#!/bin/bash

pushd $HOME
mkdir octant
cd octant
wget https://github.com/vmware-tanzu/octant/releases/download/v0.16.3/octant_0.16.3_Linux-64bit.deb
sudo dpkg -i octant_0.16.3_Linux-64bit.deb
popd