#!/bin/bash
set -e

mkdir -p downloads
echo +downloads:
ls downloads

ver_abo=1.4.1
ver_bat=4.0.2

abo_base="downloads/aboriginal-$ver_abo"
abo_seal="$abo_base.seal"
abo_file="$abo_base.tar.gz"

bat_base="downloads/build-aboriginal-$ver_abo-dobby-x86_64-$ver_bat"
bat_seal="$bat_base.seal"
bat_file="$bat_base.tar.xz"

if [ ! -f "$abo_seal" ]; then
  curl -L -o "$abo_file" "https://github.com/davedoesdev/build-aboriginal-travis/releases/download/v$ver_bat/aboriginal-$ver_abo.tar.gz"
  touch "$abo_seal"
fi

if [ ! -f "$bat_seal" ]; then
  curl -L -o "$bat_file" "https://github.com/davedoesdev/build-aboriginal-travis/releases/download/v$ver_bat/build-aboriginal-$ver_abo-dobby-x86_64.tar.xz"
  touch "$bat_seal"
fi

rm -rf aboriginal-* dobby
bsdtar -Jxf "$bat_file"
mkdir gen
mv dobby/gen/build.img gen
rm -rf dobby

find downloads -mindepth 1 -not -path "$abo_base.*" -not -path "$bat_base.*" -exec rm -v {} \;
echo -downloads:
ls downloads
