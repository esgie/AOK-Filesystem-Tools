#!/bin/sh
#
#  Part of https://github.com/emkey1/AOK-Filesystem-Tools
#
#  License: MIT
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#
#  upgrades /usr/local/bin & /usr/local/sbin with latest versions
#  from /opt/AOK, both common and distro based items
#

upgrade_distro_files() {
    # msg_2 "upgrade_distro_files()"
    distro="$1"
    [ -z "$distro" ] && error_msg "upgrade_distro_files() Did not provide distro name"

    _base_dir="$aok_content/$distro"
    [ ! -d "$_base_dir" ] && error_msg "$_base_dir - Not an existing dir, should be there!"

    echo "$distro stuff"

    if [ -d "$_base_dir"/usr_local_bin ]; then
        # msg_3 "$distro/usr_local_bin"
        rsync -ahP "$_base_dir"/usr_local_bin/* /usr/local/bin
    fi
    if [ -d "$_base_dir"/usr_local_sbin ]; then
        # msg_3 "$distro/usr_local_sbin"
        rsync -ahP "$_base_dir"/usr_local_sbin/* /usr/local/sbin
    fi
    # msg_3 "upgrade_distro_files() - done"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Allowing this to be run from anywhere using path
current_dir=$(cd -- "$(dirname -- "$0")" && pwd)

#
#  Automatic sudo if run by a user account, do this before
#  sourcing tools/utils.sh !!
#  hide_run_as_root=1  prevents this from showing: Executing $app as root
#
# shellcheck source=/opt/AOK/tools/run_as_root.sh
. "$current_dir"/run_as_root.sh

# shellcheck source=/opt/AOK/tools/utils.sh
. "$current_dir"/utils.sh

# if ! this_is_ish; then
#     error_msg "This should only be run on an iSH platform!"
# fi

echo
echo "Upgrading /usr/local/bin & /usr/local/sbin with current items from $aok_content"
echo

#
#  Always copy common stuff
#
echo "Common stuff"
rsync -ahP "$aok_content"/common_AOK/usr_local_bin/* /usr/local/bin
rsync -ahP "$aok_content"/common_AOK/usr_local_sbin/* /usr/local/sbin

#
#  Per Distro files
#

case "$(hostfs_detect)" in

"$distro_alpine")
    upgrade_distro_files "$distro_alpine"
    ;;
"$distro_debian")
    upgrade_distro_files "$distro_debian"
    ;;
"$distro_devuan")
    upgrade_distro_files "$distro_devuan"
    ;;
*)
    error_msg "Platform not recognized, can not decide how to upgrade"
    ;;
esac
