#! /bin/bash

rm -rf build/0.9.1/

cd ./src/

#love-release -lmw --osx-icon ../presskit/mac_icon.iscns --win-icon ../presskit/SH_headIcon.ico --osx-maintainer-name wilbefast -n hugly -r ../build/ . 
love-release -lmw --osx-maintainer-name wilbefast -n hugly -r ../build/ . 

rm -f hugly-win32.zip
rm -f hugly-win64.zip
rm -f hugly-macosx-x64.zip

cd ..
cp README.md build/0.9.1/
cd build/0.9.1/

# Add readme
zip -g hugly-macosx-x64.zip README.md
zip -g hugly-win32.zip README.md
zip -g hugly-win64.zip README.md

# Zip love version
mkdir hugly-love
cp hugly.love hugly-love
cp README.md hugly-love
cp manual.pdf hugly-love
zip -r hugly-love.zip hugly-love/
rm -rf hugly-love