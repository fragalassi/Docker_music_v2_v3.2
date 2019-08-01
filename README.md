
## Install nvidia-docker2 (https://github.com/NVIDIA/nvidia-docker)
  `sudo apt-get install -y nvidia-docker2`
  `sudo pkill -SIGHUP dockerd`

## Copy Docker requirements
- Copy your github ssh keys (with no passphrase in a .ssh folder in the current directory

## Build image
  `docker build .`

## Run container using nvidia runtime
  `docker run --runtime=nvidia -it CONTAINER_ID`

- The CONTAINER_ID is the id displayed at the end of the build process

## Run the pipeline
- See call.sh as an example of how to use the pipeline
  `bash call.sh`
  
