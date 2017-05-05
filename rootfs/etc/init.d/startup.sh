#!/bin/sh

mount -t proc proc /proc -o nosuid,noexec,nodev
mount -t sysfs sys /sys -o nosuid,noexec,nodev
mount -t tmpfs run /run -o mode=0755,nosuid,nodev
mount -t devtmpfs dev /dev -o mode=0755,nosuid
mkdir -p /dev/pts /dev/shm
mount -t devpts devpts /dev/pts -o mode=0620,gid=5,nosuid,noexec
mount -t tmpfs shm /dev/shm -o mode=1777,nosuid,nodev
mount -t tmpfs tmpfs /run
mount -t tmpfs tmpfs /tmp

cat /etc/hostname > /proc/sys/kernel/hostname

mdev -s
echo /sbin/mdev > /proc/sys/kernel/hotplug

ip link set up dev lo

mount -a
