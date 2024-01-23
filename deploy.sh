#!/bin/bash

source hosts.env

if [ -z "$1" ];
then
  echo "Usage: deploy.sh <host>"
  exit 1
fi

if [ -z "${!1}" ];
then
  echo "No such host $1 found."
  exit 2
fi

nixos-rebuild --target-host ${!1} --use-remote-sudo --flake ".#${1}" test
