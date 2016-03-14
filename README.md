[![Build Status](https://circleci.com/gh/davedoesdev/dobby.svg?style=svg)](https://circleci.com/gh/davedoesdev/dobby) [![Successful builds with links to disk images](http://rawgit.davedoesdev.com/davedoesdev/dobby/master/builds.svg)](http://rawgit.davedoesdev.com/davedoesdev/dobby/master/.circle-ci/builds.html)

Dobby is a [Heddle](https://github.com/davedoesdev/heddle) extension, adding packages for [Salt](http://saltstack.com/community/), [Weave](http://weave.works/), [Fold](https://github.com/davedoesdev/fold), [nfdhcpd](https://github.com/davedoesdev/nfdhcpd) and their dependencies.

## Packages

### Salt

Salt is a configuration management, remote execution and orchestration system.

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

### Pre-built images

First you need a Dobby image. Every time a commit is made to this repository, Dobby is built on SemaphoreCI and CircleCI. Successful builds are listed [here](http://rawgit.davedoesdev.com/davedoesdev/dobby/master/.circle-ci/builds.html). For each build, you can download the following artifacts:

- Build output archive
  - `dobby-[commitid]-gpt-btrfs-x86_64.tar.xz`
- Build log
  - `dobby-[commitid]-log-x86_64.txt.xz`
- Source archive
  - `dobby-[commitid]-src-x86_64.tar`

Each build output archive contains the following files:

- `gen/x86_64/dist/dobby.img` - Raw bootable disk image, partitioned with GPT or MBR and using a Btrfs or Ext4 filesystem. GPT images require EFI to boot.
- `gen/x86_64/dist/boot_dobby.sh` - Shell script to boot the disk image in KVM.
- `gen/x86_64/dist/in_dobby.sh` - Shell script for automating [customisation of the disk image](https://github.com/davedoesdev/heddle#customising-heddle).
- `gen/x86_64/dist/update` - Directory containing files necessary to [update an existing Dobby installation](https://github.com/davedoesdev/heddle#updating-heddle) to this build.

`dobby.img` is a sparse file so you should extract the archive using a version of tar which supports sparse files, for example `bsdtar` or recent versions of GNU tar.

When writing `dobby.img` to a disk (or USB stick), using a program which supports sparse device writes will be faster than one which doesn't. For example, using [ddpt](http://sg.danny.cz/sg/ddpt.html) to write `dobby.img` to `/dev/sdb`:

```shell
ddpt if=dobby.img of=/dev/sdb bs=512 bpt=128 oflag=sparse
```

Don't worry that `dobby.img` doesn't fill the entire disk. Dobby detects this when it boots and resizes its main partition to fill the disk.

Once you've written `dobby.img` onto a disk, put the disk into a computer and boot it. You should see the normal Linux kernel boot messages and then a login prompt. There is one user account: `root` (password `root`). There are also two virtual terminals if you want two logon sessions.

The `shutdown` command stops all services, calls `sync`, remounts all filesystems read-only and then calls `poweroff`. To reboot instead, use `-r`. It waits for 7 seconds for services to exit. Use `-t` to change this timeout.

Alternatively, run `boot_dobby.sh` to run the image in KVM first. You'll get a login prompt and two virtual terminals like when booting on real hardware.

If you want to use a script to customise the image, see [Run-time customisation](https://github.com/davedoesdev/heddle#run-time-customisation).

Everything in the [Heddle README](https://github.com/davedoesdev/heddle) also applies to Dobby.

### Release builds

From time-to-time release branches will be forked from `master` and named `v0.0.1`, `v0.0.2` etc.

The [build list](http://rawgit.davedoesdev.com/davedoesdev/dobby/master/.circle-ci/builds.html) shows the branch name for each build and can also show only release builds (click the __Release branches__ radio button).

## Building Dobby

To build a Dobby image, follow the instructions for [extending Heddle](https://github.com/davedoesdev/heddle#extending-heddle). Remember to install the [build depedencies](https://github.com/davedoesdev/heddle#install-build-dependencies).

For example:

```shell
# fetch dobby
git clone https://github.com/davedoesdev/dobby.git
cd dobby
# fetch heddle
git clone https://github.com/davedoesdev/heddle.git
# fetch Aboriginal Linux
curl http://landley.net/aboriginal/downloads/aboriginal-1.4.5.tar.gz | tar -zx
# set extension path
export HEDDLE_EXT_DIR="$PWD"
# initialise dobby as heddle extension
./heddle/gen/new_arch.sh
# build Aboriginal linux
cd aboriginal-1.4.5
../heddle/aboriginal_scripts/config.sh
./build.sh x86_64
# build heddle and dobby packages
../heddle/image_scripts/make_build_and_home_images.sh
../heddle/aboriginal_scripts/build_heddle.sh
# prepare dobby
../heddle/image_scripts/make_run_and_extra_images.sh
../heddle/aboriginal_scripts/run_heddle.sh -p
# generate image
../heddle/image_scripts/make_dist_and_heddle_images.sh
../heddle/aboriginal_scripts/dist_heddle.sh
# image is in gen/x86_64/dist/dobby.img, boot it with
../gen/x86_64/dist/boot_dobby.sh
```
