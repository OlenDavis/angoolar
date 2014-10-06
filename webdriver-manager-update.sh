#!/bin/sh
cd node_modules/grunt-protractor-runner/node_modules/protractor/bin/
# cd node_modules/grunt-protractor-runner/node_modules/protractor
# rm -rf node_modules selenium
# npm install
if [ ! -f "../selenium/chromedriver" ]; then
	rm -rf ../selenium
	./webdriver-manager update
fi
# ./bin/webdriver-manager update
cd -
