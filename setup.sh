#! /bin/sh

# http://k.itty.cat/7
# FreeBSD Desktop
# Version 0.1.31

########################################################################################
# Copyright (c) 2016-2024, The Daniel Morante Company, Inc.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of the FreeBSD Project.
########################################################################################

# The Latest version of the script can be found at:
# 	ftp://ftp.morante.net/pub/FreeBSD/extra/desktop/freebsd-desktop.sh
# For a full explination of what is going on here, please visit:
# 	http://www.unibia.com/unibianet/freebsd/mate-desktop

# For 12.3-RELEASE thru 14.0-RELEASE
MIN_VERSION=1203000
MAX_VERSION=1400097

# Setup desktop FreeBSD (the "-K" option for "uname" is not avaiable pre-12)
CURRENT_FREEBSD_VERSION=$(sysctl -n kern.osreldate)

# Only root can run this
if [ $(id -u) -ne 0 ]; then
	echo "Fatal Error: The script must be run as root"
	exit 1
fi

# Make sure we are on FreeBSD
if [ $(sysctl -n kern.ostype) != "FreeBSD" ]; then
	echo "Fatal Error: This script is only for FreeBSD"
	exit 1
fi

# Currently we only support FreeBSD 12.3 up to 14.0
if [ ! $CURRENT_FREEBSD_VERSION -ge $MIN_VERSION ] || [ ! $CURRENT_FREEBSD_VERSION -le $MAX_VERSION ]; then
	echo "Fatal Error: This script is not supported for your FreeBSD version: $(freebsd-version)"
	exit 1
fi

# Only 64-bit CPU
if [ $(getconf LONG_BIT) != 64 ]; then
	echo "Fatal Error: This script is only for 64-bit machines"
	exit 1
fi

# Helper function to set values in conf files
setconfig () {
	while getopts :f: flag; do
		case "$flag" in
		f) sc_config=$OPTARG ;;
		\?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
		:) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
		esac
	done
	shift $(($OPTIND-1))

	sc_value=$1
	sc_directive=`echo $sc_value | cut -d'=' -f1`

	if [ -z "$sc_value" ] || [ -z "$sc_directive" ] || [ -z "$sc_config" ]; then echo -e \\n"Mssing arguments"; return 1; fi

	if grep -sq $sc_directive $sc_config >&2; then
		sed -i '' -e "s#$sc_directive.*#$sc_value#" $sc_config
	else
		echo $sc_value >> $sc_config
	fi
}

addline () {
	while getopts :f:t flag; do
		case "$flag" in
		f) ln_config=$OPTARG ;;
		t) tabbify="yes" ;;
		\?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
		:) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
		esac
	done
	shift $(($OPTIND-1))

	ln_value=$1

	if [ -z "$ln_value" ] || [ -z "$ln_config" ]; then	echo -e \\n"Mssing arguments"; return 1; fi

	if [ $(grep -Eq -e "^$(echo -e ${ln_value} | sed s/[[:blank:]]/[[:blank:]]/g)$" "${ln_config}"; echo $?) == 1 ]; then 
		if [ "$tabbify" == "yes" ]; then ln_value=$(echo -e ${ln_value} | sed s/[[:blank:]]/\\\\t/g); fi
		echo -e ${ln_value} >> $ln_config; 
	fi;
}

