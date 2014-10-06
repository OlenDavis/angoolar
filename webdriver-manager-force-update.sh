#!/bin/sh
cd node_modules/grunt-protractor-runner/node_modules/protractor/bin/
rm -rf ../selenium
./webdriver-manager update
cd -
