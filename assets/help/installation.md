---
# Installation
---

## Web

ConvertAll can be run online without an installation.  See
<http://convertall-web.bellz.org> to try it out.

---

## Android

ConvertAll can be installed from Google Play,
[here](https://play.google.com/store/apps/details?id=org.bellz.convertall).

Alternatively, an APK file (convertall_x.x.x.apk) is provided that can be
downloaded to an Android device and run.

---

## Linux

Extract the files from the archive (convertall_x.x.x.tar.gz) into a user-owned
directory.  You need to have at least 2GB of disk space available for the
automated build.  Then change to the `ConvertAll` directory in a terminal, and
run the following commands:

    $ sudo ./ca_make.sh depends
    $ ./ca_make.sh build
    $ sudo ./ca_make.sh install

The first command automatically installs dependencies using the `apt-get`,
`dnf` or `pacman` native packaging system.  If desired, you can manually
install the dependencies in the [Requirements](requirements.md) section and
skip this line.

The second line (build) downloads Flutter and builds ConvertAll.

The third line (install) copies the necessary files into directories under
`/opt`.  After this step, the temporary `ConvertAll` build directory can be
deleted.

---

## Windows

The simplest approach is to download the "convertall_x.x.x.zip" file and
extract all of its contents to an empty folder.  Then run the "convertall.exe"
file.

To compile ConvertAll from source, install the ConvertAll source from
<https://github.com/doug-101/ConvertAll>.  Also install Flutter based on the
instructions in <https://docs.flutter.dev/get-started/install/linux>.  The
Android Setup is not required - just the Linux setup from the bottom of the
page.
