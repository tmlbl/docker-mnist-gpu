FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

## Retrieve the cuda library

RUN apt-get install -y wget
RUN wget http://us.download.nvidia.com/XFree86/Linux-x86_64/319.72/NVIDIA-Linux-x86_64-319.72.run
RUN sh NVIDIA-Linux-x86_64-319.72.run -x --keep --target cuda
RUN mv cuda/libcuda.so.319.72 /usr/lib/
RUN ln -s -T /usr/lib/libcuda.so.319.72 /usr/lib/libcuda.so

## Install Julia and add the HDF5 package

RUN apt-get install -y julia build-essential hdf5-tools
RUN julia -E "Pkg.add(\"HDF5\")"

## Run scripts to fetch and convert test data

RUN mkdir /opt/mnist
ADD ./get-mnist.sh /opt/mnist/
ADD ./mnist-convert.sh /opt/mnist/

RUN cd /opt/mnist/ && ./get-mnist.sh
RUN cd /opt/mnist/ && ./mnist-convert.sh

## Run the example

ENV MOCHA_USE_CODA disabled
ADD . /opt/mnist

RUN mv cuda/
RUN julia -E "Pkg.add(\"Mocha\")"
RUN julia /opt/mnist/mnist.jl
