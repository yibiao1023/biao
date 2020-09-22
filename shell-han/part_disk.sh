#!/bin/bash 
set -x

version=`cat /etc/redhat-release | awk '{if(match($0,/release 7/)) print "CENTOS7" ;else print "CENTOS6"}' `

if [ $version = "CENTOS7" ];then
	MKFS_EXEC=/sbin/mkfs.ext4
else
	MKFS_EXEC=/usr/local/e2fs/sbin/mkfs.ext4
fi

disknum=$((DISKNUM+1))
set b c d e f g h i j k l
for i 
do
        dd if=/dev/zero of=/dev/sd${i} bs=4k count=1000
        parted -s /dev/sd${i} mklabel gpt 
	ISBLOCK=`ls -l /dev/sd${i} | awk '/^b/' | wc -l`
        if [ $ISBLOCK -eq 1 ]; then
		parted -s /dev/sd${i} mkpart primary 0 100%
		parted -s /dev/sd${i} print
		sleep 10
                #/usr/local/e2fs/sbin/mkfs.ext4 /dev/sd${i}1 
                ${MKFS_EXEC}   /dev/sd${i}1 
		echo "waiting .... "
                sleep 60
                DISKUUID=`blkid | awk '/\/dev\/sd'"$i"'1/{ print $2 }' | tr -d \"`
                echo "${DISKUUID}  /data${disknum}                  ext4    defaults        0 0" >> /etc/fstab
                mkdir -p /data${disknum}
                disknum=$((disknum+1))
	else 
		rm -f /dev/sd${i}
        fi
done

#ENDLAST=`parted -s /dev/sda print | awk '!/^$/ && $3 ~ /B$/ { print $3 }' | tail -n 1`
#ENDNUM=`parted -s /dev/sda print | awk '!/^$/ && $3 ~ /B$/ { print $1 }' | tail -n 1`
#ENDNUM=$((ENDNUM+1))
#parted -s /dev/sda mkpart primary $ENDLAST 100%
#mkdir -p /data0
ENDNUM=`parted -s /dev/sda print | awk '!/^$/ && $3 ~ /B$/ { print $1 }' | tail -n 1`
#/usr/local/e2fs/sbin/mkfs.ext4 /dev/sda${ENDNUM}
${MKFS_EXEC}  /dev/sda${ENDNUM}
echo "waiting .... "
sleep 60
DISKUUID=`blkid | awk '/\/dev\/sda'"$ENDNUM"'/{ print $2 }' | tr -d \"`
echo "${DISKUUID}  /dataDISKNUM                  ext4    defaults        0 0" >> /etc/fstab

sed -i '/part_disk/d' /etc/rc.d/rc.local
rm -f /tmp/part_disk.sh
mount -a
/sbin/modprobe ipmi_msghandler > /dev/null 2>&1
/sbin/modprobe ipmi_devintf  > /dev/null 2>&1
/sbin/modprobe ipmi_si > /dev/null 2>&1
echo 100 |tee /sys/module/ipmi_si/parameters/kipmid_max_busy_us
/sbin/modprobe ipmi_poweroff > /dev/null 2>&1
/sbin/modprobe ipmi_watchdog > /dev/null 2>&1
USER='SinaBMC'
PASS='SINA0bmc1PWD+'
USERID=2
CHANNEL=1
lspci | grep -i Hewlett && CHANNEL=2
ipmitool user set name $USERID $USER
ipmitool user set password $USERID $PASS
ipmitool user priv $USERID 4 $CHANNEL
ipmitool channel  setaccess $CHANNEL $USERID callin=on ipmi=on link=on privilege=4
ipmitool sol payload enable $CHANNEL $USERID
ipmitool user enable $USERID
