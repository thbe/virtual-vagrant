# == Class: baseconfig
#
# Performs initial configuration tasks for Vagrant boxes.
# This one is only a dummy to verify the correct box setup
# in conjunction with Puppet
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  include baseconfig
#
# === Authors
#
# Thomas Bendler <project@bendler-net.de>
#
# === Copyright
#
# Copyright 2014 Thomas Bendler, unless otherwise noted.
#
class baseconfig {
  #  exec { 'yum -y update':
  #    command => '/usr/bin/yum -y update';
  #  }

  #  host { 'hostmachine':
  #    ip => '192.168.0.1';
  #  }

  file { '/home/vagrant/.bashrc':
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0644',
    source => 'puppet:///modules/baseconfig/bashrc';
  }
}
