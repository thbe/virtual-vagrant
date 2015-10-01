#! /bin/sh
#
# This script install the puppet client or the
# puppet server based on the script parameter
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Tue Sep 29 16:52:05 CEST 2015
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
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb

# Set proxy for apt if required
#if [ ! -z $http_proxy ]; then
#  echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/99vagrant
#fi

# Update system (exclude kernel, otherwise virtual optimization gets broken)
echo "linux-generic-lts-utopic hold" | sudo dpkg --set-selections
echo "linux-image-generic-lts-utopic hold" | sudo dpkg --set-selections
sudo apt-get clean all
sudo apt-get update
sudo apt-get -y dist-upgrade

# Install Puppet agent all in one package (4.x or newer)
sudo apt-get -y install puppet

# Set proxy for puppet if required
#if [ ! -z $http_proxy ]; then
#  PROXY_HOST=$(echo $http_proxy | cut -d '/' -f3 | cut -d ':' -f1)
#  PROXY_PORT=$(echo $http_proxy | cut -d '/' -f3 | cut -d ':' -f2)
#  echo "" >> /etc/puppet/puppet.conf
#  echo "[user]" >> /etc/puppet/puppet.conf
#  echo "http_proxy_host = ${PROXY_HOST}" >> /etc/puppet/puppet.conf
#  echo "http_proxy_port = ${PROXY_PORT}" >> /etc/puppet/puppet.conf
#fi

# Install personal style
sudo puppet module install thbe-style
sudo puppet apply -e 'class { "style": }'

# Exit if clean setup needed
if [ "x$PUPPETTYPE" = "xX" ]; then exit 0; fi

# Install yum management
sudo puppet module install thbe-yum
sudo puppet apply -e 'class { "yum": }'

if [ "x$PUPPETTYPE" = "xS" ]; then
  # Install Puppet server
  sudo apt-get -y install puppetmaster

  # Install Puppet DB
  sudo puppet module install puppetlabs-puppetdb
  sudo puppet apply -e 'class { "puppetdb": }'
  sudo puppet apply -e 'class { "puppetdb::master::config": puppetdb_server => "puppet.thbe.local" }'
  #sudo puppet resource package puppetdb ensure=latest
  #sudo puppet resource service puppetdb ensure=running enable=true

  # Install Puppet Dashboard
  sudo puppet module install puppetlabs-mysql
  sudo puppet module install puppetlabs-dashboard
  sudo apt-get -y install puppet-dashboard
fi

# Install Mcollective
sudo puppet module install puppetlabs-mcollective
if [ "x$PUPPETTYPE" = "xS" ]; then
  echo "Install Mcollective server"
else
  echo "Install Mcollective client"
fi

# Check if local puppet modules exist and install them
for item in $(ls -1 local_module/*.gz); do
  [[ -e $item ]] || break  # handle the case of no *.gz files
  puppet module install /vagrant/$item
done
