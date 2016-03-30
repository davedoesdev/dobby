#!/bin/bash
set -e

mkdir -p downloads
echo +downloads:
ls downloads

ver_abo=1.4.5
ver_bat=6.0.2
ver_home=af155d650dab6ca255e5e245a6644b0b2a756c56

bat_base="downloads/build-aboriginal-$ver_abo-dobby-x86_64-$ver_bat"
bat_seal="$bat_base.seal"
bat_file="$bat_base.tar.xz"

home_base="downloads/heddle-$ver_home-home-x86_64"
home_seal="$home_base.seal"
home_file="$home_base.tar.gz"

if [ ! -f "$bat_seal" ]; then
  curl -L -o "$bat_file" "https://github.com/davedoesdev/build-aboriginal-travis/releases/download/v$ver_bat/build-aboriginal-$ver_abo-dobby-x86_64.tar.xz"
  touch "$bat_seal"
fi

if [ ! -f "$home_seal" ]; then
  curl -L -o "$home_file" "https://github.com/davedoesdev/heddle/releases/download/home-$ver_home/heddle-$ver_home-home-x86_64.tar.gz"
  touch "$home_seal"
fi

rm -rf aboriginal-* heddle dobby
bsdtar -Jxf "$bat_file"
mkdir gen
mv dobby/gen/build.img gen
rm -rf dobby
git clone 'https://github.com/davedoesdev/heddle.git'
(cd heddle && git checkout "$ver_home")
bsdtar -C heddle -zxf "$home_file"

find downloads -mindepth 1 -not -path "$bat_base.*" -not -path "$home_base.*" -exec rm -v {} \;
echo -downloads:
ls downloads

