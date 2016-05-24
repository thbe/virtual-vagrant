#! /bin/sh
#
# This script install the puppet client or the
# puppet server based on the script parameter
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Tue May 24 13:42:17 CEST 2016
#

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
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

# Update system (exclude kernel, otherwise virtual optimization gets broken)
sudo yum clean all
sudo yum -y update --exclude=kernel*

# Install Puppet agent all in one package (4.x or newer)
sudo yum -y install puppet-agent

# Install personal style
sudo /opt/puppetlabs/bin/puppet module install thbe-style
sudo /opt/puppetlabs/bin/puppet apply -e 'class { "style": }'

# Exit if clean setup needed
if [ "x$PUPPETTYPE" = "xX" ]; then exit 0; fi

# Install yum management
sudo /opt/puppetlabs/bin/puppet module install thbe-yum
sudo /opt/puppetlabs/bin/puppet apply -e 'class { "yum": }'

if [ "x$PUPPETTYPE" = "xS" ]; then
  # Install Puppet server
  sudo yum -y install puppetserver

  # Install Puppet DB
  sudo /opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb
  sudo /opt/puppetlabs/bin/puppet apply -e 'class { "puppetdb": }'
  sudo /opt/puppetlabs/bin/puppet apply -e 'class { "puppetdb::master::config": puppetdb_server => "puppet.thbe.local" }'
  #sudo /opt/puppetlabs/bin/puppet resource package puppetdb ensure=latest
  #sudo /opt/puppetlabs/bin/puppet resource service puppetdb ensure=running enable=true

  # Install Puppet Dashboard
  sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mysql
  sudo /opt/puppetlabs/bin/puppet module install puppetlabs-dashboard
  sudo yum -y install puppet-dashboard
fi

# Install Mcollective
sudo /opt/puppetlabs/bin/puppet module install puppetlabs-mcollective
if [ "x$PUPPETTYPE" = "xS" ]; then
  echo "Install Mcollective server"
else
  echo "Install Mcollective client"
fi

# Check if local puppet modules exist and install them
for item in /home/vagrant/sync/puppet/*.gz; do
  if [ -r $item ]; then
    puppet module install $item
  fi
done
