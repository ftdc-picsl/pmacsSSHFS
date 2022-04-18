#!/bin/bash -e

# eg user@transfer.pmacs.upenn.edu
server=""

mountBase=${HOME}/pmacs

if [[ $# -eq 0 ]]; then
  echo "
  $0 <remote_dir>    : Mounts remote dir on server

  $0 -u <remote_dir> : Unmounts remote dir

  $0 -l              : List current mounts on server

  $0 -U              : Unmounts all directories from server

  Edit the script to change the server, which is currently $server

  Server format should be user@transfer.pmacs.upenn.edu

  Mount points are placed under $mountBase

  eg

    $0 /project/ftdc_misc/pcook

  mounts to 

    ${mountBase}/project/ftdc_misc/pcook.

  Use absolute paths to mount or unmount.

"
  exit 1
fi

if [[ -z "$server" ]]; then
  echo " Edit script to set server eg username@transfer.pmacs.upenn.edu"
  exit 1
fi


function listMounts {
  echo "
Mount base directory is ${mountBase}"
  echo "
Mount points:"
  mount | grep "on ${mountBase}"
  echo
}

function unmountAll {
  mounts=($(mount | grep "on ${mountBase}" | cut -d ' ' -f 3))

  for m in "${mounts[@]}"; do
    umount $m
  done
}

unmount=0

while getopts "Ulu" opt; do
  case $opt in
    U) unmountAll; exit 0;;
    l) listMounts; exit 0;;
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

existingMounts=$(mount | grep " on ${mountBase}${remotePath}") || true

if [[ -n "${existingMounts}" ]]; then
  echo "${remotePath} (or a subdirectory) is already mounted"
  exit 1
fi

# The actual directory to be mounted
mountDir=${remotePath##*/}

mkdir -p ${mountBase}${remotePath}

sshfs -o defer_permissions,noapplexattr,noappledouble,volname=${mountDir} ${server}:${remotePath} ${mountBase}${remotePath}
