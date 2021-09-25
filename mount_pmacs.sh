#!/bin/bash

# eg user@transfer.pmacs.upenn.edu
server=""

mountBase=${HOME}/pmacs

if [[ $# -eq 0 ]]; then
  echo "$0 [-u] <remote>

  Mounts remote dir on server

    $server

  to $mountBase

  eg

    $0 /project/ftdc_misc/pcook

  mounts to 

    ${mountBase}/project/ftdc_misc/pcook.

  Option -u unmounts.

  Use absolute paths.

"
  exit 1
fi

if [[ -z "$server" ]]; then
  echo " Edit script to set server eg username@transfer.pmacs.upenn.edu"
  exit 1
fi

unmount=0

while getopts "u" opt; do
  case $opt in
    u) unmount=1;;
    \?) echo "Unknown option $OPTARG"; exit 1;;
    :) echo "Option $OPTARG requires an argument"; exit 1;;
  esac
done

shift $((OPTIND-1))

# Remove trailing slash if present
remotePath=${1%/}

if [[ $remotePath == "/project" ]]; then
  echo "Do not mount /project"
  exit 1
fi

if [[ ! $remotePath =~ ^/ ]] ; then
  echo "Use absolute path for mount points"
  exit 1
fi

if [[ $unmount -eq 1 ]]; then
  umount ${mountBase}${remotePath}
  exit 0
fi

existingMounts=`mount | grep ${mountBase}${remotePath}`

if [[ -n "${existingMounts}" ]]; then
  echo "${remotePath} (or a subdirectory) is already mounted"
  exit 1
fi

# The actual directory to be mounted
mountDir=${remotePath##*/}

mkdir -p ${mountBase}${remotePath}

sshfs -o defer_permissions,noapplexattr,noappledouble,volname=${mountDir} ${server}:${remotePath} ${mountBase}${remotePath}
