#!/bin/bash

sudo xcode-select -s /Applications/Xcode-9.4.1.app
make package FINALPACKAGE=1
sudo xcode-select -s /Applications/Xcode.app