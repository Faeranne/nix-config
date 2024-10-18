#!/usr/bin/env python312
import requests
import tempfile
import sys
import json

from subprocess import run


def fetch(code):
    r = requests.get(f'https://dpaste.org/{code}/raw')
    return r


def decrypt(content):
    with tempfile.NamedTemporaryFile(delete_on_close=False) as f:
        keyIdentity = run(["age-plugin-yubikey", "-i"], capture_output=True).stdout.rstrip(b'\n')
        f.write(keyIdentity)
        f.close()
        dec = run(["age", "-d", "-i", f.name], capture_output=True, input=bytes(content, "utf-8"))
        return dec


if __name__ == "__main__":
    r = fetch(sys.argv[1])
    cont = json.loads(decrypt(r.text).stdout.rstrip(b'\n'))
    bootID = cont['bootID']
    boot1 = bootID[:4]
    boot2 = bootID[4:]
    cont['bootID'] = boot1+"-"+boot2
    print(json.dumps(cont, indent=2))
