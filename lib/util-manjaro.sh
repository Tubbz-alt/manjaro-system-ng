#!/bin/sh

if [[ -d /run/systemd ]];then
	is_systemd=true
else
	is_systemd=false
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
				install-info "$1" usr/share/info/${file}.gz usr/share/info/dir 2> /dev/null
		done
}

err() {
	ALL_OFF="\e[1;0m"
	BOLD="\e[1;1m"
	RED="${BOLD}\e[1;31m"
	local mesg=$1; shift
	printf "${RED}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}

msg() {
	ALL_OFF="\e[1;0m"
	BOLD="\e[1;1m"
	GREEN="${BOLD}\e[1;32m"
	local mesg=$1; shift
	printf "${GREEN}==>${ALL_OFF}${BOLD} ${mesg}${ALL_OFF}\n" "$@" >&2
}
