#ARG MYARCH
FROM yhfu/archsshd-x86_64
MAINTAINER yhfu <yhfudev@gmail.com>

# MOUNT cgroup:/sys/fs/cgroup/ # Rockerfile
# MOUNT pacman:/var/cache/pacman/pkg/ # Rockerfile
VOLUME [ "/sys/fs/cgroup" ]

RUN pacman -Syyu --needed --noconfirm

# install dependants
RUN pacman -S --noprogressbar --noconfirm --needed lsb-release file base-devel abs fakeroot pkgfile community/pkgbuild-introspection wget git mercurial subversion cvs bzip2 unzip vim cmake make; pkgfile --update

RUN pacman -S --noprogressbar --noconfirm --needed \
        gtest libgl eigen boost vtk qhull openmpi gl2ps \
        gstreamer0.10-base openexr xine-lib libdc1394 gtkglext nvidia-utils hdf5-cpp-fortran python cuda libcl intel-tbb \
        gcc gcc5 gdb python2-numpy python-numpy mesa \
        gdal postgresql-libs libmysqlclient unixodbc

RUN sed -i -e 's/^#MAKEFLAGS.*/MAKEFLAGS="-j8"/g' /etc/makepkg.conf

USER docker
# clean up
RUN sudo rm -rf /home/docker/*

RUN yaourt -Syyua --noconfirm --needed ceres-solver
RUN yaourt -Syyua --noconfirm --needed glog ; \
    yaourt -Syyua --noconfirm --needed gflags
RUN yaourt -Syyua --noconfirm --needed pcl
RUN yaourt -Syyua --noconfirm --needed libisam


# nvidia-docker hooks
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

RUN sudo pacman -S --noprogressbar --noconfirm --needed \
        python2 python2-yaml python2-nose python2-paramiko python2-netifaces python2-pip \
        pkg-config jshon boost libyaml \
        ninja

RUN sudo pacman -S --noprogressbar --noconfirm --needed libcanberra

# MOUNT source:/sources/ # Rockerfile

# updated opencv witch opencv_contrib and CUDA
#RUN yaourt -Syyua --noconfirm --needed opencv-cuda-git
#RUN git clone https://aur.archlinux.org/opencv-cuda-git.git && cd opencv-cuda-git && ln -sf /sources/opencv-git opencv && ln -sf /sources/opencv_contrib-git opencv_contrib && ln -sf /sources/ippicv_linux_20151201.tgz && makepkg -Asf && sudo pacman --noconfirm -U opencv-cuda-git/opencv-cuda-git-*.pkg.tar.xz

USER root
RUN rm -rf /home/docker/*
RUN pacman -Sc

# use /usr/local/cuda for cmake's FindCUDA.cmake
RUN ln -s /opt/cuda /usr/local/cuda

# start the server (goes into the background)
#CMD /usr/bin/sshd; sleep infinity
#CMD ["/usr/sbin/init"]
ENTRYPOINT ["/bin/bash"]

# PUSH yhfu/archopencv:latest # Rockerfile

