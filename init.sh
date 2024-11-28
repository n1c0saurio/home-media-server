#!/bin/bash

help() (
    :
)

# TODO: Fix multiple arguments not being retrieved, add it to the docstring
# Utility function to ask for confirmation before run any other function or command
ask_to() (
    echo -en "\n🡆 $1 (y/n): "
    read -r response
    case $response in
    y | Y) "$2" ;;
    n | N | *) echo "  Omitting..." ;;
    esac
)

# Utility function to add all the needed repositories before install the packages.
# Called automatically by `add_repos()`.
add_repos() (
    # Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    # TODO: Add MEGA CLI, to sync a directory where important logs from the system should be saved
)

# Add every package needed to deploy this setup along with other useful ones
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

# Setup a default user with admin privileges
create_user() (
    groupadd \
        --gid "${USER_GROUP_ID}" "${USER_GROUP_NAME}"
    adduser \
        --shell /bin/bash \
        --uid "${USER_GROUP_ID}" \
        --gid "${USER_GROUP_ID}" \
        "${USER_GROUP_NAME}"

    adduser "${USER_GROUP_NAME}" sudo
    adduser "${USER_GROUP_NAME}" docker

    # TODO: ...
    cp -r .ssh /home/"${USER_GROUP_NAME}"/
    chown -R "${USER_GROUP_NAME}":"${USER_GROUP_NAME}" /home/"${USER_GROUP_NAME}"/.ssh
)

# General configurations for the whole system
system_settings() (
    timedatectl set-timezone "${TIMEZONE}"

    hostnamectl set-hostname "${HOSTNAME_STATIC}" --static
    hostnamectl set-hostname "${HOSTNAME_PRETTY}" --pretty
    # Fix hostname error when run sudo
    echo "127.0.1.1       ${HOSTNAME_STATIC}" >> /etc/hosts

    ask_to "Edit WIFI authentication?" vim /etc/network/interfaces.d/wlan0
)

# Non-critical configurations
customizations() (
    # TODO: .bashrc customizations and the likes
    :
)

# Lock some features to enhance the security of the system
secure_system() (
    # Disable configurable system settings
    # https://raspi.debian.net/defaults-and-settings
    systemctl disable rpi-set-sysconf

    # Disable root account after successfuly created a custom user
    su - "${USER_GROUP_NAME}"
    sudo passwd root -ld
)

main() (
    # TODO: Check the existence of `.env` and `.htpasswd` files before run

    if [ "$EUID" != 0 ]; then
        sudo "$0"
        exit $?
    fi
)

main
