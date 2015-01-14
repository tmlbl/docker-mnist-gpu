.PHONY: build
build:
	- docker build -t mnist .

.PHONY: run
run:
	- docker run -v `pwd`:/opt/mnist mnist bash -c "julia /opt/mnist/mnist.jl"

.PHONY: sim
sim:
	- docker run -i -t -v `pwd`:/opt/mnist mnist /bin/bash
