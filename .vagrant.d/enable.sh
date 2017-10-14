#!/bin/bash
#
# This script used to enable default Vagrantfile by create softlink to ~/.vagrant.d/

DIR=$(cd "$(dirname "$0")"; pwd)

function make_softlink() {
  if [ -d "$2" ] || [ -f "$2" ]; then
    read -n 1 -p "File \"$2\" exists, replace it? [y]/n" yon
    if [ $yon = "y" ]; then
      ln -fs $1 $2
      echo -e "\nSoftlink from \"$1\" to \"$2\" created."
    else
      echo -e "\n\"$2\" untouched."
    fi
  else
    ln -s $1 $2
    echo -e "\nSoftlink from \"$1\" to \"$2\" created."
  fi
}

make_softlink $DIR/Vagrantfile ~/.vagrant.d/Vagrantfile
make_softlink $DIR/scripts ~/.vagrant.d/scripts
