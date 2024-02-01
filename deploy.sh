#!/bin/bash

source hosts.env

if [ -z "$1" ];
then
  arch=$(uname -m)
  home-manager --flake ./#$arch switch
  exit 0
fi

if [ -z "${!1}" ];
then
  echo "No such host $1 found."
  exit 2
fi

action="deploy"
if [ -v 2 ];
then
  action=$2
fi

nixos-rebuild --target-host ${!1} --use-remote-sudo --flake ".#${1}" $action
