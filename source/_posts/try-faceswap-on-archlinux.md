---
title: Try faceswap with Arch Linux
date: 2019-04-01 23:34:00
tags:
- faceswap
- Arch
- Linux
---

# What is faceswap

See [deepfakes/faceswap](https://github.com/deepfakes/faceswap)

Seems a little bit difficult to use it.

But worth to give it a try.

# Make it work

## Install anaconda

> If you don't have `yay`, check [this](http://www.findshank.com/2018/06/18/Install-yaourt-on-Arch-Linux/) post.

```sh
yay -S anaconda
```

## Create a conda virtual environment

```sh
conda create -n faceswap python=3.6
```

> python3.6 is recommended here.

## Install Nvidia driver and cuda support

```sh
yay -S nvidia nvidia-utils cuda
```

> We need cuda-10.0 here! If not match this version. try `downgrade`

<details>

<summary>How to downgrade?</summary>

```sh
yay -S downgrade
downgrade cudnn
```

</details>

## Add cudnn to cuda

Download cuDNN-7.5 for cuda-10.0 on [official site](https://developer.nvidia.com/cudnn).

> You neet to register and login first.

Then unzip the `cudnn-10.0-linux-x64-v7.5.0.56.tgz` file to `/opt/cuda`.

## Get faceswap source code and install it

```sh
git clone https://github.com/deepfakes/faceswap.git
cd faceswap

# active conda virtual environment
source activate faceswap

# install
python setup.py
```

<details>

<summary>dlib problem?</summary>

You may got `dlib` problem when you run faceswap.

```sh
# replace blas with openblas
sudo pacman -S openblas

# get dlib source code
git clone https://github.com/davisking/dlib.git
cd dlib

# active conda virtual environment
source activate faceswap

python setup.py install
```

</details>

## play with faceswap

```sh
# try gui
python faceswap.py gui
```

![screenshot](Screenshot.png)

# Ref

* [INSTALL.md](https://github.com/deepfakes/faceswap/blob/master/INSTALL.md)
* [Create virtual environments for python with conda](https://uoa-eresearch.github.io/eresearch-cookbook/recipe/2014/11/20/conda/)
* [Getting Started With NVIDIA GPU, Anaconda, TensorFlow and Keras on Arch Linux](https://medium.com/@mimoralea/getting-started-with-nvidia-gpu-anaconda-tensorflow-and-keras-on-arch-linux-8f5f2868a455)
* [How To Downgrade A Package In Arch Linux](https://www.ostechnix.com/downgrade-package-arch-linux/)
