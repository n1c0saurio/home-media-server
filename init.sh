#!/bin/bash

help() (
    :
)

# Ask for confirmation before run any other given function or command.
#
# Example:
#   ask-to "Upgrade the packages?" apt-get upgrade -y
ask-to() {
    echo -en "\n🡆 $1 (y/n): "
    read -r response
    case $response in
    y | Y) "${@:2}" ;; # Expand the remaining positional arguments
    n | N | *) echo "  Omitting..." ;;
    esac
}

# Add all the needed repositories before install any packages.
# Called automatically by `add_repos()`.
add-repos() {
    # Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    # TODO: Add MEGACMD, to sync a directory where important logs from the system should be saved
}

# Add every package needed to deploy this setup along with other useful ones.
install-packages() {
    add-repos

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
}

# Setup a default user with admin privileges.
create-user() {
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
}

# General configurations for the whole system.
system-settings() {
    timedatectl set-timezone "${TIMEZONE}"

    hostnamectl set-hostname "${HOSTNAME_STATIC}" --static
    hostnamectl set-hostname "${HOSTNAME_PRETTY}" --pretty
    # Fix hostname error when run sudo
    # TODO: Improve to add it on the second line
    echo "127.0.1.1       ${HOSTNAME_STATIC}" >>/etc/hosts

    ask-to "Edit WIFI authentication interactively?" vim /etc/network/interfaces.d/wlan0
}

# Non-critical configurations.
customizations() {
    # TODO: .bashrc customizations and the likes
    :
}

# Disable some features to enhance the security of the system.
secure-the-system() {
    # Disable configurable system settings
    # https://raspi.debian.net/defaults-and-settings
    systemctl disable rpi-set-sysconf

    # Disable root account after successfuly created a custom user
    su - "${USER_GROUP_NAME}"
    sudo passwd root -ld
}

main() {
    # Validations
    if [[ ! -f .env || ! -f .htpasswd ]]; then
        echo "Fatal error: .env and .htpasswd are both required to run this script."
        exit 1
    fi

    if [ "$EUID" != 0 ]; then
        echo "This script requires superuser privileges..."
        sudo "$0"
        exit $?
    fi

    echo "Home Media Server setup started..."

    ask-to "Install packages?" install-packages
    ask-to "Apply general system configurations?" system-settings
    ask-to "Create a regular user?" create-user
    ask-to "Apply non-critical configurations?" customizations
    ask-to "Enforce the system security?" secure-the-system
}

main
