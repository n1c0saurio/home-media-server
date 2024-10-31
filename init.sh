#!/bin/bash

help() (
    :
)

add_repos() (
    # Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # MEGA?
)

install_packages() (
    add_repos

    apt-get update
    apt-get install \
        bash-completion \
        ca-certificates \
        curl \
        htop \
        libarchive-zip-perl \
        lm-sensors \
        man \
        nano \
        speedtest-cli \
        sudo \
        tree \
        tmux \
        \
        containerd.io \
        docker-buildx-plugin \
        docker-ce \
        docker-ce-cli \
        docker-compose-plugin
)

create_user() (
    groupadd \
        --gid ${USER_GROUP_ID} ${USER_GROUP_NAME}
    adduser \
        --shell /bin/bash \
        --uid ${USER_GROUP_ID} \
        --gid ${USER_GROUP_ID} \
        ${USER_GROUP_NAME}

    adduser ${USER_GROUP_NAME} sudo
    adduser ${USER_GROUP_NAME} docker

    # TODO: ...
    cp -r .ssh /home/${USER_GROUP_NAME}/
    chown -R ${USER_GROUP_NAME}:${USER_GROUP_NAME} /home/${USER_GROUP_NAME}/.ssh
)

system_settings() (
    hostnamectl set-hostname matsushiro --static
    hostnamectl set-hostname Matsushiro --pretty

    # TODO: Apply the fix to hostname error when run sudo

    # TODO: Improve interactive edit to enable wireless conectivity
    nano /etc/network/interfaces.d/wlan0
)

customizations() (
    # TODO: .bashrc customizations and the likes
    :
)

secure_system() (
    # Disable configurable system settings
    # https://raspi.debian.net/defaults-and-settings
    systemctl disable rpi-set-sysconf

    # Disable root account after successfuly created a custom user
    su - ${USER_GROUP_NAME}
    sudo passwd root -ld
)

main() (
    # TODO: Check the existence of `.env` and `.htpasswd` files before run
    :
)
