#! /bin/sh
#
# This script launch the boot2docker instance
# using Vagrant
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Wed Mar  4 14:40:34 CET 2015
#

# Set path to ignore wired defaults
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

vagrant up --provider parallels
export DOCKER_HOST="tcp://`vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"`:2375"
docker version
bash
