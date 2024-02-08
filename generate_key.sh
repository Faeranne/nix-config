#!/bin/bash
if [ -z "$1" ];
then
  echo "Need to set a hostname before continuing."
  exit 0
fi
tmp_dir=$(mktemp -d)
mkdir -p $tmp_dir/persist/
age-keygen -o $tmp_dir/persist/sops.key
age-keygen -y $tmp_dir/persist/sops.key > secrets/$1.pub
./regenerate_sops.sh
sops updatekeys secrets/*.yaml
echo $tmp_dir