iniconfig () {
	while getopts :f:s: flag; do
		case "$flag" in
		f) ini_config=$OPTARG ;;
		s) ini_section=$OPTARG ;;
		\?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
		:) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
		esac
	done
	shift $(($OPTIND-1))

	ini_value=$1
	ini_directive=`echo $ini_value | cut -d'=' -f1`

	if [ -z "$ini_value" ] || [ -z "$ini_section" ] || [ -z "$ini_directive" ] || [ -z "$ini_config" ]; then	echo -e \\n"Mssing arguments"; return 1; fi

	# Keep track of the end of file line
	last_line=$(awk 'END {print NR}' $ini_config)

	# Find out what line the section begins
	starting_line=$(awk "/\[${ini_section}\]/ {print FNR}" $ini_config)

	# If the section does not exists
	if [ -z "$starting_line" ]; then
		# Add this section
		starting_line=$last_line
		echo -e "[${ini_section}]" >> $ini_config;
	fi

	# Find out what line the section ends
	next_section=$(awk "NR>${starting_line}&&/\[.*\]/ {print FNR}" $ini_config)
	if [ -z "$next_section" ]; then 
		ending_line=$last_line
	else
		ending_line=$(($next_section - 1))
	fi

	# Make the change within the disired range
	# Search starts right after the section header, not including it.
	starting_line=$(($starting_line + 1))
	if awk "NR==${starting_line},NR==${ending_line}" $ini_config | grep -sq $ini_directive >&2; then
		sed -i '' -e "${starting_line},${ending_line}s#$ini_directive.*#$ini_value#" $ini_config
	else
		insert_line=$ending_line
		# If we are at EOF, add a new line
		if [ $insert_line == $last_line ]; then echo >> $ini_config; fi
		before_line=$(( $ending_line - 1))
		before_line_value=$(awk "NR==${before_line}" $ini_config)
		if [ -z "$before_line_value" ]; then insert_line=$before_line; fi
		insert_line_value=$(awk "NR==${insert_line}" $ini_config)
		if [ ! -z "$insert_line_value" ]; then insert_line=$(($insert_line + 1)); fi
		#echo -e "${insert_line}\ni\n${ini_value}\n.\n\$\na\n\n.\n?^..*?+1,.d\nw\n" | ed -s $ini_config
		echo -e "${insert_line}\ni\n${ini_value}\n.\nw\n" | ed -s $ini_config
	fi
}

env PAGER=cat freebsd-update fetch --not-running-from-cron
env PAGER=cat freebsd-update install --not-running-from-cron

mkdir -p /usr/local/etc/pkg/repos/
echo 'FreeBSD: { enabled: no }' > /usr/local/etc/pkg/repos/FreeBSD.conf
sh -c 'echo -e "Base: {\n\turl: \"http://pkg.morante.net/desktop/\${ABI}\",\n\tenabled: yes\n}" > /usr/local/etc/pkg/repos/Desktop.conf'

env ASSUME_ALWAYS_YES=YES pkg bootstrap

# Install Pacy World Root CA's into system CA root store (FreeBSD 12.2 or greater)
if [ $(sysctl -n kern.osreldate) -ge  1202000 ]; then
    fetch -qo /usr/share/certs/trusted/ca-pacyworld.com.pem http://cdn.pacyworld.com/pacyworld.com/ca/ca-pacyworld.com.crt
    fetch -qo /usr/share/certs/trusted/alt_ca-morante_root.pem http://cdn.pacyworld.com/pacyworld.com/ca/alt_ca-morante_root.crt
	certctl rehash
fi

# Configure rc.conf
sysrc moused_enable="YES" dbus_enable="YES" hald_enable="YES" ntpd_enable="YES" ntpd_flags="-g" webcamd_enable="YES" kiconv_preload="YES" kiconv_local_charsets="UTF-8" kiconv_foreign_charsets="UTF-8"

# Install Core Graphical Environment Software (last 2 pull in core libs for QT and GTK)
pkg install -y xorg
pkg install -y xdg-user-dirs
pkg install -y webcamd kiconvtool
pkg install -y octopkg
pkg install -y leafpad

# Install Icon & Cursor Themes
pkg install -y x11-themes/papirus-icon-theme x11-themes/cursor-neutral-white-theme x11-themes/qogir-icon-themes x11-themes/win98se-icon-theme

# Shell and Utilities
pkg install -y fish sudo doas alacritty

# Initial Sound theme
pkg install -y audio/freedesktop-sound-theme

# Install some fonts
pkg install -y chinese/arphicttf chinese/font-std hebrew/culmus hebrew/elmar-fonts japanese/font-ipa japanese/font-ipa-uigothic japanese/font-ipaex japanese/font-kochi japanese/font-migmix japanese/font-migu japanese/font-mona-ipa japanese/font-motoya-al japanese/font-mplus-ipa japanese/font-sazanami japanese/font-shinonome japanese/font-takao japanese/font-ume japanese/font-vlgothic x11-fonts/hanazono-fonts-ttf japanese/font-mikachan korean/aleefonts-ttf korean/nanumfonts korean/unfonts-core x11-fonts/anonymous-pro x11-fonts/artwiz-aleczapka x11-fonts/dejavu x11-fonts/inconsolata-ttf x11-fonts/terminus-font x11-fonts/cantarell-fonts x11-fonts/droid-fonts-ttf x11-fonts/doulos x11-fonts/ubuntu-font x11-fonts/isabella x11-fonts/junicode x11-fonts/khmeros x11-fonts/padauk x11-fonts/stix-fonts x11-fonts/charis x11-fonts/urwfonts-ttf russian/koi8r-ps x11-fonts/geminifonts x11-fonts/cyr-rfx x11-fonts/paratype x11-fonts/gentium-plus x11-fonts/nerd-fonts x11-fonts/powerline-fonts

