#!/bin/sh

if [[ -d /run/openrc ]];then
    is_systemd=false
else
    is_systemd=true
fi


rm_db_lck(){
    rm /var/lib/pacman/db.lck &> /dev/null
}

mk_db_lck(){
    touch /var/lib/pacman/db.lck &> /dev/null
}

is_symlink(){
    if [ -L "$1" ]; then
        return 0
    else
        return 1
    fi
}

is_installed(){
    if pacman -Qq $1; then
        return 0
    else
        return 1
    fi
}

is_installed_nvidia(){
    if [ "$(mhwd -li | grep nvidia)" != "" ] && \
        [ "$(mhwd -li | grep hybrid)" == "" ] ; then
        return 0
    else
        return 1
    fi
}

is_installed_ati(){
    if [ "$(mhwd -li | grep catalyst)" != "" ] && \
        [ "$(mhwd -li | grep hybrid)" == "" ]; then
        return 0
    else
        return 1
    fi
}

is_installed_hybrid(){
    if [ "$(mhwd -li | grep hybrid)" != "" ]; then
        return 0
    else
        return 1
    fi
}

install_pkg(){
    local pkg=$1
    rm_db_lck
    pacman --noconfirm -S $pkg
    mk_db_lck
}

run_pac_cmd(){
    local args=$1 pkgs=$2
    rm_db_lck
    pacman --noconfirm -$args $pkgs
    mk_db_lck
}

remove_pkg(){
    local pkg=$1
    rm_db_lck
    pacman --noconfirm -Rdd $pkg
    mk_db_lck
}

ver_is_greater(){
    if [ "$(vercmp $1 $2)" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

ver_is_lower(){
    if [ "$(vercmp $1 $2)" -lt 0 ]; then
        return 0
    else
        return 1
    fi
}

ver_is_equal(){
    if [ "$(vercmp $1 $2)" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

get_pkg_ver(){
    local pkg=$1 result
    result=$(pacman -Q $pkg)
    echo ${result##* }
}

set_pkg_ver(){
    ver=$(get_pkg_ver $1)
}

configure_grub_info(){
    for file in grub.info grub-dev.info; do
        install-info "$@" /usr/share/info/${file}.gz /usr/share/info/dir 2> /dev/null
    done
}

run_depmod(){
    for kernel in /usr/lib/modules/extramodules-*-MANJARO/version;do
        local version=$(cat $kernel)
        echo ">>> Updating ${version} module dependencies ..."
        depmod ${version}
    done
}
#
# run_initcpio(){
#     for preset in /etc/mkinitcpio.d/*.preset;do
#         # remove old initcpio
#         source $preset
#         rm -f ${default_image}
#
#         local kern=${preset%.*}
#         echo ">>> Generating ${kern##*/} initial ramdisk, using mkinitcpio ..."
#
#         mkinitcpio -p ${kern##*/}
#     done
# }
