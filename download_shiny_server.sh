#!/bin/bash

echo "+-----------------------------+"
echo "| AE5 Shiny Server Downloader |"
echo "+-----------------------------+"

[ $SHINY_VERSION ] || SHINY_VERSION=1.5.20.1002
echo "- Target version: ${SHINY_VERSION}"

if [[ ! -z "$TOOL_PROJECT_URL" && -d data ]]; then
   echo "- Downloading into the data directory"
   fdir=data/
fi

# TODO: RStudio downloader handles CentOS 7 and 8 downloads for older R. Needed for shiny?
# Currently using CentOS 7

fname=${fdir}ss-centos7.rpm
echo "- Downloading CentOS7 RPM file to $fname"
url=https://download3.rstudio.org/centos7/x86_64/shiny-server-${SHINY_VERSION}-x86_64.rpm
echo "- URL: $url"

if ! curl -o $fname -L $url; then
  echo "- unexpected error with curl"
elif grep -q NoSuchKey $fname; then
   echo "- bucket error downloading package"
   rm -f $fname
fi
  

if [ ! -f $fname ]; then
    echo "- ERROR: could not find package as expected. Please check URLs."
    exit -1
fi

if which rpm2cpio &>/dev/null; then
    echo "- Verifying $fname"
    if ! rpm2cpio $fname >/dev/null; then
        echo "- ERROR: $fname is not a valid RPM package. Please remove this file and re-download it."
        exit -1
    fi
fi 

echo "+------------------------+"
echo "The Shiny Server binaries have been downloaded."
if [ -z "$TOOL_PROJECT_URL" ]; then
    echo "Upload these files to your installer session to proceed."
else
    echo "You may now proceed with the installation step."
fi
echo "See the README.md file for more details."
echo "+------------------------+"
