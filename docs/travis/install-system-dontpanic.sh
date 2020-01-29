#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

VERSION=1.00

if [ "$ALIEN_INSTALL_TYPE" == "system" ]; then

  cd `mktemp -d`
  curl -LO https://github.com/Perl5-Alien/dontpanic/archive/$VERSION.tar.gz
  tar xvf $VERSION.tar.gz
  cd dontpanic-$VERSION
  ./configure --prefix=$HOME/opt/dontpanic/$VERSION
  make
  make install
  ln -s $HOME/opt/dontpanic/$VERSION $HOME/opt/dontpanic/current

fi
