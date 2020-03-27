FROM ubuntu:16.04 as builder

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN set -ex \ 
     && apt-get update \
     && apt-get install -y --no-install-recommends --no-install-suggests \
     build-essential \
     cmake \
     git \
     ssh-client \
     curl \
     ca-certificates \
     libglu1-mesa-dev freeglut3-dev mesa-common-dev \
     libhdf5-dev \
     libhdf5-mpi-dev \
     ninja-build \
     && rm -rf /var/lib/apt/lists/*

# Install newer version of cmake
RUN wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add -
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
RUN apt-get update
RUN set -ex && apt-get install -y --no-install-recommends --no-install-suggests cmake

# Copy SSH key for git private repos
# Need to have a private key wih no passphrase
ADD .ssh/id_rsa /root/.ssh/id_rsa
ADD .ssh/id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa*
RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

## VTK
ENV VTK_GIT_TAG=v8.2.0

RUN set -ex \
     && mkdir -p /src/externals && cd /src/externals \
     && git clone --depth 1 -b ${VTK_GIT_TAG} https://github.com/Kitware/VTK.git \
     && mkdir -p VTK/build && cd VTK/build \
     && cmake \
     -G Ninja \
     -DCMAKE_BUILD_TYPE:STRING=Release \
     -DBUILD_EXAMPLES:BOOL=OFF \
     -DBUILD_TESTING:BOOL=OFF \
     -DVTK_LEGACY_REMOVE:BOOL=ON \
     .. \
     && ninja -j $(nproc) install

## ITK
ENV ITK_GIT_TAG=release-4.13

RUN set -ex \
     && mkdir -p /src/externals && cd /src/externals \
     && git clone --depth 1 -b ${ITK_GIT_TAG} https://github.com/InsightSoftwareConsortium/ITK.git \
     && mkdir -p ITK/build && cd ITK/build \
     && cmake \
     -G Ninja \
     -DCMAKE_BUILD_TYPE:STRING=Release \
     -DBUILD_SHARED_LIBS:BOOL=ON \
     -DBUILD_EXAMPLES:BOOL=OFF \
     -DBUILD_TESTING:BOOL=OFF \
     -DITKV3_COMPATIBILITY:BOOL=OFF \
     -DITK_BUILD_DEFAULT_MODULES:BOOL=ON \
     -DModule_ITKReview:BOOL=ON \
     -DModule_ITKVtkGlue:BOOL=ON \
     -DVTK_DIR=/src/externals/VTK/build \
     .. \
     && ninja -j $(nproc) install

## Anima
WORKDIR /music
RUN set -ex \
     && git clone --depth 1 -b music-v3.1 git@github.com:Inria-Visages/Anima-Public.git \
     && cd Anima-Public && mkdir build && cd build && cmake \
     -G Ninja \
     -DUSE_ANIMA_PRIVATE=ON \
     -DUSE_SYSTEM_VTK=ON \
     -DUSE_SYSTEM_ITK=ON \
     -DVTK_DIR=/src/externals/VTK/build \
     -DITK_DIR=/src/externals/ITK/build \
     .. && ninja -j $(nproc) 

## change Anima_Private branch and recompile     
RUN cd Anima-Public/Anima_Private && git checkout music-v3.1 -b music-v3.1
RUN cd Anima-Public/build/Anima_Private && cmake -G Ninja ../../Anima_Private/ && ninja -j $(nproc) 

#RUN cd Anima-Public/build/Boost && ninja -j $(nproc) install
RUN cd Anima-Public/build/NLOPT && ninja -j $(nproc) install 
RUN cd Anima-Public/build/RPI && ninja -j $(nproc) install 
#RUN cd Anima-Public/build/TCLAP && ninja -j $(nproc) install 
RUN cd Anima-Public/build/TinyXML2 && ninja -j $(nproc) install 


#FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04
FROM tensorflow/tensorflow:1.5.0-devel-gpu-py3 

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN set -ex \ 
     && apt-get update \
     && apt-get install -y --no-install-recommends --no-install-suggests \
     git \
     ssh-client \
     ca-certificates \
     unzip \
#     python3 python3-distutils \
     python3 \
     curl \
     && rm -rf /var/lib/apt/lists/*

# Copy SSH key for git private repos
# Need to have a private key wih no passphrase
ADD .ssh/id_rsa /root/.ssh/id_rsa
ADD .ssh/id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa*
RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

WORKDIR /music

## Copy build artifacts in current image
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin /usr/local/bin

RUN mkdir anima
COPY --from=builder /music/Anima-Public/build/bin /music/anima
COPY --from=builder /music/Anima-Public/build/lib /usr/local/lib
RUN ldconfig

## Retrieve Anima-Scripts-Public
RUN set -ex \
     && git clone --depth 1 -b music-v3.1 git@github.com:Inria-Visages/Anima-Scripts-Public.git

## Retrieve Anima-Scripts
RUN set -ex \
     && git clone --depth 1 -b music-v3.1 git@github.com:Inria-Visages/Anima-Scripts.git


## Retrieve latest music_v2 fgalassi
RUN set -ex \
     && git clone --depth 1 git@github.com:fragalassi/music_v2.git
## Retrieve latest music_v3.2 fgalassi
RUN set -ex \
     && git clone --depth 1 git@github.com:fragalassi/music_v3.2.git


## Extract Anima-Scripts-data
COPY Anima-Scripts_data ./Anima-Scripts_data
#RUN unzip ./Anima-Scripts_data.zip && rm ./Anima-Scripts_data.zip

COPY config.txt /root/.anima/

#RUN ln -s /usr/bin/python3 /usr/bin/python

#COPY nifti-data-full-2.zip .
#RUN mkdir /data
#RUN unzip ./nifti-data-full-2.zip -d /data && rm ./nifti-data-full-2.zip
RUN mkdir /testing
COPY testing ./testing

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py &&  python get-pip.py
RUN pip3 install theano nibabel keras

RUN rm -rf /root/.ssh/
