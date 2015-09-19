[![Build Status](https://circleci.com/gh/davedoesdev/dobby.svg?style=svg)](https://circleci.com/gh/davedoesdev/dobby) [![Successful builds with links to disk images](http://rawgit.davedoesdev.com/davedoesdev/dobby/master/builds.svg)](http://rawgit.davedoesdev.com/davedoesdev/dobby/master/.circle-ci/builds.html)

Dobby is a [Heddle](https://github.com/davedoesdev/heddle) extension, adding packages for [Salt](http://saltstack.com/community/), [Weave](http://weave.works/), [Fold](https://github.com/davedoesdev/fold), [nfdhcpd](https://github.com/davedoesdev/nfdhcpd) and their dependencies.

## Packages

### Salt

Satl is a configuration management, remote execution and orchestration system.

If the machine's hostname is `salt` or starts with `salt-master` then Dobby runs `salt-master`.

If the machine's hostname starts with `salt-minion` or `salt-master-minion` then Dobby runs `salt-minion`.

Dobby runs Salt with default configuration. For example, minions look for the master at DNS name `salt`. See the [Salt documentation](https://docs.saltstack.com/en/latest/) if you want to change this. The [walkthrough](https://docs.saltstack.com/en/latest/topics/tutorials/walkthrough.html) is a good place to start.

When Dobby runs `salt-minion`, it displays the minion's ID and public key fingerprint to the console and serial port.

### Weave

Weave creates a virtual network between Docker containers and, with Fold, between virtual machines.

Dobby runs `weave` with default configuration. To run `weave` with different arguments, edit `chroot/service/weave/run`.

### Fold

Fold runs virtual machines on a Weave virtual network.

The `fold` command is available on the `PATH` in `/home/install/bin/fold`.

### nfdhcpd

`nfdhcpd` is an DHCP, DHCPv6 and IPv6 Router and Neighbour Solicitation server for virtual machines. It's used by Fold to configure virtual machines and add them to a Weave virtual network.

Dobby runs `nfdhcpd` with default configuration. to run `nfdhcpd` with different configuration, use Heddle's [customisation options](https://github.com/davedoesdev/heddle#customising-heddle) to update `/home/install/etc/nfdhcpd.conf` in the image.

## Installing Dobby

Coming soon...

## Building Dobby

Coming soon...


