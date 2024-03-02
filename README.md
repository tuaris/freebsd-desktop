# FreeBSD Desktop with MATE

This is an installation script for a FreeBSD based MATE desktop. See http://www.unibia.com/unibianet/freebsd/mate-desktop for additional information.

__Note: Use the link (http://k.itty.cat/7) to always get the latest version of the installation script.__

#### Disclaimers and Warnings

* It makes use of a custom package repository (https://pkg.ny-us.morante.net/desktop/). 
* The [`security/ca_root_nss`](https://www.freshports.org/security/ca_root_nss) package is altered to include the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).
* The [`security/nss`](https://www.freshports.org/security/nss) package is altered to include the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).
* The [`www/firefox`](https://www.freshports.org/www/firefox) and [`www/firefox-esr`](https://www.freshports.org/www/firefox-esr) packages are altered to include the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).
* The [`www/firefox`](https://www.freshports.org/www/firefox) and [`www/firefox-esr`](https://www.freshports.org/www/firefox-esr) packages are altered to disable Pocket, DoH, and Telemetry by default.
* The [`mail/thunderbird`](https://www.freshports.org/mail/thunderbird) package is altered to include the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).
* All [`www/node`](https://www.freshports.org/www/node) packages are also altered to include the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).
* WIP: DoH disabled by default in Firefox as was done by [OpenBSD](https://undeadly.org/cgi?action=article;sid=20190911113856)
* WIP: Pinned certificates for well-know ad serving hostnames removed from Firefox.
* I do not make any guarantee that latest security updates will be readily available.
* The integrity of this repository is currently not being validated.
* A full list of notable modifications can be found at https://github.com/tuaris/desktop_ports

## Quick Start

It's recommended that you start with a clean install of FreeBSD 12.x 64-bit.  Your non-root user
should belong to the `operator` and `wheel` group so that it can perform administrative functions.

```
fetch -o - http://k.itty.cat/7 | sh
```

After about 30 minutes (depending on your Internet connection) your system will automatically
reboot into a graphical desktop.

### Known Issues

There is no error control.  If a package fails to download, the execution will just continue.  If this happens, re-run the script.  It's perfectly safe to run this script as much as you want without any negative side effects.

### Obligatory Screenshots

[![Screenshot1](http://venus.morante.net/downloads/unibia/screenshots/freebsd/thumb/desktop-1-250px.jpg?gh)](http://venus.morante.net/downloads/unibia/screenshots/freebsd/desktop-1.jpg)
[![Screenshot2](http://venus.morante.net/downloads/unibia/screenshots/freebsd/thumb/desktop-2-250px.jpg?gh)](http://venus.morante.net/downloads/unibia/screenshots/freebsd/desktop-2.jpg)
[![Screenshot3](http://venus.morante.net/downloads/unibia/screenshots/freebsd/thumb/desktop-3-250px.jpg?gh)](http://venus.morante.net/downloads/unibia/screenshots/freebsd/desktop-3.jpg)
[![Screenshot4](http://venus.morante.net/downloads/unibia/screenshots/freebsd/thumb/desktop-4-250px.jpg?gh)](http://venus.morante.net/downloads/unibia/screenshots/freebsd/desktop-4.jpg)
[![Screenshot5](http://venus.morante.net/downloads/unibia/screenshots/freebsd/thumb/desktop-5-250px.jpg?gh)](http://venus.morante.net/downloads/unibia/screenshots/freebsd/desktop-5.jpg)
[![Screenshot6](http://venus.morante.net/downloads/unibia/screenshots/freebsd/thumb/desktop-6-250px.jpg?gh)](http://venus.morante.net/downloads/unibia/screenshots/freebsd/desktop-6.jpg)

## Requirements

Platform options are limited only due to lack of packages.  It's recomended that you start with a fresh copy of FreeBSD for the best results.

- FreeBSD 13.2-RELEASE or later
- 64-bit edition (amd64)
- 20 GB free space
- Internet connection

Packages for 12.x-RELEASE, 11.x-RELEASE and ARM platforms are also built, but not guaranteed to be available.

### User

This install script does not create a user nor prompt you to create one.  The user account you plan on using should below to the `wheel`, `operator`, and `video` groups.

```
pw usermod <user> -G wheel,operator,video
```

Replace `<user>` above with the user account that you will want to allow login access to the desktop.

## About

This is inspired by GhostBSD.  GhostBSD is a FreeBSD desktop that uses (and as of 3/1/2024 still does use) FreeBSD as it's base. A few years ago GhostBSD switched it's base to TrueOS, then back to FreeBSD CURRENT after TrueOS was discontinued.  At somepoint is was announced GhostBSD was moving to Linux, but that hasn't materialized.  While GhostBSD continues to be a great desktop I require (and prefer) a FreeBSD base system, and some assurance that it will always be FreeBSD based. I created this installation script and the corresponding PKG repository for this reason.

## How it Works

A custom PKG repo is built using [ports-mgmt/poudriere](https://www.freshports.org/ports-mgmt/poudriere). It uses the default FreeBSD ports tree and merges it with some additional custom developed packages.  Here is the `make.conf` file used for this repository.

```
# Allows us to build ports non-interactively
DISABLE_LICENSES=yes

# Desktop Specific Options
OPTIONS_SET+=SNDIO
sysutils_gksu_UNSET+=NAUTILUS
x11-wm_compiz-fusion_UNSET+=EMERALD
accessibility_redshift_SET+=GUI VIDMODE
audio_espeak_UNSET+=PORTAUDIO
www_qt5-webengine_UNSET+=ALSA
www_qt6-webengine_UNSET+=ALSA
audio_rhvoice_UNSET+=AO
comms_morse_UNSET+=OSS
audio_harp_UNSET+=OSS
```

*The full build scripts and configuration files will be published sometime in the future.*

The most notable alteration to the default FreeBSD ports tree is the addition of the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).

## Key Package List

The complete list of packages installed will vary as dependencies change.  This is a list of the most notable packages that will be installed.

- [x11/xorg](https://www.freshports.org/x11/xorg): Obviously needed.
- [www/firefox](https://www.freshports.org/www/firefox/) Web browser.
- [x11/mate-desktop](https://www.freshports.org/x11/mate-desktop/) Default desktop environment.
- [ports-mgmt/octopkg](https://www.freshports.org/ports-mgmt/octopkg/) Package management GUI.
- [shells/fish/](https://www.freshports.org/shells/fish/) Shell.
- [mail/thunderbird](https://www.freshports.org/mail/thunderbird) E-mail client.
- [java/openjdk8](https://www.freshports.org/java/openjdk8/) Java runtime.
- [x11/alacritty](https://www.freshports.org/x11/alacritty/) A very nice terminal
- [editors/notepadnext](https://www.freshports.org/editors/notepadnext/) Just like Notepad++ on Windows
- [graphics/photoflare](https://www.freshports.org/graphics/photoflare/) MGI PhotoSuite Style Image Editor

It also goes on to install some GhostBSD packages that have been ported over such as utilities and themes.

Finally if the script detects that it's running inside of a VMware virtual machine it will trigger the install the Open VMware tools package as described at http://www.unibia.com/unibianet/freebsd/vmware-tools-smooth-mouse-clipboard-sharing-auto-resize-ghostbsd-103.

## Alernative Desktops

MATE is the officially supported desktop.  It receives the most amount of testing and iterative improvment since it's what I use everyday.  If you want to help in testing and submitting improvments/fixes for other desktops, you can try out these other isntaller scripts (not currently hosted on Github).

- [LXQT](http://ftp.morante.net/pub/FreeBSD/extra/desktop/freebsd-lxqt-desktop.sh)
- [XFCE](http://ftp.morante.net/pub/FreeBSD/extra/desktop/freebsd-xfce-desktop.sh)
- [KDE](http://ftp.morante.net/pub/FreeBSD/extra/desktop/freebsd-kde-desktop.sh)
- [Budgie](http://ftp.morante.net/pub/FreeBSD/extra/desktop/freebsd-budgie-desktop.sh) (un-tested, display corruption on VMWare)

### Screenshots

[![Screenshot1](http://download.morante.net/unibia/screenshots/freebsd/thumb/freebsd-lxqt-desktop-275px.jpg?gh)](http://download.morante.net/unibia/screenshots/freebsd/freebsd-lxqt-desktop.jpg)
[![Screenshot2](http://download.morante.net/unibia/screenshots/freebsd/thumb/freebsd-xfce-desktop-275px.jpg?gh)](http://download.morante.net/unibia/screenshots/freebsd/freebsd-xfce-desktop.jpg)
[![Screenshot3](http://download.morante.net/unibia/screenshots/freebsd/thumb/freebsd-kde-desktop-275px.jpg?gh)](http://download.morante.net/unibia/screenshots/freebsd/freebsd-kde-desktop.jpg)

To submit a bug/improvment, just open a Github issue.

## The Repository

Originally this was intended for personal use but quickly realized that others can benefit from my work.  It currently takes about 5 days to build all the packages in the FreeBSD ports tree.  Adding more repos and speeding up the build process is a matter of adding additional computing resources.  Perhaps if this find a decent enough following I may consider expanding it further by making a bootable graphical installer.

If you find this useful and want to show some appreciation the following options are available:

- Just say thanks: http://www.unibia.com/unibianet/contact
- Send some money: https://paypal.me/unibia
- Send some crypto: 
    - __(BTC) bitcoin:13ViU3NzRqgijMczSUeDR6NVQPW8Yv6QeY__
    - __(LTC) litecoin:Lhxjdf1DUPmnE2RAJdLrJZPJZ7VMubnVZp__  
    - __(ETC) 0xf3cef688864f17effc6a8ce52c5550d9b226f3c0__
