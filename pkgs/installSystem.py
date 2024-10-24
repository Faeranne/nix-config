#!/usr/bin/env python312
import locale
import uuid
import os
import json
import requests
import socket
import logging

from diskinfo import DiskInfo, Disk
from dialog import Dialog
from subprocess import Popen,PIPE
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
    log = logging.getLogger("createKey")
    res = logRun(["age-keygen", "-o", "/zroot/persist/agenix.key"],log)
    if res:
        dialog.msgBox("Failed to generate key")
        log.error("Failed to generate key")
        raise Exception("Key gen failure")
    (res, pubkey) = logOutputRun(["age-keygen", "-y", "/zroot/persist/agenix.key"],log)
    if res:
        dialog.msgBox("Failed to generate pub key")
        log.error("Failed to generate pub key")
        raise Exception("Key gen failure")
    return pubkey


def formatDisk(diskID):
    log = logging.getLogger("format")
    disk = Disk(diskID)
    if dialog.yesno(f"About to permanently wipe {disk.get_model()}! ARE YOU SURE?", yes_label=f'I am sure I want to completely wipe {disk.get_name()} RIGHT NOW!', default_button="no") == dialog.OK:
        dialog.infobox(f'Wiping {disk.get_name()} now')
        path = disk.get_path()
        bootID = os.urandom(4).hex()
        res = logRun(f'parted -s {path} -- mklabel gpt', log, shell=True)
        if res:
            log.error(f'make gpt failed.')
            dialog.msgbox("Make gpt failed.")
            raise Exception("Formatting error")
        res = logRun(f'parted -s {path} -- mkpart ESP fat32 0% 2GB', log, shell=True)
        if res:
            log.error(f'Make ESP partition failed.')
            dialog.msgbox("Make ESP partition failed.")
            raise Exception("Formatting error")
        res = logRun(f'parted -s {path} -- mkpart zfs ext3 2GB 100%', log, shell=True)
        if res:
            log.error(f'Make zfs partition failed.')
            dialog.msgbox("Make zfs partition failed.")
            raise Exception("Formatting error")
        res = logRun(f'parted -s {path} -- set 1 esp on', log, shell=True)
        if res:
            log.error(f'couldn\'t set boot flag on ESP partition.')
            dialog.msgbox("couldn\'t set boot flag on ESP partition.")
            raise Exception("Formatting error")
        res = logRun(["partprobe",path], log)
        if res:
            log.error(f'Failed to partition probe.')
            dialog.msgbox("Failed to partition probe.")
            raise Exception("Formatting error")
        res = logRun(["mkdosfs", "-i", bootID, path+"1"], log)
        if res:
            log.error(f'Couldn\'t create fat32 filesystem on boot partition.')
            dialog.msgbox("Couldn\'t create fat32 filesystem on boot partition.")
            raise Exception("Formatting error")
        res = logRun(["zpool", "create", "-f", "zroot", path+"2"], log)
        if res:
            log.error(f'Failed to create zroot zpool on zfs partition.')
            dialog.msgbox("Couldn\'t create fat32 filesystem on boot partition.")
            raise Exception("Formatting error")
        res = logRun(["zfs", "create", "zroot/nix"], log)
        if res:
            log.error(f'Failed to create nix dataset on zroot.')
            dialog.msgbox("Failed to create nix dataset on zroot.")
            raise Exception("Formatting error")
        res = logRun(["zfs", "create", "zroot/persist"], log)
        if res:
            log.error(f'Failed to create persist dataset on zroot.')
            dialog.msgbox("Failed to create persist dataset on zroot.")
            raise Exception("Formatting error")
        res = logRun(["zfs", "create", "zroot/root"], log)
        if res:
            log.error(f'Failed to create root dataset on zroot.')
            dialog.msgbox("Failed to create root dataset on zroot.")
            raise Exception("Formatting error")
        res = logRun(["zfs", "snapshot", "zroot/root@blank"], log)
        if res:
            log.error(f'Failed to snapshot root dataset for future use.')
            dialog.msgbox("Failed to snapshot root dataset for future use.")
            raise Exception("Formatting error")
        res = logRun(["zfs", "create", 
                   "-V", "8G", 
                   "-b", "4096", 
                   "-o", "compression=zle", 
                   "-o", "primarycache=metadata",
                   "-o", "secondarycache=none",
                   "-o", "logbias=throughput",
                   "-o", "sync=always",
                   "-o", "com.sun:auto-snapshot=false",
                   "zroot/swap"], log)
        if res:
            log.error(f'Failed to create swap zvol on zroot.')
            dialog.msgbox("Failed to create swap zvol on zroot.")
            raise Exception("Formatting error")
        res = logRun(["mkswap", "/dev/zvol/zroot/swap"], log)
        if res:
            log.error(f'Couldn\'t run mkswap on swap zvol.')
            dialog.msgbox("Couldn\'t run mkswap on swap zvol.")
            raise Exception("Formatting error")
        return bootID


