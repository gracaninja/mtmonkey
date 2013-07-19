#!/bin/bash
#
# Linking directories for worker environment
#
# Assuming ~khresmoi/mt-$VERSION as the target directory
# and a shared directory $SHARE to be linked to, containing
# the following directories:
#
# moses-$VERSION/ = Moses installation directory
# virtualenv/ = Python virtual environment
#

if [[ -z "$VERSION" || -z "$SHARE" || -z "$USER" ]]; then
    echo "Usage: USER=khresmoi VERSION=<stable|dev> SHARE=/mnt/share prepare_worker.sh"
    exit 1
fi

cd /home/$USER
# copy virtualenv
cp -rL $SHARE/virtualenv virtualenv


# create the main MT directory
mkdir mt-$VERSION
cd mt-$VERSION

# Clone worker Git
git clone https://redmine.ms.mff.cuni.cz/khresmoi-mt.git git

# copy Moses
cp -rL $SHARE/moses-$VERSION moses

# create worker-local directories
mkdir config logs models

# link to Git directories
ln -s git/scripts
ln -s git/worker/src worker

# copy default config
cp git/config-example/* config