#!/bin/bash

echo "+----------------------------+"
echo "| AE5 Shiny Server Installer |"
echo "+----------------------------+"

if [[ -z "$TOOL_PROJECT_URL" || -z "$TOOL_HOST" || -z "$TOOL_OWNER" ]]; then
    echo 'ERROR: this script must be run within an AE5 session.'
    exit -1
elif ! grep -q /tools/ /opt/continuum/scripts/start_user.sh; then
    echo 'ERROR: this version of the Shiny Server Installer requires AE5.5.1 or later.'
    exit -1
elif [ -z "$SHINY_SERVER_PREFIX" ]; then
    SHINY_SERVER_PREFIX=/tools/shiny-server
fi

SHINY_SERVER_PARENT=$(dirname $SHINY_SERVER_PREFIX)
if [[ -d $SHINY_SERVER_PREFIX ]]; then
    if [ ! -d $SHINY_SERVER_PREFIX ]; then
        echo "The directory $SHINY_SERVER_PREFIX is missing. Please add this volume"
        echo "to your configuration, then stop and restart this session."
        exit -1
    elif [ ! -w $SHINY_SERVER_PREFIX ]; then
        echo "The directory $SHINY_SERVER_PREFIX is readonly. Please ensure that its"
        echo "volume is set to read-write, then stop and restart this session."
        exit -1
    elif [ ! -z "$(ls -A $SHINY_SERVER_PREFIX)" ]; then
        echo "The directory $SHINY_SERVER_PREFIX is not empty. To prevent overwriting an"
        echo "existing installation, the script expects this directory to be empty."
        echo "Please manually remove the contents before proceeding."
        ls -A $SHINY_SERVER_PREFIX
        exit -1
    fi
elif [ ! -d $SHINY_SERVER_PARENT ]; then
    echo "ERROR: The directory $SHINY_SERVER_PARENT is missing. Please follow the instructions"
    echo "in README.md to create this volume, and stop and restart this session."
    exit -1
elif [ ! -w $SHINY_SERVER_PARENT ]; then
    echo "ERROR: The directory $SHINY_SERVER_PARENT is readonly. Please follow the instructions"
    echo "in README.md to set it to read-write, and stop and restart this session."
    exit -1
fi


if [[ ! -f ss-centos7.rpm && ! -f data/ss-centos7.rpm ]]; then
    echo 'ERROR: the Shiny Server binaries are not present. Please follow the'
    echo 'directions in README.md to bring these binaries into the project.'
    exit -1
fi

fname=ss-centos7.rpm
[ -f $fname ] || fname=data/$fname
echo "- Verifying $fname"
if ! rpm2cpio $fname >/dev/null; then
    echo "- ERROR: $fname is not a valid RPM package. Please remove this file and re-download it."
    exit -1
fi

echo "- Install prefix: $SHINY_SERVER_PREFIX"


echo "- Staging RHEL7/CentOS7 binary"
mkdir -p $SHINY_SERVER_PREFIX/staging7
fname=ss-centos7.rpm
[ -f $fname ] || fname=data/$fname
rpm2cpio $fname > $SHINY_SERVER_PREFIX/staging7/ss-centos7.cpio
cd $SHINY_SERVER_PREFIX/staging7 && cpio -id < $SHINY_SERVER_PREFIX/staging7/ss-centos7.cpio

echo "- Moving files into final position"
mv $SHINY_SERVER_PREFIX/staging7/opt/shiny-server/* $SHINY_SERVER_PREFIX
rm -rf $SHINY_SERVER_PREFIX/staging7

echo "- Installing support files"
cp /opt/continuum/project/shiny-server.conf.jinja2  $SHINY_SERVER_PREFIX

echo "+-----------------------+"
echo "Shiny Server installation is complete."
echo "Once you have verified the installation, feel free to"
echo "shut down this session and delete the project."
echo "+-----------------------+"
[ -z "$CONDA_PREFIX" ] || source deactivate
java_loc=$(which java 2>/dev/null)
if [ -z "$java_loc" ]; then
    echo "WARNING: Many R packages make use of Java, and it seems"
    echo "not to be present on this installation of AE5. To make"
    echo "Java available to all AE5 users, run install_java.sh, or"
    echo "manually download a JDK Linux x64 archive and unpack its"
    echo "contents into the directory /tools/java."
echo "+-----------------------+"
fi
