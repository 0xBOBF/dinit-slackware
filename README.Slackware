# Overview:

Using dinit as init conflicts with Slackware's sysvinit package, and 
it's included init and shutdown programs. The sysvinit package should 
be removed if intending to use dinit as init. Steps on how to switch 
init systems are shown below.

# Switching to dinit as init:

Assuming you are using the stock sysvinit based init system in Slackware, the
following steps will switch the system to using dinit as init. All steps are
to be completed as root:

1. Install the dinit Slackware package
2. Edit your bootloader to append the command line option:

   init=/sbin/dinit-system.wrap

   This can also be appended manually on the kernel command line, but editing
   the default lilo or grub config will be best for switching to dinit as init.

3. Reboot the system using the edited kernel command line to boot using dinit.

4. Remove the sysvinit package (this is in order to remove /sbin/shutdown and 
   related symlinks, so that we can set up dinit's versions of these files).

   E.g. On Slackware-current:

   removepkg sysvinit-3.10-x86_64-1

5. Run the dinit symlink convenience script to setup the shutdown/reboot/poweroff
   symlinks:

   /sbin/dinit-init.sh enable

From this point forward your machine is set up to boot/reboot/poweroff using dinit
as the main init process.

# Switching to sysvinit as init:

Assuming you are using dinit as installed above, the following steps will revert the 
system to using sysvinit as init. Note: You will need a copy of the sysvinit Slackware
package from a Slackware mirror, install DVD/iso, or online mirror.

1. Run the dinit symlink convenience script to remove the dinit symlinks:

   /sbin/dinit-init.sh disable

2. Install the sysvinit Slackware package back onto the system:

   E.g. On Slackware-current:

   installpkg sysvinit-3.10-x86_64-1.txz

3. Edit your bootloader to remove 'init=/sbin/dinit-system.wrap' from the kernel
   command line options.

4. Force a shutdown with the dinit-shutdown program, since dinit is still the running
   init process. Note that the --system option is used, otherwise dinit-shutdown will
   attempt to run /sbin/shutdown from the freshly installed sysvinit package, which will
   cause the kernel to panic on reboot/shutdown/poweroff.

   /sbin/dinit-shutdown --system

   This is a non-recommended way to shutdown dinit, but is the only way to shutdown 
   without panicking, as far as my testing can tell.

5. Power up the system and it will boot up with sysvinit.

