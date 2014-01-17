#!/bin/bash
echo '-- Installing pre-requisite packages'
sudo apt-get install -yq python2.7 > /dev/null
sudo apt-get install -yq python-pip > /dev/null
sudo apt-get install -yq git > /dev/null
sudo apt-get install -yq pep8 > /dev/null

SHELL_CONFIG_FILE="~/.bashrc"
DEV_DIRECTORY="$(pwd)"

echo '-- Installing pre-requisite packages'
sudo apt-get install -yq python2.7 > /dev/null
sudo apt-get install -yq python-pip > /dev/null
sudo apt-get install -yq git > /dev/null
sudo apt-get install -yq pep8 > /dev/null

echo '-- Installing pre-requisite pip packages'
pip install -q virtualenvwrapper
pip install -q cookiecutter

VIRTUALENV_CONFIG="
# Virtualenv config
export WORKON_HOME=\$HOME/.virtualenvs
export PROJECT_HOME=$DEV_DIRECTORY
source /usr/local/bin/virtualenvwrapper.sh"

if ! $(cat "$SHELL_CONFIG_FILE" | tr -d '\n' | grep -q "$(echo "$VIRTUALENV_CONFIG" | tr -d '\n')"); then
    echo "-- Adding Virtualenv config to shell config file."
    echo "$VIRTUALENV_CONFIG" >> "$SHELL_CONFIG_FILE"
fi

echo '-- Executing Virtualenv config'
eval "$VIRTUALENV_CONFIG"