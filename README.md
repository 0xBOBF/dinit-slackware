# Slackware Dinit Project

Dinit is a service manager that can be used for user or system services.

This project is an attempt at utilizing Dinit in Slackware 15.0 and later versions. 

The approach is split into two stages:

1. Incorporate Dinit as a user service manager

2. Incorporate Dinit as a system service manager, enabling it to act as an init system.

Further details of these stages is below.

## Dinit User Service Manager

Dinit can stop/start/restart user owned services, and can be operated by the user. This provides a convenience for user's wanting better control over their services that otherwise would be starting via autostart scripts and otherwise provide little interaction.

Many user services on Linux utilize the user session DBus so it needs to be one of the first services brought up. Furthermore, the `DBUS_SESSION_BUS_ADDRESS` variable is utilized by many programs, including user launched programs at runtime. Therefore we need to propagate this to the environment properly. A method for doing this already exists in the (e)logind pam module code, as long as the user DBus is found at `$XDG_RUNTIME_DIR/bus`, it will be properly set. Therefore the optimal place to startup the Dinit user service manager is in the PAM stack, prior to running the `pam_elogind.so` module.

With the above information in mind, this stage will require setting up an activation call of Dinit during the user login stages of the PAM stack, and then creating appropriate service definitions for services that users need, e.g. DBus, Pipewire, Keyring, etc.

## Dinit System Service Manager

At the present moment, Slackware's system services are defined and started via the /etc/rc.d/* scripts. 

To generate equivalent Dinit service definitions will require converting these into separate single service scripts, and then creating compatible Dinit service definitions. 

Simpler service scripts can just be converted to an equivalent Dinit service definition, i.e. those that are just scripted to provide start/stop syntax and don't use any other logic can immediately be replaced by a Dinit service, since the Dinit service manager provides the start/stop interface. Services that have more scripted logic will need to be extracted and dinit can be instructed to run the required scripts when starting/stopping the service from the service definition file.

This project will take longer to get to a usable state, due to the length of rc.S and rc.M that needs to be sliced up into compatible services. Testing wont be possible to accomplish until enough services are converted over to bring the system up to a usable state.

Once all services are converted over, the kernel can be instructed to use dinit as the init program on the kernel command line and boot testing can commence. If a more permanent switch over is wanted, then the old /sbin/init program can be moved over to a new name, and dinit symlinked in its place.

