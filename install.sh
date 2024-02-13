#!/bin/bash

source hosts.env

if [ -z "$1" ];
then
  echo "Usage: ./install <host>"
  exit 0
fi

if [ -z "${!1}" ];
then
  echo "No such host $1 found."
  exit 2
fi

echo "Going to install Nix on host ${1} via ${!1}.  Press enter to continue, or Ctrl-C to cancel."

read

nixos-anywhere --extra-files "$tmp_dir" --flake ".#${1}" ${!1}
