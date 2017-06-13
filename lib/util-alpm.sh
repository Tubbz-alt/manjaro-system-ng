#!/bin/sh

is_systemd=true
[[ -d /run/openrc ]] && is_systemd=false

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

run_pacman(){
    rm_db_lck
    pacman --noconfirm "$@"
    mk_db_lck
}

is_greater(){
    if [ "$(vercmp $1 $2)" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

is_lower(){
    if [ "$(vercmp $1 $2)" -lt 0 ]; then
        return 0
    else
        return 1
    fi
}

is_equal(){
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
