#!/bin/sh
# This is sourced. Fake bang-path to help editors and linters
#
#  Part of https://github.com/jaclu/AOK-Filesystem-Tools
#
#  License: MIT
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#
#  Varios things used at multiple places during Debian installs
#

intial_fs_prep_debian() {
    msg_2 "intial_fs_prep_debian()"
    #
    #  fix_dev is run by the AOK inittab, so needs to be present
    #  from the start in case this is not a pre-build
    #
    msg_3 "Installing fix_dev"
    cp "${aok_content}"/common_AOK/usr_local_sbin/fix_dev "$d_build_root"/usr/local/sbin

    #
    #  This modified inittab is needed on firstboot, in order to be
    #  able to set runlevels, it forcefully clears /run/openrc before
    #  going to runlevel S
    #
    msg_3 "Debian AOK inittab"
    cp -a "$aok_content"/Debian/etc/inittab "$d_build_root"/etc

    # msg_3 "intial_fs_prep_debian() - done"
}

. /opt/AOK/tools/utils.sh
