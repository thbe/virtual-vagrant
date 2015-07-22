#virtual-vagrant

####Table of Contents

1. [Overview](#overview)
2. [Repository Description - What the repository does and why it is useful](#repository-description)
3. [Setup - The basics of getting started with virtual vagrant](#setup)
    * [Prerequisites](#prerequesites)
    * [Beginning with virtual Vagrant](#beginning-with-virtual-vagrant)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the repository is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


##Overview

This repository contain Vagrant files to setup some major Linux test environments.


##Repository Description

The virtual Vagrant repository contain Vagrant files setup Vagrant boxes on your
preferred virtual provider. It also prepare the boxes to act as a puppet client or server
as well as scripts for packer that generate the boxes from scratch if you need boxes
beside virtual box.


##Setup

###Prerequisites

* Virtual platform like Virtual Box or Parallels
* Vagrant
* Optional you need packer if you want to create the boxes by yourself

###Beginning with virtual Vagrant

This example shows how to start a Vagrant box (i.e. centos6 for parallels):

```shell
cd virtual-vagrant/centos-7/
vagrant up --provider parallels
```


##Usage

To start a vagrant box you need to choose which one you want to start and what virtualization software
you are using. Assuming you want to start CentOS 7 on Parallels, the command will be:

```shell
cd virtual-vagrant/centos-7/
vagrant up --provider parallels
```


##Reference

###Sizing virtual machines

The sizing of the virtual machines is based on my local test scenarios. So all machines are equipped with
two processors and 4GB RAM. It make sense to reduce or increase the values based on the local hardware that
is used for the Vagrant machines.

###Create your own base box

This example shows howto create your own base box (CentOS 6 for Paralllels) using packer:

```shell
cd virtual-vagrant/packer/centos-6-x86_64/
packer build -only=parallels-iso template.json
cd ../../centos6/
vagrant box add thbe-centos6x file:///../packer/centos-6-x86_64/packer_parallels-iso_parallels.box
vagrant up
```


##Limitations

t.b.d.


##Development

If you like to add or improve this repository, feel free to fork the repository and send
me a merge request with the modification.
