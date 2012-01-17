#!/bin/bash
source ./xmlfunctions.sh
source ./hardenauditfunctions.sh

echo "<items>" >> report.xml;

################################################################################
# Linux Security Audit Script
################################################################################

################################################################################
# Main Script Body
################################################################################

################################################################################
# Section 1
################################################################################
section "Section 1: General principals." "No active checks neccessary.";

################################################################################
# Section 2
################################################################################
section "Section 2 - System Wide Confugration";
section "2.1. Installing and Maintaining Software"; 
section "2.1.1. Initial Installation Recommendations";

title="2.1.1.1.1. Create Separate Partition or Logical Volume for /tmp";
msg="A separate partition or logical volume does not exist for /tmp";
rec="Create a separate logical volume of 10GB and mount it on /tmp";
	
tmpmount=$(mount | awk 'BEGIN { c = 0 } $3 ~ /^\/tmp$/ { c ++ } END { print c }');
if [ $tmpmount -lt 1 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset tmpmount;
################################################################################
title="2.1.1.1.2. Create separate partition or logical volume for /var";
msg="A separate partition or logical volume does not exist for /var";
rec="Create a separate logical volume of 10GB and mount it on /var";
varmount=$(mount | awk 'BEGIN { c = 0 } $3 ~ /^\/var$/ { c ++ } END { print c }');
if [ $varmount -lt 1 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset varmount;
################################################################################
title="2.1.1.1.3. Create separate partition or logical volume for /var/log";
msg="A separate partition or logical volume does not exist for /var/log";
rec="Create a separate logical volume of size large enough for all logs
and mount it on /var/log";
logmount=$(mount | awk 'BEGIN { c = 0 } $3 ~ /^\/var\/log$/ { c ++ } END { print c }');
if [ $logmount -lt 1 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset logmount;
################################################################################
title="2.1.1.1.4. Create separate partition or logical volume for /var/log/audit";
msg="A separate partition or logical volume does not exist for	/var/log/audit";
rec="Create a sperate logical volume of size large	enough for all audit logs
and mount in on /var/log/audit.";
auditmount=$(mount | awk 'BEGIN { c = 0 } $3 ~ /^\/var\/log\/audit$/ { c ++ } END { print c }');
if [ $auditmount -lt 1 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset auditmount;
################################################################################
title="2.1.1.1.5. Create a separate partition or logical volume for /home if using local home directories.";
msg="A separate partition or logical volume does not exist for /home";
rec="Create a sperate logical volume of size large	enough for all local user
home directories and mount it on /home.";
homemount=$(mount | awk 'BEGIN { c = 0 } $3 ~ /^\/home$/ { c ++ } END { print c }');
if [ $homemount -lt 1 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
c=0;
title="2.1.1.2. Boot loader configuration / boot loader password";
msg="A grub boot loader password has not been configured.";  
rec="This is not a problem really as boot loader passwords can only be entered in at the console and can be avoided via the rescue CD.";
if [ -e /etc/grub.conf ]; then
	c=$(grep password /etc/grub.conf | wc -l);
elif [ -e /boot/grub/grub.conf ]; then
	c=$(grep password /boot/grub/grub.conf | wc -l);
else
	msg="No grub.conf found in either /etc/grub.conf or /boot/grub/grub.conf.  This can happen if the system has been upgraded to grub2";
	type="low";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
if [ $c = 0 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.1.1.3. Network devices";
text="There are no security checks in this section.  Check DHCP configuration.
It is covered in a later section of this report.";
section "${title}" "${text}";
################################################################################
title="2.1.1.4. Root password";
text="The root password can not be audited as it is not known.  User password security
is covered later in this document. The root password should be at least 
12 chars long and contain a mix of upper and lower case chars, numerical numbers
and special characters.";
section "${title}" "${text}";
################################################################################
title="2.1.1.5. Software packages";
text="This section deals with configuration applied during initial installation.
It does not apply to this audit.  Existing services and daemons are covered
later in this report.";
section "${title}" "${text}";
################################################################################
title="2.1.1.6. First boot configuration";
text="This section deals with configuration applid during initial installation.
It does not apply to this audit.";
section "${title}" "${text}";
################################################################################
title="2.1.2. Updating software";
text="This entire section is covered by standard patching procedures.  There
are no active checks that can be made on the system.  There are many different
ways to configure patching and this tool can not cover them all.";
section "${title}" "${text}";
################################################################################
title="2.1.3. Software integrity checking";
text="This tool does not test for the presence of softare integrity checking
tools. There are many different tools available and these should be considered
on a case by case basis.";
section "${title}" "${text}";
################################################################################
# Section 2.2 - File Permissions and Masks
################################################################################
section "2.2. File permissions and masks";
section "2.2.1. Restrict partition mount options";
################################################################################
title="2.2.1.1. Add nodev option to non-root local partitions";
msg="There are mounted partitions or logical volumes without the 'nodev' mount option.";
c=$(awk 'BEGIN { c = 0 } $3 ~ /^ext[234]$/ && $2 !~ /^\/$/ && $4 !~ /nodev/ { c++ } END { print c }' /etc/fstab);
if [ $c -gt 0 ]; then
	rec="Add the nodev option to the comma separated mount options on the locally
partitions in /etc/fstab.  These are usually those with filetype=ext2,ext3 or ext4.
a list of affected partitions found by this check follows:";
	type="med";
	cmd () { awk '($3 ~ /^ext[234]$/ && $2 !~ /^\/$/ && $4 !~ /nodev/) { printf "Line:%d,%s %s %s %s %s %s\n",FNR,$1,$2,$3,$4,$5,$6 }' /etc/fstab; }
	lines=$(cmd);
	rec=$(echo "${rec}
${lines}");
	xmlitem "${title}" ${type} "${msg}" "${rec}";
	unset cmd;
	unset lines;
else
	rec="It is recommended that the 'nodev' option is applied to local partition
mounts in /etc/fstab.";
	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
################################################################################
title="2.2.1.2 and 2.2.1.3. nodev, nosuid, noexec options to partitions in /etc/fstab/";
lines=$(awk '$2 ~/cdrom|floppy|usb|tmp|\/dev\/shm/ { printf "Line:%d,%s %s %s %s %s %s\n",FNR,$1,$2,$3,$4,$5,$6 }' /etc/fstab);
msg="Local partitions are not mounted securly: nodev,nosuid & noexec";
if [ $(grep -c 'cdrom\|floppy\|usb\|tmp\|\/dev\/shm' /etc/fstab) -gt 0 ]; then
	rec="/etc/fstab should be configured such that removable storage partitions,
temp and /tmp/shm should be mounted with the nodev,noexec and nosuid mount options.";
	msg="There are local partitions mounted without the security of nodev,nosuid 
and noexec.";
	type="med";
	output=""
	echo "$lines" | while read line
		do
		options=$(echo $line | awk '{ print $4 }');
		nodev_exists=$(echo "$options" | grep -c nodev);
		noexec_exists=$(echo "$options" | grep -c noexec);
		nosuid_exists=$(echo "$options" | grep -c nosuid);

		append=$options;

		if [ $nodev_exists = 0 ]; then
			append="$append,nodev";
		fi
		if [ $noexec_exists = 0 ]; then
			append="$append,noexec";
		fi
		if [ $nosuid_exists = 0 ]; then
			append="$append,nosuid";
		fi
		output=$(echo "${output}
Recommend that you change the the options in:
${line}");
		output=$(echo "${output}${options} ==> ${append}");
	done
	xmlitem "${title}" "${type}" "${msg}" "${rec}" "${output}";
	unset output;
else
	rec="no cdrom, floppy, usb, /tmp or /dev/shm in /etc/fstab";
	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
################################################################################
title="2.2.1.4. Bind-mount /var/tmp to /tmp";
msg="/tmp is not bind mounted to /var/tmp";
rec="Edit the file /etc/fstab. Add the following line:
/tmp	/var/tmp	none	rw,noexec,nosuid,nodev,bind	0 0
This line will bind-mount the world-writeable /var/tmp directory onto /tmp,
using the restrictive mount options specified. See the mount(8) man page for
further explanation of bind mounting";
c=$(awk 'BEGIN { c=0 } ($1 ~ /^\/tmp$/ && $2 ~ /^\/var\/tmp$/ && $4 ~ /rw,noexec,nosuid,nodev,bind/) { c++ } END { print c }' /etc/fstab);
if [ $c -eq 0 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.2.2. Restrict Dynamic Mounting and Unmounting of Filesystems" \
"Restrict Console Device Access
Console device access for non root users is required on most systems that
employ sudo for root escalation.  Should console access be required the
attending technician will most likely be required to log in with their
own user account and escalate to root when required using the sudo facility.
--- No checks made.";
################################################################################
section "2.2.2. Disable USB Device Support." \
"USB Device support is sometimes required for remedial activities.  Should it
be required in the event of emergency it makes sense for the system to
support it.  Any delay to restoration of service would be unacceptable in a
production environment.
However!  In some cases USB Support might be deemed too much of a security
risk and can be disabled.  A common middle ground is to disable automatic
loading of usb drivers but to allow administrators to load them manually if
and when required.";
################################################################################
title="2.2.2. Disable Modprobe Loading of USB Storage Driver";
msg="Automatic USB Storage driver loading is currently enabled.";
rec="If automatic USB Storage support is not required then it's best to disalbe 
it.
Append the line, \"install usb-storage /bin/true\" to /etc/modprobe.conf";
if [ -e /etc/modprobe.conf ]; then
	c=$(grep -c "install usb-storage /bin/true" /etc/modprobe.conf);
	if [ $c -eq 0 ]; then
		type="low";
	else
		type="pass";
	fi
else
	msg="File /etc/modprobe.conf does not exist";
	type="low";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.2.2.2.2. Remove USB Storage Driver" \
"Not checked.  USB Storage might be required for remedial activities in an
emergency.  Auto loading of USB devices should be disabled.";
################################################################################
section "2.2.2.2.3. Disable Kernel Support for USB via Bootloader Configuration." \
"Not checked.  Removing all USB support with the 'nousb' kernel parameter
will also disable usb keyboard and usb mouse support at the console.";
################################################################################
title="2.2.2.3. Disable the Automounter if Possible";
msg="autofs is enabled."
rec="autofs should be disabled if it's not required.  NFS Mounts can be done
manually in /etc/fstab
Issue the following command to turn autofs off:
# chkconfig autofs off";
c=$(/sbin/chkconfig --list autofs | grep -c on);
if [ $c -gt 0 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.2.2.4. Disable GNOME Automounting if Possible" \
"Disabling automounting of CDROM and USB media on a server located in a
secure datacentre facility serves little purpose in terms of security.
GNOME Automount is not checked by this tool.
This is currently not tested by this tool.";
################################################################################
section "2.2.2.5. Disable Mounting of Uncommon Filesystem Types." \
"Append the following lines to /etc/modprobe.conf in order to prevent the usage
of uncommon filesystem types:
	install	cramfs		/bin/true
	install	freevxfs	/bin/true
	install	jffs2		/bin/true
	install	hfs		/bin/true
	install	hfsplus		/bin/true
	install	squashfs	/bin/true
	install	udf		/bin/true";
################################################################################
# FILE PERMISSIONS
################################################################################
section "2.2.3. File Permissions";
title="2.2.3.1. Verify Permissions on /etc/passwd";
msg="/etc/passwd has the incorrect permissions configured.";
rec="Set the permissions of /etc/passwd to -rw-r--r-- by executing the following command:
#chmod 0644 /etc/passwd";
r=$(checkPermission /etc/passwd -rw-r--r--);
if [ $r = 0 ]; then
	rec="${rec}
Current permission set: $(ls -l /etc/passwd | awk '{ print $1 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Permissions on /etc/group";
msg="/etc/group has the incorrect permissions configured.";
rec="Set the permissions of /etc/group to -rw-r--r-- by executing the following command:
# chmod 0644 /etc/group";
r=$(checkPermission /etc/group -rw-r--r--);
if [ $r = 0 ]; then
	rec="${rec}
Current permission set: $(ls -l /etc/group | awk '{ print $1 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Permissions on /etc/shadow";
msg="/etc/shadow has incorrect permissions";
rec="Set the permissions of /etc/shadow to -r-------- by executing the following command:
#chmod 0400 /etc/shadow";
r=$(checkPermission /etc/shadow -r-------- );
if [ $r = 0 ]; then
	rec="${rec}
Current permission set: $(ls -l /etc/shadow | awk '{ print $1 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Permissions on /etc/gshadow";
msg="/etc/gshadow has incorrect permissions";
rec="Set the permissions of /etc/gshadow to -r-------- by executing the following command:
#chmod 0400 /etc/gshadow";
r=$(checkPermission /etc/gshadow -r-------- );
if [ $r = 0 ]; then
	rec="${rec}
Current permission set: $(ls -l /etc/gshadow | awk '{ print $1 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Owners on /etc/passwd";
msg="The owner:group configured for /etc/passwd is incorrect.";
rec="Set the owner:group of /etc/passwd to root:root by executing the following command:
#chown root:root /etc/passwd";
r=$(checkOwner /etc/passwd root:root);
if [ $r = 0 ]; then
	rec="${rec}
Current owner:group set: $(ls -l /etc/passwd | awk '{ print $3\":\"$4 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Owners on /etc/group";
msg="The owner:group configured for /etc/group is incorrect.";
rec="Set the owner:group of /etc/group to root:root by executing the following command:
#chown root:root /etc/group";
r=$(checkOwner /etc/group root:root);
if [ $r = 0 ]; then
	rec="${rec}
Current owner:group set: $(ls -l /etc/group | awk '{ print $3\":\"$4 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Owners on /etc/shadow";
msg="The owner:group configured for /etc/shadow is incorrect.";
rec="Set the owner:group of /etc/shadow to root:root by executing the following command:
#chown root:root /etc/shadow";
r=$(checkOwner /etc/shadow root:root);
if [ $r = 0 ]; then
	rec="${rec}
Current owner:group set: $(ls -l /etc/shadow | awk '{ print $3\":\"$4 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.1. Verify Owners on /etc/gshadow";
msg="The owner:group configured for /etc/gshadow is incorrect.";
rec="Set the owner:group of /etc/gshadow to root:root by executing the following command:
#chown root:root /etc/gshadow";
r=$(checkOwner /etc/gshadow root:root);
if [ $r = 0 ]; then
	rec="${rec}
Current owner:group set: $(ls -l /etc/gshadow | awk '{ print $3\":\"$4 }')";
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
## This is a tricky one.  Here is what it does:
## 1. Find mount points of all local partitions by checking /etc/fstab for /ext[23]/
## 2. execute a find command on each mount point found checking for the absence of 
##    a sticky bit on world writable directories.  discard errors to cope with .gvfs
##    (fuse) mount point on newer systems.  We don't care about them anyway.
## 3. use the function described above to populate a variable with the data
## 4. count the result.
## 5. test the count and do the usual.
## PLEASE SOMEONE FIND A BETTER WAY TO DO THIS.

title="2.2.3.2. Verify that all World-Writable Directories Have Sticky Bit Set.";
msg="There are directories that do not have the sticky bit set.  Any user on the
system can delete any file created by other users in these directories.";
rec="Evaluate the requirement for these world writable directories and if they
are required then set the sticky bit on them by issuing the following command:
# chmod +t [dirname]";
cmd() {
	for p in $(awk '($3 ~ /ext[234]/) { print $2 }' /etc/fstab); do
		find ${p} -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print 2> /dev/null
	done;
}
files=$(cmd);
fcount=$(echo $files | grep -v "^$" | wc -l);
if [ $fcount -gt 0 ]; then
	rec="${rec}
Here follows a list of directories that are world writable but do not have the
sticky bit set:
${files}";
	type="med";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset cmd;
unset files;
unset fcount;
################################################################################
title="2.2.3.3. Find unauthorized World-Writable Files.";
msg="There are world-writable files.  Any user on the system can delete any
world-writable files created by other users.";
rec="Evaluate the requirement for these world writable files and if they are not
required then set them owner/group writable only by issuing the following
command:
# chmod o-w [filename]";
cmd() {
	for p in $(awk '($3 ~ /ext[234]/) { print $2 }' /etc/fstab); do
		find ${p} -xdev -type f -perm -0002 -print 2> /dev/null
	done;
}
files=$(cmd);
fcount=$(echo $files | grep -v "^$" | wc -l);
if [ $fcount -gt 0 ]; then
	rec="${rec}
Here follows a list of world-writable files.
${files}";
	type="low";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
else
 	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
unset cmd;
unset files;
unset fcount;
################################################################################
title="2.2.3.4. Find unauthorised SUID/SGID system executables.";
msg="There are executables with the SUID or SGID bits set.";
rec="Executables with SUID or SGID bits set can be executed by unauthorised
users. Unfortunately there is no automated way of dealing with this.  Each
executable found here needs to be evaluate the following files and if their 
SUID / SGID bits do not need to be set then unset them by issueing the following
command:
# chmod -s [filename]";
cmd() {
	for p in $(awk '($3 ~ /ext[234]/) { print $2 }' /etc/fstab); do
		find ${p} -xdev \( -perm 4000 -o -perm -2000 \) -type f -print 2> /dev/null
	done;
}
files=$(cmd);
fcount=$(echo $files | grep -v "^$" | wc -l);
if [ $fcount -gt 0 ]; then
	type="low";
	rec=$(echo "${rec}
${files}");
	xmlitem "${title}" ${type} "${msg}" "${rec}";
else
 	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
unset cmd;
unset files;
unset fcount;
################################################################################
title="2.2.3.5. Find Unowned Files";
msg="There were unowned files.";
rec="Unowned files are not directly exploitable, but they are generally a sign 
that something is wrong with some system process. They may be caused by an 
intruder, by incorrect software installation or incomplete software removal, or 
by failure to remove all files belonging to a deleted account. The files should 
be repaired so that they will not cause problems when accounts are created in 
the future, and the problem which led to unowned files should be discovered and 
addressed.";
cmd() {
	for p in $(awk '($3 ~ /ext[234]/) { print $2 }' /etc/fstab); do
		find ${p} -xdev \( -nouser -o -nogroup \) -print 2> /dev/null
	done;
}
files=$(cmd);
fcount=$(echo $files | grep -v "^$" | wc -l);
if [ $fcount -gt 0 ]; then
	type="low";
		rec=$(echo "${rec}
${files}");
	xmlitem "${title}" ${type} "${msg}" "${rec}";
else
 	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
unset cmd;
unset files;
unset fcount;
################################################################################
title="2.2.3.6. Verify all World-Writable directories have proper ownership";
msg="There are world-writable directories without proper ownership.";
rec="Allowing a user account to own a world-writable directory is undesirable 
because it allows the owner of that directory to remove or replace any files 
that may be placed in the directory by other users.";
cmd() {
	for p in $(awk '($3 ~ /ext[234]/) { print $2 }' /etc/fstab); do
		find ${p} -xdev -type d -perm -0002 -uid +500 -print 2> /dev/null
	done;
}
files=$(cmd);
fcount=$(echo $files | grep -v "^$" | wc -l);
if [ $fcount -gt 0 ]; then
	type="low";
		rec=$(echo "${rec}
${files}");
	xmlitem "${title}" ${type} "${msg}" "${rec}";
else
 	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
unset cmd;
unset files;
unset fcount;
################################################################################
# RESTRICT PROGRAMS FROM DANGEROUS EXECUTION PATTERNS
################################################################################
section "2.2.4. Restrict Programs from Dangerous Execution Patterns";
################################################################################
title="2.2.4.1. Set Daemon umask";
msg="The init daemon runs with an insecure umask.";
rec="The daemon UMASK should be set to 027 to protect files including temporary 
files and log files from unauthorized reading by unprivileged users on the 
system. Append the following to /etc/sysconfig/init:
umask 027";
if [ -e /etc/sysconfig/init ]; then
c=$(grep -c "umask 027" /etc/sysconfig/init);
if [ $c = 0 ]; then
	type="med";
else
	type="pass";
fi
else
	msg="Could not find file /etc/sysconfig/init.  Is this a Redhat system?"
	type="medium";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.4.2. Disable Core Dumps";
msg="Core dumps are enabled.";
rec="Only developers under specific circumstances require core dumps.  Core 
dumps may contain sensitive information and should be disabled by default.";
if [ -e /etc/security/limits.conf ]; then
	c=$(grep -c -e "\*.*hard.*core.*0$" /etc/security/limits.conf);
	if [ $c = 0 ]; then
	type="low";
else
	type="pass";
fi
else
	msg="Could not find /etc/security/limits.conf";
	type="low";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.3.2.1. Ensure SUID Dumps are Disabled";
msg="SUID Dumps are enabled";
rec="SUID Dumps allow SUID executables to ouptut core dump information which may
contain sensitive data.";
c=$(grep -c "0" /proc/sys/fs/suid_dumpable);
if [ $c = 0 ]; then
	type="pass";
else
	type="low";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.4.3. Enable ExecShield";
msg="ExecShield is disabled and/or randomize_va_space is turned off."
rec="The ExecShield offeres systems that support it the ability to randomly 
place application code into a randmon section of memory.  This prevents exploits 
that relay on application code to reside in predictable address spaces.
Enable Exec Shield by issuing the following commands:
# sysctl -w kernel.exec-shield=1
# sysctl -w kernel.randomize_va_space=1";
rs_count=0;
if [ -e /proc/sys/kernel/exec-shield ]; then
	c=$(grep -c "0" /proc/sys/kernel/exec-shield);
	rs_count=$(($rs_count + $c));
fi
if [ -e /proc/sys/kernel/randomize_va_space ]; then
	c=$(grep -c "0" /proc/sys/kernel/randomize_va_space);
	rs_count=$(($rs_count + $c));
fi
if [ $rs_count = 0 ]; then
	type="pass";
else
	type="med";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset rs_count;
################################################################################
title="2.2.4.4. Enable NX or XD Support";
msg="This system is a 32bit system and the PAE kernel is not installed.";
rec="This is a feature that is enabled in the bios.  If enabled, it is used by 
default in 64bit systems and 32bit systems running the PAE kernel.  Install the 
32bit Kernel-PAE packages to ensure that Execute Disable (XD) or 
No Execute (NX) are supported.";
# check for 64 bit kernel.
c=$(uname -r | grep -c 64);
if [ $c = 0 ]; then
	# check for PAE kernel installed
	c=$(uname -r | grep -c "PAE");
	if [ $c = 0 ]; then
		type="low";
	else
		type="pass";
	fi
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.2.4.5. Configure Prelink";
msg="Prelinking is enabled.";
rec="Prelinking decreases process startup time by loading shared libraries into 
and address for which the linking of needed symbols has already been performed.  
After a binary has been prelinked, the address at which shared libraries will be
loaded will no longer be random on a per process basis even if the 
kernel.randomize_va_space is set to 1.  This provides a stable address for an 
attacker to use during exploitation attempts. Disable prelinking by executing 
the following commands:
In /etc/sysconfig/prelink set PRELINK=no
# /usr/sbin/prelink -ua
to revert any prelinked binaries to their original content.";
# check for current prelink status.
c=$(grep -c "PRELINIKING=no" /etc/sysconfig/prelink);
if [ $c = 0 ]; then
	type="low";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3. Account and Access Control";
################################################################################
section "2.3.1. Protect Accounts by Restricting Password-Based Login";
################################################################################
title="2.3.1.1. Restrict Root Logins to System Console";
msg="Root logins are not restricted to console.";
rec="Root logins should only be allowed for emergencies.  As such root logins 
should only be allowed on the console. Under normal circumstances administrators
should log in with a normal unprivilaged account and then escalate to root via 
su - or sudo.
Edit the /etc/securetty file to ensure that only |console|, |tty[123456]|, 
|vc/[123456]| and if required |ttyS[01]| are listed.";
c=$(grep -v "^console$" /etc/securetty | grep -v "^tty[0-9]*$" | grep -v "^vc\/[0-9]*$" | grep -v "^ttyS[0-9]*$" | wc -l); 
if [ $c -gt 0 ]; then
	type="med";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.1.2. Limit su Access ot the Root Account";
msg="Non members of the wheel group are able to su - into root.";
wheelgroupmembers=$(grep ^wheel /etc/group | cut -f4);
rec="By convention the group <u>wheel</u> is used to define users who have 
permission to escalate to root. Ensure that members of the wheel group are 
authorised system admins and alter the following line in /etc/pam.d/su:
	auth	required	pam_wheel.so	use_uid
Wheel group members are:
${wheelgroupmembers}";
c=$(grep -c "^auth.*required.*pam_wheel\.so.*use_uid$" /etc/pam.d/su);
if [ $c = 0 ]; then
	type="med";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.1.3. Configure sudo to improve auditing of root access.";
msg="sudo is not configured to allow wheel group members to execute commands as
root.";
rec="Using sudo to allow members of the wheel group to execute privilleged
commands provides great flexibility and an audit trail BUT comes with a risk.
An attacker that has access to a wheel group member's password is able to
access commands as the root user.
use the [visudo] command to uncomment or add the following line in /etc/visudo:
	%wheel	ALL=(ALL)	ALL";
# test if wheel group has access to all commands in sudoers
c=$(grep "%wheel.*ALL=(ALL).*ALL" /etc/sudoers | grep -v NOPASSWD | grep -v "^#" | wc -l);
if [ $c = 0 ]; then
	# Wheel group is not defined correctly in /etc/sudoers
	type="med";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.1.4. Block shell and login access for non root system accounts.";
msg="Accounts exist with UID less than 500 with shell access.";
rec="Remove shell access from system accounts to make it more difficult for an 
attacker to use them.
For each identified system account SYSACCT, lock the account and disable the
shell:
# usermod -L SYSACCT - lock the account
# usermod -s /sbin/nologin SYSACCT";
accounts=$(awk -F: '$3 < 500 && $1 != "root" && $7 != "/sbin/nologin" { print $1 }' /etc/passwd);
if [ $(echo $accounts | wc -l) -gt 0 ]; then
	type="med";
	rec=$(echo "${rec}
${accounts}");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset accounts;
################################################################################
section "2.3.1.5. Verify proper storage and existence of password hashes.";
################################################################################
title="2.3.1.5.1. Verify that no accounts have empty password fields.";
msg="Accounts with empty password fields exist.";
rec="For each account identified, either lock the account or set a password.
An account without a password can be accessed by any user.";
accounts=$(awk -F: '$2 == "" { print }' /etc/shadow);
if [ $(echo "${accounts}" | grep -v "^$" | wc -l) -gt 0 ]; then
	type="high";
	rec=$(echo "${rec}
${accounts}");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset accounts;
################################################################################
title="2.3.1.5.2. Verify that All Account Password Hashes are Shadowed";
msg="There are accounts with password hashes not being shadowed.";
rec="Keeping password hashes in the non world readable shadow file keeps regular
users from viewing them.";
accounts=$(awk -F: '$2 != "x" {print }' /etc/passwd);
if [ $(echo $accounts | grep -v "^$" | wc -l) -gt 0 ]; then
	type="med"
		rec=$(echo "${rec}
${accounts}");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset accounts;
################################################################################
title="2.3.1.6. Verify that no non-root accounts have uid = 0";
msg="There are non root accounts with uid=0";
rec="Accounts with UID=0 other than root, may result in unexpected side effects
and are therefore not recommended.";
accounts=`awk -F: '$3 == "0" { print }' /etc/passwd`;
if [ $(echo $accounts | wc -l) -gt 1 ]; then
	type="med"
	rec=$(echo "${rec}
${accounts}");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset accounts;
################################################################################
title="2.3.1.7. Set password expiration parameters";
msg="Password expiry rules are not configured correctly.";
rec="Configure password expiry for each existing user set the current expiration 
settings:
# chage -M 90 -m 7 -W 7 USER
and configure the defaults in /etc/login.defs:";
pass_max_days=$(awk '($1 ~ /PASS_MAX_DAYS/) { print $2 }' /etc/login.defs);
pass_min_days=$(awk '($1 ~ /PASS_MIN_DAYS/) { print $2 }' /etc/login.defs);
pass_min_len=$(awk '($1 ~ /PASS_MIN_LEN/)   { print $2 }' /etc/login.defs);
pass_warn_age=$(awk '($1 ~ /PASS_WARN_AGE/) { print $2 }' /etc/login.defs);
append="";
if [ $pass_max_days != 90 ]; then
	append=$(echo "$append
PASS_MAX_DAYS = ${pass_max_days} = NOT OK");
fi
if [ $pass_min_days != 7 ]; then
	append=$(echo "$append
PASS_MIN_DAYS = ${pass_min_days} = NOT OK");
fi
if [ $pass_min_len != 14 ]; then
	append=$(echo "$append
PASS_MIN_LEN = ${pass_min_len} = NOT OK");
fi
if [ $pass_warn_age != 7 ]; then
	append=$(echo "$append
PASS_WARN_AGE = ${pass_warn_age} = NOT OK");
fi
c=$(echo "${append}" grep -v "^$" | wc -l);
if [ $c != 0 ]; then
	type="med";
	cmd="${append}";
	cmd=$(echo "${cmd}
Set them to this:");
	cmd=$(echo "${cmd}
PASS_MAX_DAYS 90
PASS_MIN_DAYS 7
PASS_MIN_LEN  8
PASS_WARN_AGE 7");
rec=$(echo "${rec}
${cmd}");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset cmd;
unset append;
unset pass_max_days;
unset pass_min_days;
unset pass_min_len;
unset pass_warn_age;
################################################################################
title="2.3.1.7.1. Remove password parameters from libuser.conf";
msg="/etc/libuser.conf contains password parameters that override those defined 
in /etc/login.defs";
rec="Edit /etc/libuser.conf so that it has a reference to login.defs in the 
[import] section as follows:
login_defs = /etc/login.defs
Also make sure that no lines begining with the following appear anywhere in the
[userdefaults] section:
LU_SHADOWMAX
LU_SHADOWMIN
LU_SHADOWWARNING
LU_UIDNUMBER
";
c=$(grep -c "login_defs = /etc/login.defs" /etc/libuser.conf);
if [ $c = 0 ]; then
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.1.8. Remove legacy '+' entries from password files";
msg="There are legacy + symbols in password files.";
rec="A '+' symbols in password files is a legacy reference to NIS logins.
Should NIS or LDAP logins be required the correct place to configure that is in
/etc/nsswitch.conf.  Using legacy '+' symbols in password files while NIS is
turned off might result in a user having access to the system with the
username = '+'";
c=$(grep -c "^+:" /etc/passwd);
d=$(grep -c "^+:" /etc/shadow);
e=$(grep -c "^+:" /etc/group);
f=$(($c + $d + $e));
if [ $f -gt 0 ]; then
	type="high";
	function cmd() { grep -c \"^+:\" /etc/passwd /etc/shadow /etc/group; }
	xmlitem "${title}" ${type} "${msg}" "${rec}" "${cmd}";
else
	type="pass";
	xmlitem "${title}" ${type} "${msg}" "${rec}";
fi
unset cmd;
unset d;
unset e;
unset f;
################################################################################
section "2.3.2. Use unix groups to enhance security" \
"This is standard operating procedure and should be covered by policy.
There is no real way to test for this. ideas are welcome.";
################################################################################
section "2.3.3. Protect accounts by configuring PAM" \
"PAM, or Pluggable Authentication Modules, is a system which implements modular
authentication for Linux programs. PAM is the framework which provides the 
system’s authentication architecture and can be configured to minimize your 
system’s exposure to unnecessary risk. This section contains guidance on how to 
accomplish that, and how to ensure that the modules used by your PAM 
configuration do what they are supposed to do. PAM is implemented as a set of 
shared objects which are loaded and invoked whenever an application wishes to 
authenticate a user. Typically, the application must be running as root in order 
to take advantage of PAM. Traditional privileged network listeners (e.g. sshd) 
or SUID programs (e.g. sudo) already meet this requirement. An SUID root 
application, userhelper, is provided so that programs which are not SUID or 
privileged themselves can still take advantage of PAM.
PAM looks in the directory /etc/pam.d for application-specific configuration 
information. For instance, if the program login attempts to authenticate a 
user, then PAM’s libraries follow the instructions in the file 
/etc/pam.d/login to determine what actions should be taken.
One very important file in /etc/pam.d is /etc/pam.d/system-auth. This file, 
which is included by many other PAM configuration files, defines “default” 
system authentication measures. Modifying this file is a good way to make 
far-reaching authentication changes, for instance when implementing a 
centralized authentication service.

Be careful when making changes to PAM’s configuration files. The syntax for 
these files is complex, and modifications can have unexpected consequences.
The default configurations shipped with applications should be sufficient 
for most users.

Running authconfig or system-config-authentication will re-write the PAM 
configuration files, destroying any manually made changes and replacing 
them with a series of system defaults.";
################################################################################
section "2.3.3.1. Set password quality requirements.";
################################################################################
append="";
theline="password	requisite	pam_cracklib.so try_first_pass retry=3";
title="2.3.3.1.1. Set password quality reqruirments if using pam_cracklib";
msg="Password complexity is not convigured in pam_cracklib correctly.";
rec="Add udcredit=-1 ucreadit=-1 lcredit=-1 minlen=8 to make passwords 
have at least one uppercase, one lowercase and one digit as well as be at least 
8 chars long to the end";
foo=$(awk '$1 ~ /password/ && $2 ~/requisite/ { print $1=$2="";print $0}' /etc/pam.d/system-auth | grep -v "^$" | sed 's/^ *//g');
if [ $(echo $foo | grep -c minlen) = 0 ]; then
	append=$(echo "$append
cracklib does not define minlen.  Add minlen=8 to the end of $theline");
fi
if [ $(echo $foo | grep -c dcredit) = 0 ]; then
	append=$(echo "$append
cracklib does not define dcredit. (at least one digit).  Add dcreadit=-1 to end of $theline");
fi
if [ $(echo $foo | grep -c lcreadit) = 0 ]; then
	append=$(echo "$append
cracklib does not define lcredit. (at least one lowercase). Add lcredit=-1 to end of $theline");
fi
if [ $(echo $foo | grep -c ucreadit) = 0 ]; then
	append=$(echo "$append
cracklib does not define ucredit. (at least one uppercase). Add ucredit=-1 to end of $theline");
fi
if [ $(echo $append | wc -l) -gt 0 ]; then
	type="high";
	rec=$(echo "${rec}
${append}");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset foo;
unset theline;
unset append;
################################################################################
title="2.3.3.2. Set lockouts for failed password attempts";
msg="PAM is not configured to lock users out after failed password attempts.";
rec="Configure account lockouts after failed password attempts by altering the 
following lines in /etc/pam.d/system-auth:
###
auth	sufficient	pam_unix.so nullok try_first_pass
###
	change to
###
auth	required	pam_unix.so nullok try_first_pass
###

then comment out or delete the following lines:

###
#auth	requisite	pam_succeed_if.so uid >= 500 quiet
#auth	required	pam_deny.so
###
then to force lockout, add the following to the individual programs' 
configuration files in /etc/pam.d.
First, add to end of the auth lines:
###
auth	required	pam_tally2.so deny=5 onerr=fail
###

Second, add to the end of the account lines:
###
account	required	pam_tally2.so
###
Locking out user accounts presents the risk of a denial-of-service attack. The 
security policy regarding system lockout must weigh whether the risk of such a 
denial-of-service attack outweighs the benefits of thwarting password guessing 
attacks. The pam tally2 utility can be run from a cron job on a hourly or daily 
basis to try and offset this risk.";
c=$(awk '$1 ~ /auth/ && $2 ~ /sufficient/ && $3 ~ /pam_unix.so/ { print }' /etc/pam.d/system-auth | grep "nullok try_first_pass" | grep -v ^# -c);
if [ $c -gt 0 ]; then
	type="high";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3.3.3. Use pam_deny.so to quickly deny access to a service." \
"In order to deny access to a service SVCNAME via PAM, edit the file 
/etc/pam.d/SVCNAME . Prepend this line to the beginning of the file:
###
auth	requisite	pam_deny.so
###";
################################################################################
title="2.3.3.4. Restrict execution of userhelper to console users.";
msg="The userhelper program can be executed by any user of the system.";
rec="Restrict execute access to the userhelper program to a group of human 
users. First alter the owner of /usr/sbin/userhelper to the group of human 
users:
#chgrp [usergroup] /usr/sbin/userhelper

Second alter the permissions so that only the user and owner (root) can execute 
the program:
#chmod 4710 /usr/sbin/userhelper";
if [ -e /usr/sbin/userhelper ]; then
	fperms=$(find /usr/sbin/userhelper -maxdepth 0 -type f -printf "%m");
	if [ ${fperms} -ne "4710" ]; then
		type="low";
		msg=$(echo "${msg}
current permissions = ${fperms}");
	else
		type="pass";
	fi
else
	msg="Could not find file '/usr/sbin/userhelper'";
	type="low";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.3.5. Upgrade password hashing algorythm to SHA-512";
msg="Password hash algorythm is out of date.";
rec="Change the password hashing algorythm to a more secure version.  Password
hashes will only be updated when users change their passwords.
Edit 3 files:

1: /etc/pam.d/system-auth
	password	sufficient	pam_unix.so sha512 shadow nullok try_first_pass use_authtok

2: /etc/login.defs
	MD5_CRYPT_ENAB no
	ENCRYPT_METHOD SHA512

3: /etc/libuser.conf
	crypt_style = sha512
";
if [ -e /etc/pam.d/system-auth ]; then
	pamenc=$(grep "password.*sufficient" /etc/pam.d/system-auth | grep -wo "md5\|sha256\|sha512");
	if [ ${pamenc} = "md5" ]; then
		type="med";
	else
		type="pass";
	fi
else
	pamenc="no /etc/pam.d/system-auth !  Are you using PAM";
	type = "high";
fi
if [ -e /etc/login.defs ]; then
	md5encryptenabled=$(grep "MD5_CRYPT_ENAB" /etc/login.defs | awk '{ print $2 }');
	if [ "${md5encryptenabled}" == "md5" ]; then
		type="med";
	else
		type="pass";
	fi
else
	encryptenabled="no /etc/login.defs !";
	type="high";
fi
if [ -e /etc/libuser.conf ]; then
	libuserenc=$(grep crypt_style /etc/libuser.conf | grep -wo "md5\|sha256\|sha512");
	if [ ${libuserenc} = "md5" ]; then
		type="med";
	else
		type="pass";
	fi
else
	libuserenc="no /etc/libuser.conf !";
	type="high";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
unset md5encryptenabled
unset encryptenabled
unset libuserenc
################################################################################
title="2.3.3.6. Limit password reuse";
msg="Passwords can be reused more frequently than once every 5 times.";
rec="Configure pam to remember passwords so that users can not reuse any of
their last 5 passwords:
edit /etc/pam.d/system-auth (append remember=5 to the password sufficient line)
	password sufficient pam_unix.so [existing options] remember=5";
c=$(grep "password.*sufficient" /etc/pam.d/system-auth | grep -c remember);
if [ $c = 0 ]; then
	type="med";
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.3.7. Remove the pam_ccreds package is possible.";
msg="The pam_ccreds package is installed.";
rec="The pam_ccreds package provides the setuid program and should be removed
unless it provides essential functionality.  It caches credentials so if the
cache were ever compromised it would present a major security risk.  Remove it
with:
yum erase pam_ccreds";
c=$(rpm -qa | grep -c pam_ccred);
if [ $c = 0 ]; then
	type="pass";
else
	type="high";
	msg=$(echo "${msg}
$(rpm -qa | grep pam_ccred)");
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3.4. Secure session configuration for login accounts.";
################################################################################
section "2.3.4.1. Ensure no dangerous directories exist in root's path." \
"Best practice is for sysadmins to execute applications by typing in the full
path to the executable.  Any strange directories in root's path could contain
executables installed by unpriviliged users and could be dangerous.
Interrogate root's path with
# echo \$PATH";
################################################################################
title="2.3.4.1.1. Ensure that root's path does not include relative paths or null directories.";
msg="Root's path contains relatives paths or null directories.";
rec="The following items in root's path are suspect and should be removed.";
type="pass";
IFS_OLD="${IFS}";
IFS=:
for v in $PATH; do
	if [ $(echo "${v}" | grep -c '\..*\|\.\..*') -gt 0 ]; then
		rec=$(echo "${rec}
$(echo "${v}" | grep '\..*\|\.\..*')");
		type="high";
	fi
done
IFS=${IFS_OLD};
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.4.1.2. Ensure root's path does not include world / group writable directories.";
msg="Root's path contains world writable directories.";
rec="Remove world and group writable permissions from directories in root's
path. Here follows the offending paths:";
type="pass";
IFS_OLD="${IFS}";
IFS=:
for v in $PATH
do
	if [ -d $v ]; then
		c=$(find ${v} -maxdepth 0 -type d -printf "%m %p\n" | awk '$1 > 755 { print }' | wc -l);
		if [ $c -gt 0 ]; then
			type="high";
			rec=$(echo "${rec}
$(find ${v} -maxdepth 0 -type d -printf "%m %p\n")");
		fi
	fi
done
IFS=${IFS_OLD};
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.4.2. User home direcotires must not be group / world writable.";
msg="User home directories are group / world writable.";
rec="Sometimes this is required so BE CAREFUL to solicit user input prior to
making this change. Change permissions on the following home dirs as follows:
# chmod g-w /path/to/home/[user]
# chmod o-rwx /path/to/home/[user]";
homedirs=$(awk -F: '$3 >= 500 && $3 != 65534 { print $6 }' /etc/passwd);
if [ $(echo ${homedirs} | wc -l) = 0 ]; then
	msg=$(echo "${msg}
NO HOMEDIRS FOUND.");
	type="high";
else
	type="pass";
	for h in ${homedirs}; do
		c=$(find ${h} -maxdepth 0 -type d -printf "%m %p\n" | awk '$1 > 755 { print }' | wc -l );
		if [ $c -gt 0 ]; then
			type="high";
			rec= $(echo "${rec}
find ${h} -maxdepth 0 -type d -printf "%m %p\n")");
		fi
	done
fi
unset homedirs;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.4.3. Ensure user dot files are not world writable.";
msg="There are user dot files that are world writable.";
rec="Ensuring that configuration files are not world writable prevents 
unauthorised users from altering configuration of other users.
Issue the following command to fix these:
# chmod go-w /path/to/[.filename]";
homedirs=$(awk -F: '$3 >= 500 && $3 != 65534 { print $6 }' /etc/passwd);
if [ $(echo ${homedirs} | wc -l) = 0 ]; then
	msg=$(echo "${msg}
NO HOMEDIRS FOUND.");
	type="high";
else
	type="pass";
	for h in ${homedirs}; do
		wwfiles=$(find ${h} -name ".*" -type f -printf "%m %p\n" | awk '$1 > 644 { print }');
		if [ $(echo ${wwfiles} | grep -v "^$" | wc -l) -gt 0 ]; then
			type="high";
			rec=$(echo "${rec}
${wwfiles}");
		fi
	done
fi
unset homedirs;
unset wwfiles;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3.4.4. Ensure that users have sensible umask values", \
"1. Edit the global configuration files /etc/profile, /etc/bashrc, and 
/etc/csh.cshrc. Add or correct the line:
	umask 077
2. Edit the user definitions file /etc/login.defs. Add or correct the line:
	UMASK 077
3. View the additional configuration files /etc/csh.login and 
/etc/profile.d/*, and ensure that none of these files redefine the umask to
a more permissive value unless there is a good reason for it.
4. Edit the root shell configuration files /root/.bashrc, 
/root/.bash profile, /root/.cshrc, and /root/.tcshrc. Add or correct the line:
	umask 077
";
################################################################################
title="2.3.4.5. Ensure that users do not have .netrc files.";
msg="One or more users on the system contain .netrc config files.";
rec="The .netrc file is a configuration file used to make unattended logins to
other systems via FTP.  When this file exists, it frequently contains
unencrypted passwords which may be used to attack other systems.
Remove all the following .netrc files:";
homedirs=$(awk -F: '$3 >= 500 && $3 != 65534 { print $6 }' /etc/passwd);
if [ $(echo ${homedirs} | wc -l) = 0 ]; then
	msg=$(echo "${msg}
NO HOMEDIRS FOUND.");
	type="high";
else
	type="pass";
	for h in ${homedirs}; do
		c=$(find ${h} -name ".netrc" | wc -l);
		if [ $c -gt 0 ]; then
			type="high";
			rec=$(echo "${rec}
$(find ${h} -name ".netrc")");
		fi
	done
fi
unset homedirs;
unset netrcfiles;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3.5. Protect Physical Console Access" \
"Some basic precautions that make hard for attackers to gain console access to 
a system.";
################################################################################
section "2.3.5.1. Set BIOS password" "Out of scope for this tool.";
################################################################################
title="2.3.5.2. Set boot loader password.";
msg="No boot loader password is configured.";
rec="A boot loader password requires that a password is entered on the console
at boot time.  It discourages unauthenticated users from altering the kernel
parameters at boot time.  For example: Disable SELINUX, boot into single user
mode and much more.
Note: The bootloader password is easily overridden via a rescue CD during boot
time.
Add a boot loader password as follows:
1. Select a suitable password and generate a hash from it by using the 
grub-md5-crypt tool.
 # grub-md5-crypt
2. Insert the following line into /etc/grub.conf immediately after hte header
comments.  (use the output of grub-md5-crypt as the value for [password-hash]
	password --md5 [password-hash]
3. Verify the permissions on etc/grub.conf.
	# chown root:root /etc/grub.conf
	# chmod 600 /etc/grub.conf
";
if [ -e /etc/grub.conf ]; then
	titles=$(grep -c "^title" /etc/grub.conf);
	passwds=$(grep -c "password --.*$" /etc/grub.conf);
	if [ $titles -ne $passwds ]; then
		type="low";
		rec=$(echo "${rec}
*** You have titles in your crontab that do not contain password entries.");
	else
		type="pass";
	fi
else
	type="high";
	msg=$(echo "${msg}
COULD NOT FIND /etc/grub.conf.  Is this server running grub2?");
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.5.3. Require authentication for single user mode.";
msg="Single usermode should be root password authenticated.";
rec="Append the following line to /etc/inittab to fix.
 ~:S:wait:/sbin/sulogin";
lines=$(grep -c "^~:S:wait:/sbin/sulogin$" /etc/inittab);
if [ "${lines}" -eq 0 ]; then
	type="low";
else
	type="pass";
fi
unset lines;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.5.4. Disable interactive boot.";
msg="Interactive boot allows the console user to select servives that are 
enabled during boot time.  Important filewalls and security services could be
disabled and weaken system security.";
rec="Add or correct the following setting in /etc/sysconfig/init :
 PROMPT=no";
lines=$(grep -c "^PROMPT=no" /etc/sysconfig/init);
if [ "${lines}" -eq 0 ]; then
	type="low";
else
	type="pass";
fi
unset lines;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.3.5.5. Implement Inactivity Time-out for Login Shells";
msg="Automatic logout after 15 minutes idle on console sessions.
See also the section on SSH security 3.5.2.3. for how to configure the same for
SSH Logins.

*** THIS TEST ONLY CHECKS THE BASH ENVIRONMENT ****";
rec="For bash shells, create a file called /etc/profile.d/tmout.sh with the
following lines:
 TMOUT=900
 readonly TMOUT
 export TMOUT

For tcsh shells, create a file called /etc/profile.d/autologout.csh with the
following lines:
 set -r autologout 15

The readonly and -r settings in these files should be omitted if policies allow
users to override these timeouts.";

type="pass";
sh_lines=$(env | grep -c TMOUT);
if [ "${sh_lines}" -eq 0 ]; then
	type="low";
fi
unset sh_lines;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3.5.6. Configure Screen Locking";
################################################################################
title="2.3.5.6.1. Configure gui screen locking.";
msg="Only applies if X / gnmoe is installed. Make sure that the
gnome-screensaver is enabled for all users.
*** THIS TEST ONLY CHECKS FOR GNOME SESSIONS ***";
rec="";
type="high";
#Start by confirming that X is installed.
if [ $(ps -e | grep -c Xorg) -eq 0 ]; then
	type="pass";
	msg="There is no X server currently running.";
	rec="Nothing to do.";
else
	# xorg is running.  Check for gdm-binary - a sure indicator that gnome is
	# installed.
	if [ $(ps -e | grep -c gdm-binary) -eq 0 ]; then
		type="pass";
		msg="GNOME is not running.";
		rec="Nothing to do.";
	else
		# All test logic fits here.  Testing 4 settings:
		testresult=$(gconftool-2 --direct --config-source xml:read:/etc/gconf/gconf.xml.mandatory --get /apps/gnome-screensaver/idle_activation_enabled);
		if [ "${testresult}" != "true" ]; then
			type="low";
			rec=$(echo "${rec}
# gconftool-2 --direct --config-source xml:/readwrite:/etc/gconf/gconf.xml.mandatory --type bool --set /apps/gnome-screensaver/idle_activation_enabled true");
		fi
		testresult=$(gconftool-2 --direct --config-source xml:read:/etc/gconf/gconf.xml.mandatory --get /apps/gnome-screensaver/lock_enabled);
		if [ "${testresult}" != "true" ]; then
			type="low";
			rec=$(echo "${rec}
# gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type bool --set /apps/gnome-screensaver/lock_enabled true");
		fi
		testresult=$(gconftool-2 --direct --config-source xml:read:/etc/gconf/gconf.xml.mandatory --get /apps/gnome-screensaver/mode);
		if [ "${testresult}" != "blank-only" ]; then
			type="low";
			rec=$(echo "${rec}
# gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type string --set /apps/gnome-screensaver/mode blank-only");
		fi
		testresult=$(gconftool-2 --direct --config-source xml:read:/etc/gconf/gconf.xml.mandatory --get /apps/gnome-screensaver/idle_delay);
		if [ "${testresult}" != 15 ]; then
			type="low";
			rec=$(echo "${rec}
# gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type int --set /apps/gnome-screensaver/idle_delay 15");
		fi
	fi
fi
unset testresult
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section="2.3.5.6.2. Configure console screen locking";
text="Console screen locking can be achived via the vlock program which is not
installed by default.  If console locking is neccessary then install the vlock
package.
 # yum install vlock

Instruct users to enable it with:
 # vlock -a";
section "${title}" "${text}";
################################################################################
section "2.3.5.7. Disable unnecessary ports." "Systems in secure data centre
environments are at low risk of attack vectors via USB, FIREWIRE, SATA and other
physical ports.
It is considered best practice to disable ports not required in the BIOS.
*** WARNING ***
   Do not disable USB ports in this way as they are required for keyboard and
   mouse input.";
################################################################################
section "2.3.6. Use a centralised authentication service" \
"Consider managing all user accounts and passwords with ldap from a central
location.";
################################################################################
section "2.3.7. Warning banners for system access.";
################################################################################
title="2.3.7.1. Modify the system login banner";
msg="The default login banner is installed.  This gives basic information about
the operating system and kernel version to users prior to authentication.";
rec="It appears as though you have a default redhat warning banner defined
at /etc/issue.  Consider updating it to one that defines roles and
responsibilities implied by use of the server.
Current banner is:
/etc/issue
$(cat /etc/issue)";
line1=$(echo | awk 'NR==1 { print;exit }' /etc/issue);
line2=$(echo | awk 'NR==2 { print;exit }' /etc/issue);
if [ "${line1}" == "$(cat /etc/redhat-release)" ]; then
	if [ "${line2}" == "Kernel \r on an \m" ]; then
		type="low";
	else
		type="pass";
	fi
else
	type="pass";
fi
unset line1
unset line2
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.3.7.2. Impliment a GUI warning banner." \
"A gui login banner can be defined in /usr/share/gdm/themes/RHEL/RHEL.xml";
################################################################################
section "2.4 SELinux";
section "2.4.1. How SELinux Works";
################################################################################
title="2.4.2.  Enable SELInux";
msg="Ensure that SELinux is configured and enabled correctly.
Edit /etc/selinux/config and add or correct the following lines:
  SELINUX=enforcing
  SELINUXTYPE=targeted
Edit /etc/grub.conf and ensure that the following arguments DO NOT appear on any
of the kernel command lines:
  selinux=0
  enforcing=0";
enforcingon=$(grep -c "^SELINUX=enforcing$" /etc/selinux/config);
targetedon=$(grep -c "^SELINUXTYPE=targeted$" /etc/selinux/config);
kcmd=0;
if [ -e /boot/grub/grub.conf ]; then
	kcmd=$((${kcmd} + $(grep "^\s*kernel" /boot/grub/grub.conf | grep -c "enforcing=0")));
	kcmd=$((${kcmd} + $(grep "^\s*kernel" /boot/grub/grub.conf | grep -c "selinux=0")));
elif [ -e /boot/grub2/grub.cfg ]; then
	kcmd=$((${kcmd} + $(grep "^\s*linux" /boot/grub2/grub.cfg | grep -c "enforcing=0")));
	kcmd=$((${kcmd} + $(grep "^\s*linux" /boot/grub/grub.conf | grep -c "selinux=0")));	
fi
rec="";
if [ "${enforcingon}" -eq 1 ]; then
	rec=$(echo "${rec}
GOOD: selinux policy is set to enforcing in /etc/selinux/config.");
	if [ "${targetedon}" -eq 1 ]; then
		type="pass";
		rec=$(echo "${rec}
GOOD: selinux policy is set to targeted in /etc/selinux/config.");
	else
		type="high";
		rec=$(echo "${rec}
ALERT: selinux policy is not set to targeted in /etc/selinux/config.");
	fi
else
	type="high";
	rec=$(echo "${rec}
ALERT: selinux is not set to enabled in /etc/selinux/config.");
fi

if [ "${kcmd}" -gt 0 ]; then
  rec=$(echo "${rec}
ALERT: There are grub kernel or linux parameters that turn selinux off or set it
to permissive mode.
Check /boot/grub/grub.conf (grub) or /boot/grub2/grub.cfg (grub2)");
	type="high";
fi
unset enforcingon;
unset targetedon;
unset kcmd;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.4.2.1. Ensure SELinux is properly enabled.";
msg="Check that SELinux is currently enabled.  SELinux can be disabled during
runtime so this check makes sure it's still running.";
rec="Alter config settings as 2.4.2.  Enable SELInux
execute the following command as root:
 # setenforce 1";
sestatus=$(/usr/sbin/sestatus | grep "SELinux status" | awk -F': *' '{ print $2 }');
if [ "${sestatus}" != "enabled" ]; then
	type="high";
	rec=$(echo "${rec}
Output of /usr/sbin/sestatus:
$(/usr/sbin/sestatus)");
else
	type="pass";
fi
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.4.3. Disable unnecessary SELinux Daemons";
################################################################################
title="2.4.3.1. Disable and remove SETroubleshoot if possible.";
msg="Unless there is a requirement for users to have access to the
setroubleshoot gui, disable it and remove it.";
req="Turn the service off, remove the service and erase the package.
# service setroubleshootd stop
# chkconfig setroubleshoot off
# yum erase setroubleshoot";
rec="Any problems found are listed below:";
type="pass";
enabled=$(chkconfig --list | grep -c setroubleshoot);
if [ "${enabled}" -gt 0 ]; then
	type="low";
	rec=$(echo "${rec}
setroubleshoot is enabled");
fi
unset enabled;
installed=$(rpm -qa setroubleshoot | grep -c setroubleshoot);
if [ "${installed}" -gt 0 ]; then
	type="low";
	rec=$(echo "${rec}
setroubleshoot package is installed");
fi
unset installed;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.4.3.3. Restorecon service" "No recommendations given by NSA guide.";
################################################################################
title="2.4.4. Check for unconfined daemons";
msg="Daemons that are started by the init process inherit the security context
of init. (initrc).  They should be properly confined and this check should
come up empty.";
rec="Configure the following daemons correctly for SELinux.";
num_bad_daemons=$(ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }' | wc -l);
if [ "${num_bad_daemons}" -gt 0 ]; then
	type="low";
	rec=$(echo "${rec}
$(ps -eZ | egrep "initrc" | egrep -vw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }'
)");
else
	type="pass";
fi
unset num_bad_daemons;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.4.5. Check for unlabled device files";
msg="Device files are used for communication with important system resources. 
SELinux contexts should exist for these. If a device file is not labeled, then
misconfiguration is likely.";
rec="Configure SELinux contexts on these devices files correctly.";
num_device_files=$(ls -Zl /dev | grep -c unlabeled_t);
if [ "${num_device_files}" -gt 0 ]; then
	type="low";
	rec=$(echo "${rec}
$(ls -Z /dev)");
else
	type="pass";
fi
unset num_device_files;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
section "2.4.6. Debugging SELinux Policy Errors" \
"This section is not required for database servers.  A more detailed
review of SELinux might be appropriate.  Please check the above errors and read
along in the NSA Guide for how to do this.";
section "2.4.7. Further Strengthening" \
"This section is not required for database servers.  A more detailed
review of SELinux might be appropriate.  Please check the above errors and read
along in the NSA Guide for how to do this.";
################################################################################
section "2.5. Network Configuration and Firewalls" \
"This section checks system settings in terms of networking and firewalls.";
################################################################################
title="2.5.1.1. Network Parameters for Hosts Only";
msg="Make sure the system does not forward network traffic or act as a go
between in any way.";
rec="If any of the following values = 1 then set them to 0 and alter
/etc/sysctl.conf.";
results="";
results="$(sysctl net.ipv4.ip_forward | grep -v 0)
$(sysctl net.ipv4.conf.all.send_redirects | grep -v 0)
$(sysctl net.ipv4.conf.default.send_redirects | grep -v 0)";

if [ "${results}" != ""  ]; then
	type="high";
	rec=$(echo "${rec}
${results}");
else
	type="pass";
fi
unset results;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.5.1.2. Network parameters for hosts and routers.";
msg="General improvement of system ability to defend against certain types of
IPv4 protocol attacks.";
results="";
results="$(sysctl net.ipv4.conf.all.accept_source_route | grep -v 0)
$(sysctl net.ipv4.conf.all.accept_redirects | grep -v 0)
$(sysctl net.ipv4.conf.all.secure_redirects | grep -v 0)
$(sysctl net.ipv4.conf.all.log_martians | grep -v 1)
$(sysctl net.ipv4.conf.default.accept_source_route | grep -v 0)
$(sysctl net.ipv4.conf.default.accept_redirects | grep -v 0)
$(sysctl net.ipv4.conf.default.secure_redirects | grep -v 0)
$(sysctl net.ipv4.icmp_echo_ignore_broadcasts | grep -v 1)
$(sysctl net.ipv4.icmp_ignore_bogus_error_responses | grep -v 1)
$(sysctl net.ipv4.tcp_syncookies | grep -v 1)
$(sysctl net.ipv4.conf.all.rp_filter | grep -v 1)
$(sysctl net.ipv4.conf.default.rp_filter | grep -v 1)";
if [ "${results}" != ""  ]; then
	type="high";
	rec=$(echo "${rec}
Check the results below against these correct values and fix them in 
/etc/sysctl.conf if they are set incorrectly.

GOOD VALUES
=============================================
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_messages = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

RESULTS FOUND:
=============================================
${results}");
else
	type="pass";
fi
unset results;
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
title="2.5.1.3. Ensure System is Not Acting as a Network Sniffer";
msg="Make sure there is nothing sniffing packets.";
lc=$(cat /proc/net/packet | wc -l);
if [ "${lc}" -gt 1 ]; then
	type="high";
	rec="Something is acting as a network sniffer and should be investigated.
Wireshark and TCP DUMP can be valid examples but these should not be left
running all the time.";
else
	type="pass";
fi
unset lc
xmlitem "${title}" ${type} "${msg}" "${rec}";
################################################################################
# Collate
################################################################################
echo "</items>" >> report.xml;
