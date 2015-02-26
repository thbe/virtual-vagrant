#!/bin/bash

# Bail if we are not running inside Parallels.
[ `facter virtual` == "parallels" ] || {
  exit 0
}

# Install the Parallels Tools

mkdir -p /mnt/parallels
mount -o loop /home/vagrant/prl-tools-lin.iso /mnt/parallels

/mnt/parallels/install --install-unattended-with-deps --progress

umount /mnt/parallels

rm -rf /home/vagrant/prl-tools-lin.iso
