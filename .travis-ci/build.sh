#!/bin/bash
set -e

version="$TRAVIS_BRANCH"
if [ "$version" = master ]; then
  version="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$version" = master -o "$version" = HEAD ]; then
    version="$(git rev-parse HEAD)"
  fi
fi
echo "version: $version"

export HEDDLE_EXT_DIR="$PWD"

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
# mount home without recursive bind to get rid of its xroot bind mounts
sudo mount -o bind /tmp/chroot/home /tmp/home
homef="dobby-$version-home-x86_64.tar.gz"
sudo tar --owner root --group root -zcf "$homef" "$logf" -C /tmp home
ls -lh "$homef"

hmac() {
  SECRET="$1" node 3<&0 << 'EOF'
var hmac = require('crypto').createHmac('sha256', process.env.SECRET);
require('fs').createReadStream(null, {fd: 3}).pipe(hmac);
var t = new require('stream').Transform();
t._transform = function (data, encoding, callback)
{
    this.push(data.toString('hex'));
    callback();
};
hmac.pipe(t);
t.pipe(process.stdout);
EOF
}

txf() {
  URL="$1" node 3<&0 << 'EOF'
var opts = require('url').parse(process.env.URL);
opts.method = 'PUT';
var fs = require('fs');
fs.createReadStream(null, {fd: 3}).pipe(require('http').request(opts, function (res)
{
    var fd;
    if (res.statusCode === 200)
    {
        process.exitCode = 0;
        fd = 1;
    }
    else
    {
        console.error('error', res.statusCode);
        process.exitCode = 1;
        fd = 2;
    }
    var s = fs.createWriteStream(null, {fd: fd});
    s.on('finish', function ()
    {
        process.exit(process.exitCode);
    });
    res.pipe(s);
}));
EOF
}

txf_url() {
  echo "http://txf-davedoesdev.rhcloud.com/default/$(echo -n "$1" | hmac "$DEFAULT_SENDER_SECRET")/$1"
}

mac="$(hmac "$INTEGRITY_SECRET" < "$homef")"

while ! txf "$(txf_url "dobby-$version")" < "$homef"; do sleep 1; done
while ! echo -n "$mac" | txf "$(txf_url "dobby-$version.mac")"; do sleep 1; done
