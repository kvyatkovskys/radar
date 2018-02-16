#!/bin/sh

if [["$TRAVIS_BRANCH" == "develop"]]; then
	fastlane test
	exit $?
fi

if [["$TRAVIS_PULL_REQUEST" != false]]; then
	fastlane test
	exit $?
fi	