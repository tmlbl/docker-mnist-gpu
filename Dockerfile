FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

# A docker container with the Nvidia kernel module and CUDA drivers installed
## From https://registry.hub.docker.com/u/tleyden5iwx/ubuntu-cuda/dockerfile/

ENV CUDA_RUN http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run

RUN apt-get install -q -y \
  wget \
  build-essential 

RUN cd /opt && \
  wget $CUDA_RUN && \
  chmod +x *.run && \
  mkdir nvidia_installers && \
  ./cuda_6.5.14_linux_64.run -extract=`pwd`/nvidia_installers && \
  cd nvidia_installers && \
  ./NVIDIA-Linux-x86_64-340.29.run -s -N --no-kernel-module

RUN cd /opt/nvidia_installers && \
  ./cuda-linux64-rel-6.5.14-18749181.run -noprompt

## Install HDF5 and Julia deps

RUN apt-get install -y hdf5-tools git

## Install a compatible version of Julia

RUN wget https://julialang.s3.amazonaws.com/bin/linux/x64/0.3/julia-0.3.5-linux-x86_64.tar.gz

RUN gunzip julia-0.3.5-linux-x86_64.tar.gz && \
  tar xvf julia-0.3.5-linux-x86_64.tar && \
  rm *.tar && \
  mv julia-* /opt/julia

ENV PATH $PATH:/opt/julia/bin

RUN julia -E "Pkg.add(\"Mocha\")"

## Run scripts to fetch and convert test data

RUN mkdir /opt/mnist
ADD ./get-mnist.sh /opt/mnist/
ADD ./mnist-convert.sh /opt/mnist/

RUN cd /opt/mnist/ && ./get-mnist.sh
RUN cd /opt/mnist/ && ./mnist-convert.sh

## Run the example

ENV LD_LIBRARY_PATH usr/local/cuda-6.5/lib64:$LD_LIBRARY_PATH