# Install Emoji fonts & tooling
pkg install -y twemoji-color-font-ttf noto-emoji textproc/ibus-uniemoji

# Web Broswer
pkg install -y firefox

# Install additional usefull software for a better experience
pkg install -y thunderbird mpc-qt vlc notepadnext photoflare

# Install Spell Check, Dictionaries, Thesuarus, and Word lists (English only for now)
pkg install -y hunspell aspell mythes
pkg install -y en-hunspell en-aspell en-mythes

# Install Desktop Environment, themes and related utilities
pkg install -y mate
pkg install -y seahorse gnome-keyring
pkg install -y networkmgr pavucontrol
pkg install -y x11-themes/matcha-gtk-themes x11-themes/gtk-nodoka-engine x11-themes/qogir-gtk-themes x11-themes/chicago95

# Install session manager with themes/tools
pkg install -y sddm
pkg install -y sddm-freebsd-black-theme

# Enable, and configure session manager
sysrc sddm_enable="YES"
# Setup SDDM login theme
mkdir -p /usr/local/etc/sddm.conf.d
cat << EOF >/usr/local/etc/sddm.conf.d/FreeBSD.conf
[Theme]
Current=sddm-freebsd-black-theme
EOF

# Mount points for Java
FSTAB=/etc/fstab; if [ $(grep -q "/proc" "${FSTAB}"; echo $?) == 1 ]; then echo -e "proc\t/proc\t\t\tprocfs\trw\t\t0\t0" >> $FSTAB; fi; if [ $(grep -q "/dev/fd" "${FSTAB}"; echo $?) == 1 ]; then echo -e "fdesc\t/dev/fd\t\t\tfdescfs\trw,auto,late\t0\t0" >> $FSTAB; fi

# Allow sudo and doas to function for users in the 'wheel' group
sed -i '' -r 's/^# (%wheel ALL=\(ALL\) ALL)$/\1/I' /usr/local/etc/sudoers
sed -i "" -e 's/# %sudo/%sudo/g' /usr/local/etc/sudoers

# Improved Networking
setconfig -f /etc/sysctl.conf net.local.stream.recvspace=65536
setconfig -f /etc/sysctl.conf net.local.stream.sendspace=65536
# Enhance shared memory X11 interface
setconfig -f /etc/sysctl.conf kern.ipc.shmmax=67108864
setconfig -f /etc/sysctl.conf kern.ipc.shmall=32768
# Enhance desktop responsiveness under high CPU use (200/224)
setconfig -f /etc/sysctl.conf kern.sched.preempt_thresh=224
# Bump up maximum number of open files
setconfig -f /etc/sysctl.conf kern.maxfiles=200000
# Shared memory for Chromium
setconfig -f /etc/sysctl.conf kern.ipc.shm_allow_removed=1
# Allow users to mount disks
setconfig -f /etc/sysctl.conf vfs.usermount=1

# The essentials for a desktop
sysrc -f /boot/loader.conf fusefs_load="YES" tmpfs_load="YES" smbfs_load="YES" aio_load="YES" libiconv_load="YES" libmchain_load="YES" cd9660_iconv_load="YES" msdosfs_iconv_load="YES" snd_driver_load="YES" cuse_load="YES" 

# Pretty Boot
sysrc -f /boot/loader.conf boot_mute="YES" autoboot_delay="3"
sysrc rc_startmsgs="NO" background_dhclient="YES"

# Override the FreeBSD default syslog.conf with a desktop friendly version
# The magic is in the last line, it copies the existing syslog.conf (minus comments) 
# and removes the line that logs to /dev/console
# Hints for `sed` from: https://stackoverflow.com/questions/17998763/sed-commenting-a-line-matching-a-specific-string-and-that-is-not-already-comme
sysrc syslogd_flags="-s -f /usr/local/etc/syslog.conf"
touch /var/log/console.log; chmod 600 /var/log/console.log
cat << EOF >/usr/local/etc/syslog.conf
# FreeBSD $(freebsd-version)
# Desktop Syslog Configuration File
# Generated on $(date)
# Version 0.0.1
#
# This file was created by the FreeBSD Desktop installer. Changes made here 
# could be overritten. Add any syslog configuration entries to: 
#
# /usr/local/etc/syslog.d/*.conf
#
# This is the FreeBSD recomended best practice.
#
*.err;kern.warning;auth.notice;mail.crit               /var/log/console.log
console.*                                              /var/log/console.log
$(cat /etc/syslog.conf | sed 's/^[^#]*\/dev\/console/#&/' | grep '^[^#]')
EOF

