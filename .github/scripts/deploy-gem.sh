#!/bin/sh -l
GITHUB_TOKEN=$1
OWNER=$2

#--DEBUG
echo "GITHUB_TOKEN=$GITHUB_TOKEN"
echo "OWNER=$OWNER"

echo "Verifying the version matches the gem version"
VERSION_TAG=$(echo $GITHUB_REF | cut -d / -f 3)
GEM_VERSION=$(ruby -e "require 'rubygems'; gemspec = Dir.entries('.').find { |file| file =~ /.*\.gemspec/ }; spec = Gem::Specification::load(gemspec); puts spec.version")

echo "VERSION_TAG=$VERSION_TAG"
echo "GEM_VERSION=$GEM_VERSION"

echo "Setting up access to Github Package Registry"
mkdir -p ~/.gem
touch ~/.gem/credentials
chmod 600 ~/.gem/credentials
echo ":github: Bearer ${GITHUB_TOKEN}" >> ~/.gem/credentials

echo "Building the gem"
gem build *.gemspec
echo "Pushing the gem to Github Package Registry"
gem push --key github --host "https://rubygems.pkg.github.com/${OWNER}" *.gem