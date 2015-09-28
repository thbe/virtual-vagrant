#! /bin/sh
#
# This script install the puppet client or the
# puppet server based on the script parameter
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Tue Jan 27 00:39:54 CET 2015
#

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
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb

# Update system (exclude kernel, otherwise virtual optimization gets broken)
# echo linux-image-amd64 hold | sudo dpkg --set-selections
sudo apt-get clean all
sudo apt-get update
sudo apt-get -y dist-upgrade

# Install Puppet agent all in one package (4.x or newer)
sudo apt-get -y install puppet-agent

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
for item in $(ls -1 local_module/*.gz); do
  puppet module install /vagrant/$item
done
