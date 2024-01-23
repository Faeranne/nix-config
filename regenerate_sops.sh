#!/bin/bash
for f in secrets/*.pub
do
  name=$(echo $(basename $f)|sed 's/\./_/g'| awk '{print toupper($0)}')
  val=$(cat $f)
  printf -v "$name" "%s" "$val"
  export "$name"
done
cat templates/.sops.yaml | envsubst > .sops.yaml
