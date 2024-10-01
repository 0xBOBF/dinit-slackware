# Dinit Services for Slackware
This project's goal is to create dinit services for use on Slackware Linux. This includes both system services and user services.

Disclaimer: This project builds a dinit package configured with services tailor made for the author's system. This project is published as an example of one way to use dinit on a Slackware based system. This is not intended to be used by anyone else except the author. You are on your own if you choose to build and use this package since the author has limited time to support the project. You should also thoroughly know your init system and dinit if you choose to experiment with this, as there is a high chance you may need to fix a broken boot.

## Dinit System Services
System services managed by dinit are those that are traditionally found in the `/etc/rc.d/` directory on Slackware Linux. Equivalent dinit services are installed at `/etc/dinit.d/system/`. 

Not all services present in Slackware's `/etc/rc.d/` directory are converted to an equivalent dinit service yet. The list of services remaining to convert are listed in the TODO file of the git repository.

The system services can be used to boot the system with dinit running as init (pid 1). See the 'README.Slackware' file for further details and the steps required to use dinit as init.

## Dinit User Services
User services managed by dinit are things like a dbus session, pipewire, wireplumber, etc. These services are installed to `/etc/dinit.d/user/` so that all users can control the same services/daemons.

## Dinit Scripts
Support scripts are installed to `/etc/dinit.d/scripts/`. These scripts are either "oneshot" style service scripts used by dinit's system or user instance. The `dinit-user.sh` script used to hook the dinit user instance from PAM is also kept here.

## Controlling System and User Services
The `dinitctl` program is installed to `/sbin/dinitctl` by default, and symlinked to `/usr/bin/dinitctl` so regular users have the program in their path as well.

System services are managed by invoking `dinitctl` as the root user, while user services are managed when a user invokes `dinitctl`.

The provided script called `/etc/dinit.d/scripts/dinit-user.sh` can be used to start and stop the user instance of dinit from the PAM stack by being hooked from pam using the `pam_exec.so` module.

E.g 1: For console logins, add the following line to `/etc/pam.d/login`, right before `pam_elogind.so` is started:
```
-session        optional        pam_exec.so /etc/dinit.d/scripts/dinit-user.sh
```

E.g 2: For GDM logins, add the following line to `/etc/pam.d/gdm-password`, right before `pam_elogind.so` is started:
```
-session optional       pam_exec.so /etc/dinit.d/scripts/dinit-user.sh
```

The same line can also be used in `sddm` to used dinit user services from that display manager.

Consult the dinit documentation for further details on usage of dinitctl and dinit service management.
