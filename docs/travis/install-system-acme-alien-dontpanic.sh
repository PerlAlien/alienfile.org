#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

cd `mktemp -d`
git clone --depth 2 https://github.com/Perl5-Alien/Acme-Alien-DontPanic.git .
cpanm --installdeps -n .
perl Build.PL
./Build
./Build install