# Silence rc.d completely
#
# TODO: This isn't elegant at all and is more of a hack.  However FreeBSD has not other way
# of addressing this functionality unless you resort to modifying the base system, which we
# do not want to do.
sysrc suppress_rc_output="YES" rc_conf_files="/etc/rc.conf /etc/rc.conf.local /etc/rc.conf.desktop"
cat << EOF >/etc/rc.conf.desktop
# FreeBSD $(freebsd-version)
# Desktop Local RC File
# Generated on $(date)
# Version 0.0.1
#
# This file was created by the FreeBSD Desktop installer. Changes made here 
# could be overritten.
#
# Redirect all output (stdout and stderr to /dev/null if the option is enabled
# in /etc/rc.conf
if checkyesno suppress_rc_output; then
    # An alternative would be to turn close the file descriptors
    # using '&-' instead of '/dev/null'.   More testing needed.
    exec 1>/dev/null
    exec 2>/dev/null
fi
EOF

# Boot-time kernel tuning
setconfig -f /boot/loader.conf kern.ipc.shmseg=1024
setconfig -f /boot/loader.conf kern.ipc.shmmni=1024
setconfig -f /boot/loader.conf kern.maxproc=100000

# Enable equalizer for sound cards
# https://forums.ghostbsd.org/viewtopic.php?t=792
# https://github.com/nomadbsd/NomadBSD/blob/master/config/boot/loader.conf
# https://github.com/helloSystem/ISO/blob/experimental/overlays/boot/boot/loader.conf
setconfig -f /boot/loader.conf hint.pcm.0.eq="1"
setconfig -f /boot/loader.conf hint.pcm.1.eq="1"
setconfig -f /boot/loader.conf hint.pcm.2.eq="1"
setconfig -f /boot/loader.conf hint.pcm.3.eq="1"
setconfig -f /boot/loader.conf hint.pcm.4.eq="1"
setconfig -f /boot/loader.conf hint.pcm.5.eq="1"
setconfig -f /boot/loader.conf hint.pcm.6.eq="1"
setconfig -f /boot/loader.conf hint.pcm.7.eq="1"
setconfig -f /boot/loader.conf hint.pcm.8.eq="1"
setconfig -f /boot/loader.conf hint.pcm.9.eq="1"

cat << EOF >/usr/local/etc/PolicyKit/PolicyKit.conf
<config version="0.1">
	<match user="root">
		<return result="yes"/>
	</match>
	<define_admin_auth group="wheel"/>
	<match action="org.freedesktop.hal.power-management.shutdown">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.power-management.reboot">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.power-management.suspend">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.power-management.hibernate">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.storage.mount-removable">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.storage.mount-fixed">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.storage.eject">
		<return result="yes"/>
	</match>
	<match action="org.freedesktop.hal.storage.unmount-others">
		<return result="yes"/>
	</match>
</config>
EOF

# Add Locals
if [ $(locale | grep -q "UTF-8"; echo $?) == 1 ]; then 
	EDIT_FILE=/etc/login.conf; 
	if [ $(head -50 "${EDIT_FILE}" | grep -q ":charset=UTF-8:"; echo $?) == 1 ]; then echo -e '/^\t:umask=022:$/\nc\n\t:umask=022:\\\n\t:charset=UTF-8:\\\n\t:lang=en_US.UTF-8:\n.\nw\n' | ed -s ${EDIT_FILE}; fi
	cap_mkdb /etc/login.conf
	setconfig -f /etc/profile LANG=en_US.UTF-8\;
	setconfig -f /etc/profile CHARSET=UTF-8\;
fi

# Allow all users to access optical media
addline -tf /etc/devfs.conf "perm    /dev/acd0       0666"
addline -tf /etc/devfs.conf "perm    /dev/acd1       0666"
addline -tf /etc/devfs.conf "perm    /dev/cd0        0666"
addline -tf /etc/devfs.conf "perm    /dev/cd1        0666"

