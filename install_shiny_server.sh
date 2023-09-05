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
elif [ $SHINY_SERVER_PREFIX = /tools/shiny-server ]; then
    :
else
    echo "ERROR: Shiny Server must be installed in /tools/shiny-server"
    exit -1
fi


SHINY_SERVER_PARENT=$(dirname $SHINY_SERVER_PREFIX)
if [[ -d $SHINY_SERVER_PREFIX || $SHINY_SERVER_PREFIX != /tools/shiny-server ]]; then
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
