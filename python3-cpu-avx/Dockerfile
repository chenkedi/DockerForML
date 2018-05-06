# IOT Data team python 3.6 tensorflow with cpu

FROM registry.docker-cn.com/library/ubuntu:16.04

MAINTAINER chenkedi <chenkedi@baidu.com>

# download anaconda3
ADD ./Anaconda3-5.0.1-Linux-x86_64.sh /root/
#ADD https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh /root/
ADD ./tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl /root/
ADD ./opencv-3.3.1.zip /root/
ADD ./opencv_contrib-3.3.1.zip /root/

# change source to cn archive
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
RUN echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse"  >> /etc/apt/sources.list && \
    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse"  >> /etc/apt/sources.list && \
    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse"  >> /etc/apt/sources.list && \
    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse"  >> /etc/apt/sources.list && \
    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse"  >> /etc/apt/sources.list && \
    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.canonical.com/ubuntu/ xenial partner" >> /etc/apt/sources.list

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# install the necessary packages for anaconda, and add python3.6-dev repository
RUN apt-get update && apt-get -y upgrade && apt-get install -f -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 software-properties-common vim \
    git mercurial subversion

# start install andaconda and set environment variable
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    /bin/bash /root/Anaconda3-5.0.1-Linux-x86_64.sh -b -p /opt/conda

ENV PATH /opt/conda/bin:$PATH


# compile and  install OpenVC3 and its dependency libs must behind anaconda due to opencv bindings need numpy
RUN add-apt-repository -y ppa:jonathonf/python-3.6 && \
    echo 'deb http://launchpad.proxy.ustclug.org/jonathonf/python-3.6/ubuntu xenial main' > /etc/apt/sources.list.d/jonathonf-ubuntu-python-3_6-xenial.list && \
    apt-get update && \
    apt-get install --fix-missing -y build-essential cmake pkg-config libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
        libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev \
        libatlas-base-dev gfortran python3.6-dev unzip

RUN cd ~ && \
        unzip opencv-3.3.1.zip && \
        unzip opencv_contrib-3.3.1.zip && \
        cd opencv-3.3.1/ && \
        mkdir build && \
        cd ~/opencv-3.3.1/build && \
        cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D WITH_IPP=OFF \
            -D INSTALL_PYTHON_EXAMPLES=ON \
            -D INSTALL_C_EXAMPLES=OFF \
            -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.3.1/modules \
            -D PYTHON_EXECUTABLE=/opt/conda/bin/python \
            -D BUILD_EXAMPLES=ON .. && \
        make -j4 && \
        make install && \
        rm -rf ~/opencv-3.3.1 ~/opencv_contrib-3.3.1 && \
        cd /opt/conda/lib/python3.6/site-packages && \
        ln -s /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so cv2.so


# change the mirror for faster speed when using pip
RUN mkdir ~/.pip && \
        touch ~/.pip/pip.conf && \
        echo "[global]" > ~/.pip/pip.conf && \
        echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf

# create and intall normal tensorflow cpu only environment
RUN conda create -y -n tensorflow --clone root && \
    /bin/bash -c 'source activate tensorflow && \
        conda info -e && \
        pip install --ignore-installed --upgrade \
            -i https://pypi.tuna.tsinghua.edu.cn/simple/ \
            https://mirrors.tuna.tsinghua.edu.cn/tensorflow/linux/cpu/tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl && \
        pip install keras'


# create and install tensorflow cpu with AVX and SSE optimization
RUN conda create -y -n tensorflow-avx --clone root && \
    /bin/bash -c 'source activate tensorflow-avx && \
        conda info -e && \
        pip install --ignore-installed --upgrade \
                -i https://pypi.tuna.tsinghua.edu.cn/simple/ \
                /root/tensorflow-1.4.0-cp36-cp36m-linux_x86_64.whl && \
        pip install keras'

# setting up the jupyter notebook, password is "iotdata"
RUN jupyter notebook --generate-config --allow-root && \
    echo "c.NotebookApp.password = 'sha1:44175ca6105c:cf046e9c45835bf866b5970322ce72154bcddd99'" > ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/mnt'" >> ~/.jupyter/jupyter_notebook_config.py

EXPOSE 8088

# use bash as default shell so jupyter terminal supporting auto complete
ENV SHELL=/bin/bash

# install ssh service so we can set a remote python interpret in containers through pycharm
RUN apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:iotdata' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # SSH login fix. Otherwise user is kicked off after login
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    # enable x11 forward for plot graph, and using compression to accelarate
    echo 'X11Forwarding yes' >> /etc/ssh/sshd_config && \
    echo 'Compression yes' >> /etc/ssh/sshd_config

# setting the default tensorflow environment when starting the image. jupyter is the last one because it's not a background deamom
ENTRYPOINT ["/bin/bash", "-c", "source activate tensorflow-avx && /etc/init.d/ssh start && jupyter notebook --ip=0.0.0.0 --port=8088 --no-browser --allow-root"]
