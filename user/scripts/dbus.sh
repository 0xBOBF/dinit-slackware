#!/bin/sh

# Note: Running prior to elogind means no XDG_* variables are set.
# Set the session dbus address the logind expects manually. Using this
# address ensures that elogind propegates this into the user's env.
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Export the address for other dinit services, since they do not inherit
# environment from elogind.
dinitctl setenv DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS

exec dbus-daemon --session --address="$DBUS_SESSION_BUS_ADDRESS" "$@"
