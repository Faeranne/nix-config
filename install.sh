#!/bin/bash

source hosts.env

if [ -z "$1" ];
then
  echo "Usage: ./install <host> <key_dir>"
  exit 0
fi

if [ -z "$2" ];
then
  echo ""
  exit 0
fi

if [ -z "${!1}" ];
then
  echo "No such host $1 found."
  exit 2
fi

echo "Going to install Nix on host ${1} via ${!1}.  Press enter to continue, or Ctrl-C to cancel."

read

nixos-anywhere --extra-files "$2" -t --flake ".#${1}" ${!1}
