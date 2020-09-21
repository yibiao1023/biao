#!/bin/bash
fdisk /dev/sdb << EOF
n
p
1


wq
EOF

# 扩容/目录
mkfs.xfs /dev/sdb1
pvcreate /dev/sdb1
vgextend centos /dev/sdb1 << EOF
y
EOF
lvextend -L +4G /dev/centos/root
xfs_growfs /dev/mapper/centos-root

自动挂载
mkfs.ext4 /dev/sdb1
[ ! -d /mnt/dir1 ] && mkdir /mnt/dir1 && mount /dev/sdb1 /mnt/dir1 && echo "/dev/sdb1 /mnt/dir1 ext4 default 0 0" >> /etc/fstab
