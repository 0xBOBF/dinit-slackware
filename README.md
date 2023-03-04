# Slackware Dinit Project

Dinit is a service manager that can be used for user or system services.

This project is an attempt at utilizing Dinit in Slackware 15.0 and later versions. 

The approach is split into two stages:

1. Incorporate Dinit as a user service manager

2. Incorporate Dinit as a system service manager, enabling it to act as an init system.

Further details of these stages is below.

## Dinit User Service Manager

Dinit can stop/start/restart user owned services, and can be operated by the user. This provides a convenience for user's wanting better control over their services that otherwise would be starting via autostart scripts and otherwise provide little interaction.

Many user services on Linux utilize the user session DBus so it needs to be one of the first services brought up. Futhermore, the `DBUS_SESSION_BUS_ADDRESS` variable is utilized by many programs, including user launched programs at runtime. Therefore we need to propegate this to the environment properly. A method for doing this already exists in the (e)logind pam module code, as long as the user DBus is found at `$XDG_RUNTIME_DIR/bus`, it will be properly set. Therefore the optimal place to startup the Dinit user service manager is in the PAM stack, prior to running the `pam_elogind.so` module.

With the above information in mind, this stage will require setting up an activation call of Dinit during the user login stages of the PAM stack, and then creating appropriate service definitions for services that users need, e.g. DBus, Pipewire, Keyring, etc.

## Dinit System Service Manager

At the present moment, Slackware's system services are defined and started via the /etc/rc.d/* scripts. 

To generate equivalent Dinit service defninitions will require converting these separate scripts, a single service per script, and creating compatible Dinit service definitions. Simpler service scripts could probably just be converted to equivalent service, e.g. those that are just scripted to provide start/stop syntax and dont use any other logic can immediately be replaced by a Dinit service, since the manage provides the start/stop interface. Services that have more scripted logic can just be extracted and dinit can be instructed to run said scripts when starting/stopping the service in the service definition file.

This project will take longer to get to a useable state, due to the length of rc.S and rc.M that needs to be sliced up into compatible services. Testing wont be possible to accomplish until enough services are converted over to bring the system up to a useable state.

Once all services are converted over, the kernel can be instructed to use dinit as the init program on the kernel command line and boot testing can commence. If a more permanent switch over is wanted, then the /sbin/init program can be moved over and dinit symlinked in its place.

