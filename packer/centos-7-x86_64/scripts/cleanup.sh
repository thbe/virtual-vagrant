#!/bin/bash

# Clean up unneeded packages.
yum -y clean all

# Ensure that udev doesn't screw us with network device naming.
ln -sf /dev/null /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
sed -i '/^UUID/d'   /etc/sysconfig/network-scripts/ifcfg-enp0s3
sed -i '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3

# Cleanup log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# remove under tmp directory
rm -rf /tmp/*
