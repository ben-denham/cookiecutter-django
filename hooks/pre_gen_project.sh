#!/bin/bash
# Inspired by http://www.jeffknupp.com/blog/2013/12/18/starting-a-django-16-project-the-right-way/
# Created 16/01/2014 for Django 1.6 on Vagrant Ubuntu 12.04 LTS.
# Created by Ben Denham.

SHELL_CONFIG_FILE="/home/vagrant/.bashrc"
DEV_DIRECTORY="$(pwd)"

echo '-- Installing pre-requisite packages'
sudo apt-get install -yq python2.7 > /dev/null
sudo apt-get install -yq python-pip > /dev/null
sudo apt-get install -yq git > /dev/null
sudo apt-get install -yq pep8 > /dev/null
sudo apt-get install -yq libpq-dev

echo '-- Installing pre-requisite pip packages'
sudo pip install -q virtualenvwrapper

VIRTUALENV_CONFIG="
# Virtualenv config
export WORKON_HOME=\$HOME/.virtualenvs
export PROJECT_HOME=$DEV_DIRECTORY
source /usr/local/bin/virtualenvwrapper.sh"

if ! $(cat "$SHELL_CONFIG_FILE" | tr -d '\n' | grep -q "$(echo "$VIRTUALENV_CONFIG" | tr -d '\n')"); then
    echo "-- Adding Virtualenv config to shell config file."
    echo "$VIRTUALENV_CONFIG" >> "$SHELL_CONFIG_FILE"
fi