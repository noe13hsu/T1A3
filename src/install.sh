#! /bin/bash
echo "Hello Word!"
echo "Preparing to install required gems"
rm Gemfile.lock
gem install bundler
bundle install
echo "Gem installation completed"