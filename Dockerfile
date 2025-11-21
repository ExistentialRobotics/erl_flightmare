FROM ubuntu:22.04 as flightmare_base
SHELL ["/bin/bash", "-o", "pipefail", "-ic"]

ENV DEBIAN_FRONTEND=noninteractive

# Installing some essential system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
   lsb-release \
   build-essential \
   python3 python3-dev python3-pip \
   cmake \
   openssh-client \
   git \
   vim \
   wget \
   curl \
   net-tools \
   ca-certificates \
   libsodium-dev \
   libzmq3-dev \
   nlohmann-json3-dev \
   libboost-all-dev \
   libopencv-dev \
   gnupg2 \
   && rm -rf /var/lib/apt/lists/*

# Add GitHub to known hosts for private repositories
RUN mkdir -p ~/.ssh \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts \
  && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

# Build zmqpp from source and install
RUN cd /home && \
    git clone https://github.com/zeromq/zmqpp.git && \
    cd zmqpp && \
    make && \
    make client && \
    make install && \
    ldconfig

from flightmare_base as flightmare_deps
WORKDIR /home/erl

# Installing miniconda
RUN cd /home/erl && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/erl/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

RUN echo "export PATH=/home/erl/miniconda3/bin:\$PATH" >> ~/.bashrc && \
    source ~/.bashrc && \
    conda init bash && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda config --set always_yes yes --set changeps1 no && \
    conda create -n flightmare python=3.6 pip && \
    echo "conda activate flightmare" >> ~/.bashrc && \
    source ~/.bashrc && \
    conda activate flightmare && \
    pip install --upgrade pip setuptools

RUN pip install \
    tensorflow-gpu==1.14 \
    scikit-build \
    opencv-python==4.5.5.64 \
    ruamel.yaml==0.16

RUN echo "export FLIGHTMARE_PATH=/home/erl/erl_flightmare" >> ~/.bashrc && \
    source ~/.bashrc

# Install as developer
from flightmare_deps as flightmare_dev

COPY . /home/erl/erl_flightmare

RUN cd /home/erl/erl_flightmare/flightlib && \
    pip3 install . && \
    cd /home/erl/erl_flightmare/flightrl && \
    pip3 install .

RUN cd /home/erl/erl_flightmare/flightlib/build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Install as normal user
from flightmare_deps as flightmare

RUN --mount=type=ssh \
    cd /home/erl/ && \
    git clone git@github.com:ExistentialRobotics/erl_flightmare.git

RUN cd /home/erl/erl_flightmare/flightlib && \
    pip3 install . && \
    cd /home/erl/erl_flightmare/flightrl && \
    pip3 install .

RUN cd /home/erl/erl_flightmare/flightlib/build && \
    cmake .. && \
    make -j$(nproc) && \
    make install