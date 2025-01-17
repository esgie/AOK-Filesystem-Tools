#!/bin/sh
#
#  Part of https://github.com/jaclu/AOK-Filesystem-Tools
#
#  License: MIT
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#
#  upgrades /usr/local/bin & /usr/local/sbin with latest versions
#  from /opt/AOK, both common and distro based items
#

#===============================================================
#
#   Main
#
#===============================================================

hide_run_as_root=1 . /opt/AOK/tools/run_as_root.sh
. /opt/AOK/tools/utils.sh

this_is_ish || error_msg "This should only be run on an iSH platform!"

msg_1 "Updating /etc/skel files"
rsync_chown "$aok_content"/common_AOK/etc/skel/ /etc/skel

msg_1 "Upgrading /usr/local/bin & /usr/local/sbin"

#
#  Always copy common stuff
#
msg_2 "Common stuff"
rsync_chown "$aok_content"/common_AOK/usr_local_bin/ /usr/local/bin
rsync_chown "$aok_content"/common_AOK/usr_local_sbin/ /usr/local/sbin
[ -f /etc/init.d/hostname ] && rsync_chown "$aok_content"/common_AOK/common_AOK/aok-hostname-service /etc/init.d/hostname
[ -f /usr/local/bin/hostname ] && rsync_chown "$aok_content"/common_AOK/common_AOK/hostname_alt /usr/local/bin/hostname
[ -f /usr/local/sbin/hostname_sync.sh ] && rsync_chown "$aok_content"/common_AOK/common_AOK/hostname_sync.sh /usr/local/sbin
echo

#
#  Copy distro specific stuff
#
if hostfs_is_alpine; then
    msg_3 "Alpine specifics"
    rsync_chown "$aok_content"/Alpine/usr_local_bin/ /usr/local/bin
    rsync_chown "$aok_content"/Alpine/usr_local_sbin/ /usr/local/sbin
elif hostfs_is_debian; then
    echo "Debian specifics"
    rsync_chown "$aok_content"/Debian/usr_local_bin/ /usr/local/bin
    rsync_chown "$aok_content"/Debian/usr_local_sbin/ /usr/local/sbin
elif hostfs_is_devuan; then
    echo "Devuan specifics"
    rsync_chown "$aok_content"/Devuan/usr_local_bin/ /usr/local/bin
    rsync_chown "$aok_content"/Devuan/usr_local_sbin/ /usr/local/sbin
else
    echo "ERROR: Failed to recognize Distro, aborting."
    exit 1
fi
