#!/bin/bash
source ./xmlfunctions.sh
source ./hardenauditfunctions.sh

if [ -e /usr/sbin/userhelper ]; then
	fperms=$(find /usr/sbin/userhelper -maxdepth 0 -type f -printf "%m");
	echo ${fperms};
fi
