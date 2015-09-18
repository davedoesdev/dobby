#!/bin/bash
set -e

version="$(git rev-parse --abbrev-ref HEAD)"
if [ "$version" = master -o "$version" = HEAD ]; then
  version="$(git rev-parse HEAD)"
fi
echo "version: $version"

export HEDDLE_EXT_DIR="$PWD"
git clone 'https://github.com/davedoesdev/heddle.git'

cd aboriginal-*
( while true; do echo keep alive!; sleep 60; done ) &

build() {
  ../heddle/gen/new_arch.sh || return 1
  ../heddle/image_scripts/make_build_and_home_images.sh || return 1
  ../heddle/aboriginal_scripts/build_heddle.sh -c
}
logf="dobby-$version-log-x86_64.txt"
if ! build >& "../$logf"; then
  tail -n 1000 "../$logf"
  exit 1
fi
cd ..
tail -n 100 "$logf"
sudo rm -rf /tmp/chroot/home/source
df -h
mkdir /tmp/home
# mount home without recursive bind to get rid of its chroot bind mounts
sudo mount -o bind /tmp/chroot/home /tmp/home
homef="dobby-$version-home-x86_64.tar.gz"
sudo tar --owner root --group root -zcf "$homef" "$logf" -C /tmp home
ls -lh "$homef"
