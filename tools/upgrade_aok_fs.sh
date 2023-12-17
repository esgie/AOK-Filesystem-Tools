#!/bin/sh
#
#  Part of https://github.com/jaclu/AOK-Filesystem-Tools
#
#  License: MIT
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#
#  Upgrades an already installed iSH to be current with /optAOK content
#  This is not equivallent to a fresh install, since dynamically generated
#  suff is better suited for a re-install.
#
#  Some sanity checks are done in order to move config and status files
#  when possible. Warnings will be printed if obsolete files are found.
#

distro_prefix() {
    if hostfs_is_alpine; then
        echo "/opt/AOK/Alpine"
    elif hostfs_is_debian; then
        echo "/opt/AOK/Debian"
    else
        error_msg "cron service not available for this FS"
    fi
}

restore_to_aok_state() {
    src="$1"
    dst="$2"
    [ -z "$src" ] && error_msg "restore_to_aok_state() - no 1st param"
    [ -z "$dst" ] && error_msg "restore_to_aok_state() - no 2nd param"
    [ -e "$src" ] || error_msg "restore_to_aok_state() - not found $src"
    [ -e "$dst" ] || error_msg "restore_to_aok_state() - not found $dst"

    msg_2 "Will restore $src -> $dst"
    rsync_chown "$src" "$dst" || error_msg "restore_to_aok_state() - Failed to copy $src -> $dst"
}

do_forced_restore() {
    echo "===  Force upgrade is requested, will update /etc/inittab and similar configs"
    restore_to_aok_state "$(distro_prefix)"/etc/inittab /etc/inittab
    restore_to_aok_state "$(distro_prefix)"/etc/profile /etc/profile
    restore_to_aok_state /opt/AOK/common_AOK/etc/init.d/runbg /etc/init.d/runbg
    restore_to_aok_state /opt/AOK/common_AOK/etc/skel /etc
    restore_to_aok_state /opt/AOK/common_AOK/etc/login.defs /etc
    if hostfs_is_alpine; then
        restore_to_aok_state "$(distro_prefix)"/etc/motd_template /etc/motd_template
    elif hostfs_is_debian; then
        restore_to_aok_state "$(distro_prefix)"/etc/pam.d /etc/pam.d
        restore_to_aok_state "$(distro_prefix)"/etc/update-motd.d /etc/update-motd.d
    elif hostfs_is_debian; then
        restore_to_aok_state "$(distro_prefix)"/etc/pam.d /etc/pam.d
        restore_to_aok_state "$(distro_prefix)"/etc/update-motd.d /etc/update-motd.d
    fi
}

launch_cmd_get() {
    tr -d '\n' <"$f_launch_cmd" | sed 's/  \+/ /g' | sed 's/"]/" ]/'
}

move_file_to_right_location() {
    f_old="$1"
    f_new="$2"
    [ -z "$f_old" ] && error_msg "move_file_to_right_location() - no first param"
    [ -z "$f_new" ] && error_msg "move_file_to_right_location() - no second param"
    [ -z "$d_new_etc_opt_prefix" ] && error_msg "d_new_etc_opt_prefix not defined"

    [ -f "$f_old" ] || return # nothing to move

    mkdir -p "$d_new_etc_opt_prefix"

    [ "${f_new%"$d_new_etc_opt_prefix/"*}" != "$f_new" ] || {
        error_msg "destination incorrect: $f_new - should start with $d_new_etc_opt_prefix"
    }

    if mv "$f_old" "$f_new"; then
        msg_3 "Moved $f_old -> $f_new"
    else
        error_msg "Failed to move: $f_old -> $f_new"
    fi
}

is_obsolete_file_present() {
    f_name="$1"
    [ -z "$f_name" ] && error_msg "is_obsolete_file_present() - no first param"

    if [ -f "$f_name" ]; then
        msg_1 "Obsolete file found: $f_name"
    elif [ -e "$f_name" ]; then
        msg_1 "Obsolete filename found, but was not file: $f_name"
    fi
}

