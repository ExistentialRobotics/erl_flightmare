FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04 AS flightmare_base
SHELL ["/bin/bash", "-o", "pipefail", "-ic"]

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

# ------------------------------------------------------------
# Add GitHub to known hosts for private repositories
# ------------------------------------------------------------
RUN mkdir -p ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

# ------------------------------------------------------------
# System dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    lsb-release \
    build-essential \
    python3 python3-dev python3-pip \
    cmake \
    git \
    vim \
    ca-certificates \
    # libzmqpp-dev \
    libopencv-dev \
    gnupg2 \
    x11-apps\
    x11-utils \
    mesa-utils \
    ssh \
    curl \
    wget \
    gdb \
    libomp-dev \
    software-properties-common \
    wget \
    gnupg \
    net-tools \
    openssh-client \
    # libsodium-dev \
    # libzmq3-dev \
    # libboost-all-dev \
    nlohmann-json3-dev \
    libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/packages
# ------------------------------------------------------------
# Build libzmq & zmqpp from source and install
# ------------------------------------------------------------
RUN --mount=type=ssh \
    cd /root/packages && \
    git clone git@github.com:zeromq/libzmq.git && \
    cd libzmq && \
    ./autogen.sh && \
    ./configure && make && \
    make install && \
    ldconfig

RUN --mount=type=ssh \
    cd /root/packages && \
    git clone git@github.com:zeromq/zmqpp.git && \
    cd zmqpp && \
    make && \
    # make client && \
    make install && \
    ldconfig

FROM flightmare_base AS flightmare_deps
# ------------------------------------------------------------
# Installing miniconda
# ------------------------------------------------------------
RUN cd /root/erl && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/erl/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

RUN echo "export PATH=/root/erl/miniconda3/bin:\$PATH" >> ~/.bashrc && \
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

RUN echo "export FLIGHTMARE_PATH=/root/erl/erl_flightmare" >> ~/.bashrc && \
    source ~/.bashrc

FROM flightmare_deps AS flightmare_ros
# ------------------------------------------------------------
# Add ROS2 repository
# ------------------------------------------------------------
RUN add-apt-repository universe && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# ------------------------------------------------------------
# Install ROS2
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-desktop-full \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc \
    && source ~/.bashrc

FROM flightmare_ros AS flightmare
# ------------------------------------------------------------
# Clone Flightmare as root
# ------------------------------------------------------------
RUN --mount=type=ssh \
    cd /root/erl/ && \
    git clone git@github.com:ExistentialRobotics/erl_flightmare.git

RUN cd /root/erl/erl_flightmare/flightlib && \
    pip3 install . && \
    cd /root/erl/erl_flightmare/flightrl && \
    pip3 install .

RUN cd /root/erl/erl_flightmare/flightlib/build && \
    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
    make -j$(nproc) && \
    make install
