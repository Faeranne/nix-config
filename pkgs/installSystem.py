#!/usr/bin/env python312
import locale
import uuid
import os
import json
import requests

from diskinfo import DiskInfo, Disk
from dialog import Dialog
from subprocess import run 
from netifaces import ifaddresses, interfaces, AF_LINK

locale.setlocale(locale.LC_ALL, '')

dialog = Dialog(dialog="dialog", autowidgetsize=True)
dialog.set_background_title("Install System")


def selectNetwork():
    devs = interfaces()
    choices = [(d, d) for d in devs]
    code, tag = dialog.menu("Select default network interface:", choices=choices)
    if code == dialog.OK:
        return tag
    else:
        return False


def selectDisk():
    di = DiskInfo()
    all_disks = di.get_disk_list(sorting=True)
    # Remove zram and CD drives
    real_disks = [d for d in all_disks if ((not d.get_model() == "") and (not d.get_name().startswith("sr")))]
    choices = [(d.get_name(), f'Model: {d.get_model()} Path: {d.get_byid_path()[0]}') for d in real_disks]
    code, tag = dialog.menu("Select default disk", choices=choices)
    if code == dialog.OK:
        return tag
    else:
        return False


def createKey():
    run(["age-keygen", "-o", "/zroot/persist/agenix.key"])
    pubkey = run(["age-keygen", "-y", "/zroot/persist/agenix.key"], capture_output=True).stdout.rstrip(b'\n').decode("utf-8")
    return pubkey
    pass


def formatDisk(diskID):
    disk = Disk(diskID)
    if dialog.yesno(f"About to permanently wipe {disk.get_model()}! ARE YOU SURE?", yes_label=f'I am sure I want to completely wipe {disk.get_name()} RIGHT NOW!', default_button="no") == dialog.OK:
        dialog.infobox(f'Wiping {disk.get_name()} now')
        path = disk.get_path()
        bootID = os.urandom(4).hex()
        print(path)
        print(run(f'parted -s {path} -- mklabel gpt', shell=True, capture_output=True))
        print(run(f'parted -s {path} -- mkpart ESP fat32 0% 2GB', shell=True, capture_output=True))
        print(run(f'parted -s {path} -- mkpart zfs ext3 2GB 100%', shell=True, capture_output=True))
        print(run(f'parted -s {path} -- set 1 esp on', shell=True, capture_output=True))
        print(run(["partprobe",path]))
        print(run(["mkdosfs", "-i", bootID, path+"1"]))
        print(run(["zpool", "create", "-f", "zroot", path+"2"]))
        print(run(["zfs", "create", "zroot/nix"]))
        print(run(["zfs", "create", "zroot/persist"]))
        print(run(["zfs", "create", "zroot/root"]))
        print(run(["zfs", "snapshot", "zroot/root@blank"]))
        print(run(["zfs", "create", 
                   "-V", "8G", 
                   "-b", "4096", 
                   "-o", "compression=zle", 
                   "-o", "primarycache=metadata",
                   "-o", "secondarycache=none",
                   "-o", "logbias=throughput",
                   "-o", "sync=always",
                   "-o", "com.sun:auto-snapshot=false",
                   "zroot/swap"]))
        print(run(["mkswap", "/dev/zvol/zroot/swap"]))
        return bootID


def getMac(id):
    addrs = ifaddresses(id)
    return addrs[AF_LINK][0]['addr']


def encrypt(content):
    enc = run(["age", "-a", "-r", "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr"], capture_output=True, input=bytes(content, "utf-8"))
    return enc


def submit(content):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("termbin.com", 9999))
    s.sendall(content.encode())
    s.shutdown(socket.SHUT_WR)
    res = ""
    while True:
        data = s.recv(4096)
        if not data:
            break
        res = res + data.decode('utf-8')
    return res.strip('\n\x00')


if (__name__ == "__main__"):
    if dialog.yesno("Begin installing system?") == dialog.OK:
        dialog.infobox("Beginning install")
        dialog.infobox("Fetching disks")
        net = selectNetwork()
        if net:
            mac = getMac(net)
            tag = selectDisk()
            if tag:
                bootID = formatDisk(tag)
                pubkey = createKey()
                res = json.dumps({"bootID": bootID.upper(), "pubkey": pubkey, "mac": mac}, indent=4)
                #print(res)
                content = encrypt(res)
                print(content)
                r = submit(content.stdout.strip(b'\n'))
                code = r.strip('https://termbin.com/')
                with open('./code','w') as f:
                    f.write(code)
                with open('./content.json', 'w') as f:
                    f.write(res)
                print(code)
        run(["zpool", "export", "zroot"])
