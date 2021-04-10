#! /bin/bash
echo "Hello Word!"
echo "Preparing to install required gems"
rm Gemfile.lock
bundle install
echo "Gem installation completed"