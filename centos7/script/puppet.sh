#! /bin/sh
#
# This script install the puppet client or the
# puppet server based on the script parameter
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Tue Jan 27 00:39:54 CET 2015
#

# Set proxy if needed
# export http_proxy="http://proxy.example.com:8080"
# export https_proxy="http://proxy.example.com:8080"

# Get parameter
case $1 in
  "client") PUPPETTYPE=C;;
  "server") PUPPETTYPE=S;;
  *) echo "Wrong parameter, should be client or server"; exit 1;;
esac

# Setup repositories
sudo rpm -Uvh http://ftp.tu-chemnitz.de/pub/linux/fedora-epel/7/x86_64/e/epel-release-7-2.noarch.rpm
sudo rpm -Uvh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

# Update system (exclude kernel, otherwise vboxsf gets broken)
sudo yum clean all
sudo yum -y update --exclude=kernel*

# Install Puppet
sudo yum -y install puppet

# Install yum management
sudo puppet module install thbe-yum
sudo puppet apply -e 'class { "yum": }'

if [ "x$PUPPETTYPE" = "xS" ]; then
  # Install Puppet server
  sudo yum -y install puppetserver

  # Install Puppet DB
  sudo puppet module install puppetlabs-puppetdb
  sudo puppet apply -e 'class { "puppetdb": }'
  sudo puppet apply -e 'class { "puppetdb::master::config": puppetdb_server => "centos.thbe.local" }'
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
