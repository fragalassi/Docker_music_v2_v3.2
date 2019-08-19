## Copy Docker requirements
Clone the repository on your computer

## Install nvidia-docker2 (https://github.com/NVIDIA/nvidia-docker)
  `sudo apt-get install -y nvidia-docker2`
  `sudo pkill -SIGHUP dockerd`

## github ssh keys
Copy your github ssh keys (with no passphrase in a .ssh folder in the current directory)

## Build image
  `docker build .`

## Run container using nvidia runtime
  `docker run --runtime=nvidia -it CONTAINER_ID`

The CONTAINER_ID is the id displayed at the end of the build process

## Run the pipeline

This Docker contains two pipelines: 

- folder music_v2: pipeline based on graph-cuts with a priori map
	See music_v2/call.sh as an example of how to use the pipeline
 	`bash call.sh`

- folder music_v3.2: pipeline based on a CNN (outperforming the pipeline music_v2 in accuracy and robustness)
	See music_v3.2/call.sh as an example of how to use the pipeline
  	`bash call.sh`

## Authors

If you make use fo the pipeline music_v2, please cite:

F. Galassi, O. Commowick, C. Barillot. Integration of Probabilistic Atlas and Graph Cuts for Automated Segmentation of Multiple Sclerosis lesions. International Society for Magnetic Resonance in Medicine (ISMRM 2018), Jun 2018, Paris, France. pp.1-6. ⟨hal-01823801⟩

If you make use fo the pipeline music_v3.2, please cite:

F. Galassi, S. Tarride, E. Vallée, O. Commowick, C. Barillot. Deep learning for multi-site ms lesions segmentation: two-step intensity standardization and generalized loss function. ISBI 2019 - IEEE International Symposium on Biomedical Imaging, Apr 2019, VENICE,Italy. pp.1. Francesca Galassi, Solène Tarride, Emmanuel Vallée, Olivier Commowick, Christian Barillot. Deep learning for multi-site ms lesions segmentation: two-step intensity standardization and generalized loss function. ISBI 2019 - IEEE International Symposium on Biomedical Imaging, Apr 2019, VENICE, Italy. pp.1. ⟨hal-02052250⟩


## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

The cascaded CNN architecture at the core of the segmentation step of our pipeline music_v3.2 was proposed by https://github.com/sergivalverde/nicMSlesions. We thank the main author S. Valverde for the positive and helpful discussions.

We thank B<>com, Rennes, for the software development collaboration, essential to translate research work into the clinical practice.

We thank Rennes CHU for the clinical feedback and extensive discussions that have helped optimizing this pipeline so to actually assist clinicians in their practice.

