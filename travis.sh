#!/bin/sh

if [["$TRAVIS_BRANCH" == "develop"]]; then
	fastlane test
	exit $?
fi