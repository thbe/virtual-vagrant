#! /bin/sh
#
# This script install the puppet client or the
# puppet server based on the script parameter
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Tue Jan 27 00:39:54 CET 2015
#

### Not usable with SLES11, need to be adjusted! ###
exit 0

# Set proxy if needed
# export http_proxy="http://proxy.thbe.local:8080"
# export https_proxy="http://proxy.thbe.local:8080"

# Set path to ignore wired defaults
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Get parameter
case $1 in
  "client") PUPPETTYPE=C;;
  "server") PUPPETTYPE=S;;
  "clean") PUPPETTYPE=X;;
  *) echo "Wrong parameter, should be client or server"; exit 1;;
esac

# Setup repositories
sudo rpm -Uvh http://vesta.informatik.rwth-aachen.de/ftp/pub/Linux/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo rpm -Uvh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Update system (exclude kernel, otherwise vboxsf gets broken)
sudo yum clean all
sudo yum -y update --exclude=kernel*

# Install Puppet
sudo yum -y install puppet

# Exit if clean setup needed
if [ "x$PUPPETTYPE" = "xX" ]; then exit 0; fi

# Install yum management
sudo puppet module install thbe-yum
sudo puppet apply -e 'class { "yum": }'

if [ "x$PUPPETTYPE" = "xS" ]; then
  # Install Puppet server
  sudo yum -y install puppetserver

  # Install Puppet DB
  sudo puppet module install puppetlabs-puppetdb
  sudo puppet apply -e 'class { "puppetdb": }'
  sudo puppet apply -e 'class { "puppetdb::master::config": puppetdb_server => "puppet.thbe.local" }'
  #sudo puppet resource package puppetdb ensure=latest
  #sudo puppet resource service puppetdb ensure=running enable=true

  # Install Puppet Dashboard
  sudo puppet module install puppetlabs-mysql
  sudo puppet module install puppetlabs-dashboard
  sudo yum -y install puppet-dashboard
fi

# Install Mcollective
sudo puppet module install puppetlabs-mcollective
if [ "x$PUPPETTYPE" = "xS" ]; then
  echo "Install Mcollective server"
else
  echo "Install Mcollective client"
fi

# Install personal style
sudo puppet module install thbe-style
sudo puppet apply -e 'class { "style": }'
