# This Dockerfile aims to provide a Pangeo-style image with the VNC/Linux Desktop feature
# It was constructed by following the instructions and copying code snippets laid out
# and linked from here:
# https://github.com/2i2c-org/infrastructure/issues/1444#issuecomment-1187405324

FROM ubuntu:22.04

WORKDIR /code

# Get library dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y software-properties-common \
    libnetcdf-dev \
    libnetcdff-dev \
    liblapack-dev \
    libopenblas-dev \
    cmake \
    g++ \
    git \
    libssl-dev \
    make \
    gfortran \
    wget \
    python3-pip \
    valgrind \
    gdb &&\
    apt-get autoclean

RUN pip3 install xarray
RUN pip3 install netcdf4

# Install the C++ Actor Framework 0.18.6
RUN wget https://github.com/actor-framework/actor-framework/archive/refs/tags/0.18.6.tar.gz
RUN tar -xvf 0.18.6.tar.gz
WORKDIR /code/actor-framework-0.18.6
RUN ./configure
WORKDIR /code/actor-framework-0.18.6/build
RUN make -j 4
RUN make test
RUN make install

WORKDIR /code

# Install Sundials
RUN wget https://github.com/LLNL/sundials/releases/download/v7.0.0/sundials-7.0.0.tar.gz
RUN tar -xzf sundials-7.0.0.tar.gz
RUN mkdir sundials
WORKDIR /code/sundials
RUN mkdir /usr/local/sundials
RUN mkdir builddir
WORKDIR /code/sundials/builddir
RUN cmake ../../sundials-7.0.0 -DBUILD_FORTRAN_MODULE_INTERFACE=ON \
        -DCMAKE_Fortran_COMPILER=gfortran \
        -DCMAKE_INSTALL_PREFIX=/usr/local/sundials \
        -DEXAMPLES_INSTALL_PATH=/code/sundials/instdir/examples
RUN make
RUN make install

# Change workdir for when we attach to this container
WORKDIR /Summa-Actors

USER ${NB_USER}
