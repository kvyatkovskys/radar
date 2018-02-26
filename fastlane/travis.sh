#!/bin/sh

if [ "$TRAVIS_BRANCH" = "develop" -a "$TRAVIS_PULL_REQUEST" = "false" ]; then
	fastlane test
	exit $?
fi

if [ "$TRAVIS_BRANCH" = "master" -a "$TRAVIS_PULL_REQUEST" = "true" ]; then
	fastlane test
	exit $?
fi	