def getMac(id):
    addrs = ifaddresses(id)
    return addrs[AF_LINK][0]['addr']

def encrypt(content):
    log = logging.getLogger("encrypt")
    (res, enc) = logOutputRun(["age", "-a", "-r", "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr"], log, input=bytes(content, "utf-8"))
    if res:
        log.error(f'Failed to encrypt {content}.')
        dialog.msgbox(f'Failed to encrypt {content}.')
        raise Exception("Encryption error")
    return enc


def submit(content):
    log = logging.getLogger("submit")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("termbin.com", 9999))
    s.sendall(content)
    s.shutdown(socket.SHUT_WR)
    res = ""
    while True:
        data = s.recv(4096)
        if not data:
            break
        res = res + data.decode('utf-8')
    return res.strip('\n\x00')

def prepSystem():
    log = logging.getLogger("prep")
    res = logRun(["zfs","umount","zroot"])
    if res:
        log.error(f'Failed to unmount zroot contents.')
        dialog.msgbox(f'Failed to unmount zroot contents.')
        raise Exception("System Prep Error")
    res = logRun(["mount","-t","tmpfs","tmpfs","/mnt"])
    if res:
        log.error(f'Failed to tmp mount /mnt.')
        dialog.msgbox(f'Failed to tmp mount /mnt.')
        raise Exception("System Prep Error")
    for p in ["nix","persist","boot"]:
        os.makedirs(f'/mnt/{p}',exist_ok=True)
    res = logRun(["mount","/dev/disk/by-partlabel/ESP"])
    if res:
        log.error(f'Failed to mount boot partition.')
        dialog.msgbox(f'Failed to mount boot partition.')
        raise Exception("System Prep Error")
    for p in ["nix","persist"]:
        res = logRun(["mount","-t","zfs","-o","zfsutil","zroot/{p}","/mnt/{p}"])
        if res:
            log.error(f'Failed to mount zfs volume {p}.')
            dialog.msgbox(f'Failed to mount zfs volume {p}.')
            raise Exception("System Prep Error")

def copySystem(system):
    log = logging.getLogger("copy")
    res = logRun(["nix","copy","--to","/mnt",system],log)

def installSystem(system):
    log = logging.getLogger("install")
    res = logRun(["nixos-install","--system",system,"--no-channel-copy","--no-root-password"],log)

def logRun(args,log, **kargs):
    process = Popen(args,**kargs,stdout=PIPE, stderr=PIPE)

    def check_io():
        while True:
            res = False
            output = process.stdout.readline().decode()
            if output:
                log.info(output)
                res=True
            error = process.stderr.readline().decode()
            if error:
                log.error(error)
                res=True
            if not res:
                break
    while process.poll() is None:
        check_io()
    return process.returncode

def logOutputRun(args,log, **kargs):
    process = Popen(args,**kargs,stdout=PIPE, stderr=PIPE)
    result = ""
    def check_io():
        while True:
            res = False
            output = process.stdout.readline().decode()
            if output:
                log.info(output)
                result = result + output
                res=True
            error = process.stderr.readline().decode()
            if error:
                log.error(error)
                res=True
            if not res:
                break
    while process.poll() is None:
        check_io()
    return (process.returncode,result)

def main():
    log = logging.getLogger("main")
    dialog.infobox("Clearing zroot.")
    logRun(['zpool','export','zroot'],log)
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
                boot1 = bootID[:4]
                boot2 = bootID[4:]
                res = json.dumps({"bootID": (f'{boot1}-{boot2}').upper(), "pubkey": pubkey, "mac": mac}, indent=4)
                (res,content) = encrypt(res)
                if res:
                    log.error("Failed to encrypt content")
                    return
                try:
                    log.info("Attempting to upload to termbin.com")
                    code = submit(content.strip('\n'))
                    log.info(f'Upload successful.  Returned {code}')
                    with open('/zroot/persist/code','w') as f:
                        f.write(code)
                except Exception as e:
                    log.error("Couldn't upload.")
                log.info("Storing contents at /persist/content.json")
                with open('/zroot/persist/content.json', 'w') as f:
                    f.write(res)
                log.info("Preparing to install")
                prepSystem()
                with open('/etc/systemPath','r') as f:
                    system = f.read().strip('\n')
                    log.info(f'Copying {system} to new install')
                    copySystem(system)
                    log.info(f'Running nixos-install with {system}')
                    installSystem(system)

if (__name__ == "__main__"):
    main()
