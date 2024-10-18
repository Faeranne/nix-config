#!/usr/bin/env python312
import locale
import parted
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


def createBoot(disk, device, bootID):
    geometry = parted.Geometry(
        device=device,
        start=1,
        length=int((1 * 1000 * 1000 * 1000) / device.sectorSize)
    )
    filesystem = parted.FileSystem(type="fat32", geometry=geometry)
    partition = parted.Partition(
        disk=disk,
        type=parted.PARTITION_NORMAL,
        fs=filesystem,
        geometry=geometry
    )
    partition.set_type_uuid(uuid.UUID("C12A7328-F81F-11D2-BA4B-00A0C93EC93B").bytes)
    disk.addPartition(
        partition=partition,
        constraint=device.optimalAlignedConstraint
    )
    disk.commit()
    return (partition.path, geometry.end)


def createPool(disk, device, start):
    geometry = parted.Geometry(
        device=device,
        start=start + 1,
        end=device.length - 1
    )
    filesystem = parted.FileSystem(type="ext3", geometry=geometry)
    partition = parted.Partition(
        disk=disk,
        type=parted.PARTITION_NORMAL,
        fs=filesystem,
        geometry=geometry
    )
    disk.addPartition(
        partition=partition,
        constraint=device.optimalAlignedConstraint
    )
    disk.commit()
    return partition.path


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
        device = parted.getDevice(path)
        disk = parted.freshDisk(device, "gpt")
        bootID = os.urandom(4).hex()
        (bootPath, bootEnd) = createBoot(disk, device, bootID)
        poolPath = createPool(disk, device, bootEnd)
        print(run(["partprobe",path]))
        print(run(["ls",path+"*"]))
        print(run(["ls","/dev/disk/by-uuid"]))
        print(run(["mkdosfs", "-i", bootID, bootPath]))
        print(run(["zpool", "create", "-f", "zroot", poolPath]))
        print(run(["zfs", "create", "zroot/nix"]))
        print(run(["zfs", "create", "zroot/persist"]))
        return bootID


def getMac(id):
    addrs = ifaddresses(id)
    return addrs[AF_LINK][0]['addr']


def encrypt(content):
    enc = run(["age", "-a", "-r", "age1yubikey1qtfy343ld8e5sxlvfufa4hh22pm33f6sjq2usx6mmydrmu7txzu7g5xm9vr"], capture_output=True, input=bytes(content, "utf-8"))
    return enc


def submit(content):
    r = requests.post("https://dpaste.org/api/", data={"format": "url", "content": content, "expires": "onetime"})
    return r


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
                res = json.dumps({"bootID": bootID, "pubkey": pubkey, "mac": mac}, indent=4)
                print(res)
                content = encrypt(res)
                print(content)
                r = submit(content.stdout.strip(b'\n'))
                if r.status_code == 200:
                    print(r.text.rstrip('\n'))
                else:
                    print(f'Error submitting encoded data. Error code: {r.status_code} with content: {r.text}')
        run(["zpool", "export", "zroot"])
