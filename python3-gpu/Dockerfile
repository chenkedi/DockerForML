# IOT Data team python 3.6 tensorflow with gpu

FROM registry.docker-cn.com/library/ubuntu:16.04
MAINTAINER chenkedi <chenkedi@baidu.com>

# install cuda8 and cudnn6
RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list

ENV CUDA_VERSION 8.0.61

ENV CUDA_PKG_VERSION 8-0=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-8-0=8.0.61.2-1 \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-8.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDNN_VERSION 6.0.21
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn6=$CUDNN_VERSION-1+cuda8.0 && \
    rm -rf /var/lib/apt/lists/*


ADD ./Anaconda3-5.0.1-Linux-x86_64.sh /root/
ADD ./opencv-3.3.1.zip /root/
ADD ./opencv_contrib-3.3.1.zip /root/

# change source to cn archive
#RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
#RUN echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse" > /etc/apt/sources.list && \
#    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list && \
#    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse"  >> /etc/apt/sources.list && \
#    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse"  >> /etc/apt/sources.list && \
#    echo "deb http://cn.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse"  >> /etc/apt/sources.list && \
#    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse"  >> /etc/apt/sources.list && \
#    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse"  >> /etc/apt/sources.list && \
#    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
#    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
#    echo "deb-src http://cn.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
#    echo "deb http://archive.canonical.com/ubuntu/ xenial partner" >> /etc/apt/sources.list

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# install the necessary packages for anaconda, and add python3.6-dev repository
RUN apt-get update && apt-get -y upgrade && apt-get install -f -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 software-properties-common vim \
    git mercurial subversion libcupti-dev

# start install andaconda and set environment variable
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    /bin/bash /root/Anaconda3-5.0.1-Linux-x86_64.sh -b -p /opt/conda

ENV PATH /opt/conda/bin:$PATH

ENV LD_LIBRARY_PATH /usr/local/cuda/lib64/:$LD_LIBRARY_PATH

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
        make -j6 && \
        make install && \
        rm -rf ~/opencv-3.3.1 ~/opencv_contrib-3.3.1 && \
        cd /opt/conda/lib/python3.6/site-packages && \
        ln -s /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so cv2.so

# change the mirror for faster speed when using pip
RUN mkdir ~/.pip && \
        touch ~/.pip/pip.conf && \
        echo "[global]" > ~/.pip/pip.conf && \
        echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf

# create and install tensorflow gpu
RUN conda create -y -n tensorflow --clone root && \
    /bin/bash -c 'source activate tensorflow && \
        conda info -e && \
        pip install \
            -i https://pypi.tuna.tsinghua.edu.cn/simple/ \
            https://mirrors.tuna.tsinghua.edu.cn/tensorflow/linux/gpu/tensorflow_gpu-1.4.0-cp36-cp36m-linux_x86_64.whl'

# setting up the jupyter notebook, password is "iotdata"
#RUN jupyter notebook --generate-config --allow-root
RUN mkdir ~/.jupyter && \
    touch ~/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = 'sha1:30ea4f2bba35:9d0c41fa8fa2554b8207354c66c7e95dda5de52a'" > ~/.jupyter/jupyter_notebook_config.py && \
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
ENTRYPOINT ["/bin/bash", "-c", "source activate tensorflow && /etc/init.d/ssh start && jupyter notebook --ip=0.0.0.0 --port=8088 --no-browser --allow-root"]
