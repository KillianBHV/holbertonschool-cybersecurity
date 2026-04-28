#!/bin/bash

# System Hardening
# [IMPORTANT] No interactive actions, no human must be required

source logging.sh

# H-01) Packages up-to-date
if apt-get update >/dev/null 2>&1 && apt-get upgrade -y >/dev/null 2>&1; then
	log "SUCCESS" "Package updates and upgrades completed."
	audit "INFO" "Package updates OK."	
else
	log "ERROR" "Update or upgrade: something's unexcepted occured!"
	log "STOP" "For safety, exit toolkit. You can try to reload it."
	
	audit "ERROR" "Updates failed!"
	exit
fi

# H-02) Uninstall bloatwares
### Checks if packets are already installed
for p in $TOOLS_REMOVED; do
	if dpkg -s $p >/dev/null 2>&1 && apt-get remove -y $p >/dev/null 2>&1; then
		log "SUCCESS" "$p has been removed."
	else
		log "INFO" "$p is not installed, no need to remove it."
	fi
	audit "INFO" "$p removed successfully or already removed."
done

# H-03) Install required tools
for p in $TOOLS_INSTALL; do
	if apt-get install -y $p >/dev/null 2>&1; then
		log "SUCCESS" "$p installed successfully or already installed."
		audit "INFO" "$p installed successfully or already installed."
	else
		log "ERROR" "An error occured during installation of $p!"
		log "STOP" "For safety, exit toolkit. You can try to reload it."

		audit "ERROR" "$p installation failed!"
		exit
	fi
done

### [INFO] In real environment, you can also control no longer required packages
