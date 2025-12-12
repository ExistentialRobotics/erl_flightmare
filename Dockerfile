FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

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
    libzmqpp-dev \
    libopencv-dev \
    gnupg2 \
    x11-apps\
    x11-utils \
    mesa-utils \
    ssh \
    curl \
    wget \
    libomp-dev \
    software-properties-common \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

#RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - &&     apt-add-repository "deb https://apt.kitware.com/ubuntu/ bionic main" &&     apt-get update &&     apt-get install -y cmake &&     rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Add ROS repository
# ------------------------------------------------------------
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
      > /etc/apt/sources.list.d/ros-latest.list && \
    apt-key adv --keyserver "hkp://keyserver.ubuntu.com:80" \
        --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# ------------------------------------------------------------
# Install ROS Noetic
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Python / catkin tools
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-setuptools \
    && pip3 install --no-cache-dir catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------
RUN echo "source /opt/ros/noetic/setup.bash" >> /etc/bash.bashrc
RUN echo "export FLIGHTMARE_PATH=${FLIGHTMARE_PATH}" >> /etc/bash.bashrc

# ------------------------------------------------------------
# Clone Flightmare as root
# ------------------------------------------------------------
WORKDIR /root
RUN git clone https://github.com/uzh-rpg/flightmare.git ${FLIGHTMARE_PATH}

# ------------------------------------------------------------
# Default shell
# ------------------------------------------------------------
CMD ["/bin/bash"]