# Allow all USB Devices to be mounted
addline -tf /etc/devfs.conf "perm    /dev/da0        0666"
addline -tf /etc/devfs.conf "perm    /dev/da1        0666"
addline -tf /etc/devfs.conf "perm    /dev/da2        0666"
addline -tf /etc/devfs.conf "perm    /dev/da3        0666"
addline -tf /etc/devfs.conf "perm    /dev/da4        0666"
addline -tf /etc/devfs.conf "perm    /dev/da5        0666"
     
# Misc other devices
addline -tf /etc/devfs.conf "perm    /dev/pass0      0666"
addline -tf /etc/devfs.conf "perm    /dev/xpt0       0666"
addline -tf /etc/devfs.conf "perm    /dev/uscanner0  0666"
addline -tf /etc/devfs.conf "perm    /dev/video0     0666"
addline -tf /etc/devfs.conf "perm    /dev/tuner0     0666"
addline -tf /etc/devfs.conf "perm    /dev/dvb/adapter0/demux0    0666"
addline -tf /etc/devfs.conf "perm    /dev/dvb/adapter0/dvr       0666"
addline -tf /etc/devfs.conf "perm    /dev/dvb/adapter0/frontend0 0666"

# Install a devfs.rules
cat << EOF >/etc/devfs.rules 
[devfsrules_common=7]
add path 'ad[0-9]\*'		mode 666
add path 'ada[0-9]\*'	mode 666
add path 'da[0-9]\*'		mode 666
add path 'acd[0-9]\*'	mode 666
add path 'cd[0-9]\*'		mode 666
add path 'mmcsd[0-9]\*'	mode 666
add path 'pass[0-9]\*'	mode 666
add path 'xpt[0-9]\*'	mode 666
add path 'ugen[0-9]\*'	mode 666
add path 'usbctl'		mode 666
add path 'usb/\*'		mode 666
add path 'lpt[0-9]\*'	mode 666
add path 'ulpt[0-9]\*'	mode 666
add path 'unlpt[0-9]\*'	mode 666
add path 'fd[0-9]\*'		mode 666
add path 'uscan[0-9]\*'	mode 666
add path 'video[0-9]\*'	mode 666
add path 'tuner[0-9]*'  mode 666
add path 'dvb/\*'		mode 666
add path 'cx88*' mode 0660
add path 'cx23885*' mode 0660 # CX23885-family stream configuration device
add path 'iicdev*' mode 0660
add path 'uvisor[0-9]*' mode 0660
EOF

sysrc devfs_system_ruleset="devfsrules_common"

# Setup doas
cat << EOF >/usr/local/etc/doas.conf
permit nopass keepenv root
permit :wheel
permit nopass keepenv :wheel cmd netcardmgr
permit nopass keepenv :wheel cmd detect-nics
permit nopass keepenv :wheel cmd detect-wifi
permit nopass keepenv :wheel cmd ifconfig
permit nopass keepenv :wheel cmd service
permit nopass keepenv :wheel cmd wpa_supplicant
permit nopass keepenv :wheel cmd fbsdupdatecheck
permit nopass keepenv :wheel cmd fbsdpkgupdate
permit nopass keepenv :wheel cmd pkg args upgrade -y
permit nopass keepenv :wheel cmd pkg args upgrade -Fy
permit nopass keepenv :wheel cmd pkg args lock
permit nopass keepenv :wheel cmd pkg args unlock
permit nopass keepenv :wheel cmd mkdir args -p /var/db/update-station/
permit nopass keepenv :wheel cmd chmod args -R 665 /var/db/update-station/
permit nopass keepenv :wheel cmd sh args /usr/local/lib/update-station/cleandesktop.sh
permit nopass keepenv :wheel cmd shutdown args -r now
EOF

# Install VMWare Tools (if virtual machine on VMWare)
if [ $(pciconf -lv | grep -i vmware >/dev/null 2>/dev/null; echo $?) = "0" ]; then
	fetch -qo - http://k.itty.cat/3 | sh
fi

# Install VirtualBox Addons (if virtual machine on VirtualBox)
if [ $(pciconf -lv | grep -i virtualbox >/dev/null 2>/dev/null; echo $?) = "0" ]; then
	# Install the drivers
	pkg install -y emulators/virtualbox-ose-additions
	# Enable
	sysrc vboxguest_enable="YES" vboxservice_enable="YES"
	# Moused doesn't work with VirtualBox
	sysrc moused_enable="NO"
fi

# All done, lets reboot into a desktop!
reboot
