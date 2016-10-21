
# docker-opencv
defines a docker container running Arch Linux with the opencv with extra modules and CUDA.
(it's pre-half of the project docker-lidar!)

## Build Arch Linux docker image

### Recommend

If you want to mount the /var/cache/pacman/pkg/ to reuse the cache, try rocker (https://github.com/grammarly/rocker)

    MYUSER=${USER}
    MYARCH=$(uname -m)

    #sudo nvidia-docker build -t ${MYUSER}/archopencv-${MYARCH}-prebuild .

    cp Dockerfile Rockerfile
    sed -i \
        -e "s|^[# ]*MOUNT cgroup.*$|MOUNT /sys/fs/cgroup/:/sys/fs/cgroup/|g" \
        -e "s|^[# ]*MOUNT pacman.*$|MOUNT /root/homegw/sources/pacman-pkg-x64:/var/cache/pacman/pkg/|g" \
        -e "s|^[# ]*MOUNT source.*$|MOUNT /root/homegw/sources/:/sources/|g" \
        -e "s|^[# ]*PUSH .*$|PUSH ${MYUSER}/archopencv-${MYARCH}-prebuild|g" \
        -e "s|^[# ]*ATTACH .*$|ATTACH|g" \
        -e "s|^RUN pacman -Sc$|# RUN pacman -Sc|g" \
        Rockerfile
    cat Rockerfile
    sudo ./rocker build

To reuse the source and pacman cache, and also keep the nvidia driver avaiable,
we have to use a work-around, which runs a docker container with GPU and do the compiling,
once done, commit the image. (see http://stackoverflow.com/questions/24312827/is-it-possible-to-mount-a-directory-while-building-from-dockerfile)

    TMPNAME=tmp-archopencv-${MYARCH}-${MYUSER}
    sudo nvidia-docker run --name=${TMPNAME} \
        -i -t \
        --privileged \
        --cap-add SYS_ADMIN \
        -p 2222:22 \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /etc/ssh/ssh_host_key:/etc/ssh/ssh_host_key:ro \
        -v /etc/ssh/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key:ro \
        -v /etc/ssh/ssh_host_dsa_key:/etc/ssh/ssh_host_dsa_key:ro \
        -v /etc/ssh/ssh_host_ecdsa_key:/etc/ssh/ssh_host_ecdsa_key:ro \
        -v /etc/ssh/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:ro \
        -v /root/.ssh/authorized_keys:/root/.ssh/authorized_keys:ro \
        -v /root/homegw/sources/:/sources/:rw \
        -v /root/homegw/sources/pacman-pkg-x64:/var/cache/pacman/pkg/:rw \
        --volume=$PWD/compileinstall/:/compileinstall \
        --workdir=/compileinstall \
        ${MYUSER}/archopencv-${MYARCH}-prebuild

    # and in the container, run
    /compileinstall/runme.sh

    sudo docker commit ${TMPNAME} ${MYUSER}/archopencv-${MYARCH}
    sudo docker rm -f ${TMPNAME}

### other

    MYUSER=${USER}
    MYARCH=$(uname -m)
    sed -i \
        -e "s|^[# ]*RUN yaourt -Syyua --noconfirm --needed opencv-cuda-git|RUN yaourt -Syyua --noconfirm --needed opencv-cuda-git|g" \
        -e 's|^[# ]*ENTRYPOINT .*$|ENTRYPOINT ["/lib/systemd/systemd"]|g' \
        Dockerfile
    sudo nvidia-docker build -t ${MYUSER}/archopencv-${MYARCH}:latest .

    #sudo docker build \
    #    --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm \
    #    -t ${MYUSER}/archopencv-${MYARCH}:latest \
    #    .

    #sed -i -e "s|^[# ]*RUN git clone https://aur.archlinux.org/opencv-cuda-git.git|RUN git clone https://aur.archlinux.org/opencv-cuda-git.git|g" Dockerfile

## Run and test

    # run as daemon, or replace '-d' with '--rm' to test the image
    sudo nvidia-docker run \
        -d \
        -i -t \
        --privileged \
        --cap-add SYS_ADMIN \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v /etc/ssh/ssh_host_key:/etc/ssh/ssh_host_key:ro \
        -v /etc/ssh/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key:ro \
        -v /etc/ssh/ssh_host_dsa_key:/etc/ssh/ssh_host_dsa_key:ro \
        -v /etc/ssh/ssh_host_ecdsa_key:/etc/ssh/ssh_host_ecdsa_key:ro \
        -v /etc/ssh/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:ro \
        -v /root/.ssh/authorized_keys:/root/.ssh/authorized_keys:ro \
        -v /root/homegw/sources/:/sources/:rw \
        -v /root/homegw/sources/pacman-pkg-x64:/var/cache/pacman/pkg/:rw \
        --env="DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        -h docker \
        -p 2222:22 \
        --name myarchopencv \
        ${MYUSER}/archopencv-${MYARCH}

    # test clinet
    ssh -CY -p 2222 root@localhost







