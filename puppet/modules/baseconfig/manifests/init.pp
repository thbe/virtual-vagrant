# == Class: baseconfig
#
# Performs initial configuration tasks for all Vagrant boxes.
#
class baseconfig {
#  exec { 'yum -y update':
#    command => '/usr/bin/yum -y update';
#  }

#  host { 'hostmachine':
#    ip => '192.168.0.1';
#  }

  file {
    '/home/vagrant/.bashrc':
      owner => 'vagrant',
      group => 'vagrant',
      mode  => '0644',
      source => 'puppet:///modules/baseconfig/bashrc';
  }
}
