# FreeBSD Desktop with MATE

This is an installation script for a FreeBSD based MATE desktop. See http://www.unibia.com/unibianet/freebsd/mate-desktop for additional information.

__Note: Use the link (http://k.itty.cat/7) to always get the latest version of the installation script.__

#### Disclaimers and Warnings

* It makes use of a custom package repository (https://pkg.ny-us.morante.net). 
* The `security/ca_root_nss` package is altered to include the [TDMC/Pacy World, LLC. root CA](http://www.pacyworld.com/ca.php).
* I do not make any guarantee that latest security updates will be readily available.
* The integrity of this repository is currently not being validated.

## Quick Start

It's recommended that you start with a clean install of FreeBSD 12.0 64-bit.  Your non-root user
should belong to the `operator` and `wheel` group so that it can perform administrative functions.

```
fetch -o - http://k.itty.cat/7 | sh
```

After about 30 minutes (depending on your Internet connection) your system will automatically
reboot into a graphical desktop.

## Requirements

Platform options are limited only due to lack of packages.

- FreeBSD 12.0-RELEASE
- 64-bit edition (amd64)
- 20 GB free space
- Internet connection

## About

This is inspired by GhostBSD.  GhostBSD was a FreeBSD desktop distribution that originally used FreeBSD as it's base.  After several years GhostBSD switch it's base to TrueOS.  While GhostBSD continues to be a great desktop I require (and prefer) a FreeBSD base system. I created this installation script and the corresponding PKG repository to fill the gap left by GhostBSD.

## How it Works

A custom PKG repo is built using [ports-mgmt/poudriere](https://www.freshports.org/ports-mgmt/poudriere). It uses the default FreeBSD ports tree and merges it with some additional custom developed packages.  Here is the `make.conf` file used for this repository.

```
# Allows us to build ports non-interactively
DISABLE_LICENSES=yes

# Desktop Specific Options
sysutils_gksu_UNSET+=NAUTILUS
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

It also goes on to install some GhostBSD packages that have been ported over such as utilities and themes.

Finally if the script detects that it's running inside of a VMware virtual machine it will trigger the install the Open VMware tools package as described at http://www.unibia.com/unibianet/freebsd/vmware-tools-smooth-mouse-clipboard-sharing-auto-resize-ghostbsd-103.

## The Repository

It currently takes about 5 days to build all the packages in the FreeBSD ports tree.
