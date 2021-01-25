#!/bin/bash
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

GPG_VER=$(gpg --version | head -n1 | grep -E -o "[0-9.]+")

cd ~/.ssh

if [ $(version $GPG_VER) -ge $(version "2.1.17") ]; then
    gpg --full-generate-key
else
    gpg --default-new-key-algo rsa4096 --gen-key
fi
