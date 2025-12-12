# erl_flightmare


This project is a fork of Flightmare from uzh-rpg, See below for the original readme and ruels for citing this work.

## build instructions

### Build Dependencies
Some dependencies are no longer available from `apt` and must be installed manually, I recommend having some location for these packages outside tree for this repo, such as `~/packages`
```bash
git clone git@github.com:zeromq/libzmq.git
cd libzmq
./autogen.sh
./configure && make
sudo make install
sudo ldconfig
cd ../
# Now install ZMQPP
git clone git@github.com:zeromq/zmqpp.git
cd zmqpp
make
make check
sudo make install
make installcheck
```

At the time of writing this I am using the following commits:
```
libzmq: 7a7bfa10e6b0e99210ed9397369b59f9e69cef8e
zmqpp: ba4230d5d03d29ced9ca788e3bd1095477db08ae
```

### Install Additional Dependencies
```bash
sudo apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    libopencv-dev \
    nlohmann-json3-dev \
    libomp-dev
```

### Build Flightlib
I recommend cloning this in `~/erl/`
```bash
git clone git@github.com:ExistentialRobotics/erl_flightmare.git
```

First, add the following to `~/.bashrc` or `~/.zshrc`, replacing `~/erl/` with the path to this repo.
```bash
export FLIGHTMARE_PATH=~/erl/erl_flightmare
```

```bash
cd $FLIGHTMARE_PATH/flightlib/build
cmake ..
make -j
sudo make install
```

## Download Unity Environment
See the releases page of the official repo [here](https://github.com/uzh-rpg/flightmare/releases) or run the following command.
```bash
cd erl_flightmare/flightrender
wget https://github.com/uzh-rpg/flightmare/releases/download/0.0.5/RPG_Flightmare.tar.xz
tar xvf RPG_Flightmare.tar.xz
```

I recomend the following alias to start flightmare from anywhere.
```bash
alias flightmare='$FLIGHTMARE_PATH/flightrender/RPG_Flightmare/RPG_Flightmare.x86_64'
```

ORIGINAL README BELOW

# Flightmare - 左青龙

![Build Status](https://github.com/uzh-rpg/flightmare/workflows/CPP_CI/badge.svg) ![clang format](https://github.com/uzh-rpg/flightmare/workflows/clang_format/badge.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg) ![website]( https://img.shields.io/website-up-down-green-red/https/naereen.github.io.svg)

**Flightmare** is a flexible modular quadrotor simulator.
Flightmare is composed of two main components: a configurable rendering engine built on Unity and a flexible physics engine for dynamics simulation.
Those two components are totally decoupled and can run independently from each other.
Flightmare comes with several desirable features: (i) a large multi-modal sensor suite, including an interface to extract the 3D point-cloud of the scene; (ii) an API for reinforcement learning which can simulate hundreds of quadrotors in parallel; and (iii) an integration with a virtual-reality headset for interaction with the simulated environment.
Flightmare can be used for various applications, including path-planning, reinforcement learning, visual-inertial odometry, deep learning, human-robot interaction, etc.

**[Website](https://uzh-rpg.github.io/flightmare/)** &
**[Documentation](https://flightmare.readthedocs.io/)**

[![IMAGE ALT TEXT HERE](./docs/flightmare_main.png)](https://youtu.be/m9Mx1BCNGFU)

## Installation
Installation instructions can be found in our [Wiki](https://github.com/uzh-rpg/flightmare/wiki).

## Updates
 *  17.11.2020 [Spotlight](https://youtu.be/8JyrjPLt8wo) Talk at CoRL 2020
 *  04.09.2020 Release Flightmare

## Publication

If you use this code in a publication, please cite the following paper **[PDF](http://rpg.ifi.uzh.ch/docs/CoRL20_Yunlong.pdf)**

```
@inproceedings{song2020flightmare,
    title={Flightmare: A Flexible Quadrotor Simulator},
    author={Song, Yunlong and Naji, Selim and Kaufmann, Elia and Loquercio, Antonio and Scaramuzza, Davide},
    booktitle={Conference on Robot Learning},
    year={2020}
}
```

## License
This project is released under the MIT License. Please review the [License file](LICENSE) for more details.