update_etc_opt_references() {
    #
    #  Correct old filenames  - last updated 23-12-03
    #
    msg_2 "Migrating obsolete /etc/opt files to $d_new_etc_opt_prefix"
    move_file_to_right_location /etc/opt/tmux_nav_key_handling \
        "$d_new_etc_opt_prefix/tmux_nav_key_handling"
    move_file_to_right_location /etc/opt/tmux_nav_key \
        "$d_new_etc_opt_prefix/tmux_nav_key"
    move_file_to_right_location /etc/opt/hostname_source_fname \
        "$d_new_etc_opt_prefix/hostname_source_fname"

    move_file_to_right_location /etc/opt/AOK-FS/tmux_nav_key_handling \
        "$d_new_etc_opt_prefix/tmux_nav_key_handling"
    move_file_to_right_location /etc/opt/AOK-FS/tmux_nav_key \
        "$d_new_etc_opt_prefix/tmux_nav_key"
    move_file_to_right_location /etc/opt/AOK-FS/hostname_source_fname \
        "$d_new_etc_opt_prefix/hostname_source_fname"

    move_file_to_right_location /etc/opt/AOK/default-login-username \
        "$d_new_etc_opt_prefix/login-default-username"
    move_file_to_right_location /etc/opt/AOK/continous-logins \
        "$d_new_etc_opt_prefix/login-continous"
}

obsolete_files() {
    msg_2 "Ensuring no obsolete files are present"

    is_obsolete_file_present /etc/opt/AOK-login_method
    is_obsolete_file_present /etc/opt/hostname_cached
}

verify_launch_cmd() {
    msg_2 "Verifying expected 'Launch cmd'"

    launch_cmd_current="$(launch_cmd_get)"
    if [ "$launch_cmd_current" != "$launch_cmd_expected" ]; then
        msg_1 "'Launch cmd' is not the default for AOK"
        echo "Current 'Launch cmd': '$launch_cmd_current'"
        echo
        echo "To set the default, run this, it will display the updated content:"
        echo
        echo "echo '$launch_cmd_expected' | sudo tee $f_launch_cmd > /dev/null && cat $f_launch_cmd"
        # echo "sudo echo '$launch_cmd_expected' > $f_launch_cmd"
        echo
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

hide_run_as_root=1 . /opt/AOK/tools/run_as_root.sh
. /opt/AOK/tools/utils.sh

ensure_ish_or_chrooted

launch_cmd_expected='[ "/usr/local/sbin/aok_launcher" ]'
f_launch_cmd="/proc/ish/defaults/launch_command"
d_new_etc_opt_prefix="/etc/opt/AOK"

this_is_ish || error_msg "This should only be run on an iSH platform!"

if [ "$1" = "force" ]; then
    do_forced_restore
else
    echo "Not requested: force"
fi

msg_1 "Updating /etc/skel files"
rsync_chown "$d_aok_base"/common_AOK/etc/skel/ /etc/skel

msg_1 "Upgrading /usr/local/bin & /usr/local/sbin"

#
#  Always copy common stuff
#
msg_2 "Common stuff"
msg_3 "/usr/local/bin"
rsync_chown "$d_aok_base"/common_AOK/usr_local_bin/ /usr/local/bin
msg_3 "/usr/local/sbin"
rsync_chown "$d_aok_base"/common_AOK/usr_local_sbin/ /usr/local/sbin
echo
msg_3 "alternate hostname related"
[ -f /etc/init.d/hostname ] && rsync_chown "$d_aok_base"/common_AOK/hostname_handling/aok-hostname-service /etc/init.d/hostname
[ -f /usr/local/bin/hostname ] && rsync_chown "$d_aok_base"/common_AOK/hostname_handling/hostname_alt /usr/local/bin/hostname
[ -f /usr/local/sbin/hostname_sync.sh ] && rsync_chown "$d_aok_base"/common_AOK/hostname_handling/hostname_sync.sh /usr/local/sbin
echo

#
#  Copy distro specific stuff
#
if hostfs_is_alpine; then
    msg_2 "Alpine specifics"
    msg_3 "/usr/local/bin"
    rsync_chown "$d_aok_base"/Alpine/usr_local_bin/ /usr/local/bin
    msg_3 "/usr/local/sbin"
    rsync_chown "$d_aok_base"/Alpine/usr_local_sbin/ /usr/local/sbin
elif hostfs_is_debian; then
    msg_2 "Debian specifics"
    msg_3 "/usr/local/bin"
    rsync_chown "$d_aok_base"/Debian/usr_local_bin/ /usr/local/bin
    msg_3 "/usr/local/sbin"
    rsync_chown "$d_aok_base"/Debian/usr_local_sbin/ /usr/local/sbin
elif hostfs_is_devuan; then
    msg_2 "Devuan specifics"
    msg_3 "/usr/local/bin"
    rsync_chown "$d_aok_base"/Devuan/usr_local_bin/ /usr/local/bin
    msg_3 "/usr/local/sbin"
    rsync_chown "$d_aok_base"/Devuan/usr_local_sbin/ /usr/local/sbin
else
    error_msg "ERROR: Failed to recognize Distro, aborting."
fi

update_etc_opt_references
obsolete_files
verify_launch_cmd
