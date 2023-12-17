# Dinit Services for Slackware
This project's goal is to create dinit services for use on Slackware Linux. This includes both system services and user services.

## Dinit System Services
System services managed by dinit are those that are traditionally found in the `/etc/rc.d/` directory on Slackware linux. Equivalent dinit services are installed at `/etc/dinit.d/system/`. 

Not all services present in Slackware's `/etc/rc.d/` directory are converted to an equivalent dinit service yet. The list of services remaining to convert are listed in the TODO file of the git repository.

## Dinit User Services
User services managed by dinit are things like pipewire, dbus, wireplumber, gnome-keyring-daemon, etc. These services are installed to `/etc/dinit.d/user/` so that all users can control the same services/daemons.

## Dinit Scripts
Support scripts are installed to `/etc/dinit.d/scripts/`. These scripts are either "oneshot" style service scripts used by dinit's system or user instance. The `dinit-user.sh` script used to hook the dinit user instance from PAM is also kept here.

## Controlling User Services
The `dinitctl` program is installed to `/sbin/dinitctl` by default. A link in the user's path can be added to allow users easy access to dinitctl for controlling user daemons. E.g: `cd /usr/local/bin && ln -s /sbin/dinitctl ./dinitctl`.

The provided script called `dinit-user.sh` is used to start and shutdown the user instance of dinit from the PAM stack. It can be hooked from pam using the `pam_exec.so` module.

E.g 1: For console logins, add the following line to `/etc/pam.d/login`, right before `pam_elogind.so` is started:
`-session        optional        pam_exec.so /etc/dinit.d/scripts/dinit-user.sh`

E.g 2: For GDM logins, add the following line to `/etc/pam.d/gdm-password`, right before `pam_elogind.so` is started:
`-session optional       pam_exec.so /etc/dinit.d/scripts/dinit-user.sh`

The same line can also be used in `sddm` to used dinit user services from that display manager.
