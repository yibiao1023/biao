#!/bin/bash
function Hadoop()
{
echo "========Do Hadoop========"
echo -n  -e "\033[31m  Are you sure configer Hadoop (Y/N): \033[0m"
CHOOSE=y
if [ $CHOOSE = "y" ] || [ $CHOOSE = "Y" ] ;then
# step 1  all data mount point add noatime
#fstab=$1
TIME=$(date "+%Y-%m-%d_%H:%M:%S")
cp /etc/fstab /etc/fstab.$TIME.bk

cat /etc/fstab | grep noatime > /dev/null 2>&1
if [ $? -ne 0 ];
then
sed  -i '/\/data/s/defaults        0 0/defaults,noatime        1 2/' /etc/fstab
echo "add noatime parameter ok!"
else
echo -e "add noatime parameter ok!"
"\033[31m noatime parameter already done! \033[0m"
fi

cat /etc/fstab | grep LABEL > /dev/null 2>&1
if [ $? -ne 0 ];
then
# step 2 get all data disk dev partion
grep '\/data' /etc/fstab | awk '{print $1,$2}' | awk -F"=" '{print $2}' > uuids
cat uuids
cat uuids | while read uuid data_partion
do
dev=`blkid | sort | grep $uuid | awk '{print $1}' | sed 's/://g'`
#1000000 block for root
tune2fs -r 1000000 $dev  > /dev/null 2>&1
tune2fs -L${data_partion} $dev > /dev/null 2>&1
data_partion=`echo "$data_partion" | sed 's/\///g' `
sed -i 's/UUID='"$uuid"'/LABEL=\/'"$data_partion"'/' /etc/fstab
done
rm -f uuids
else
echo -e "\033[31m LABEL already done! \033[0m"
tune2fs -r 1000000 $dev  > /dev/null 2>&1
tune2fs -L${data_partion} $dev > /dev/null 2>&1
fi
echo "umount all data partion"
umount /data*
echo "mount all data partion"
mount -a
echo "delte acpi_pad mod!"
rmmod acpi_pad; grubby --update-kernel=ALL --args="acpi_pad.disable=1"
cat > /etc/resolv.conf  << EOF
nameserver 127.0.0.1
nameserver 172.16.53.234
nameserver 172.16.105.248
nameserver 10.13.8.25
EOF
echo "DNS ok"
#echo "options igb RSS=8,8,8,8" >> /etc/modprobe.d/modprobe.conf
echo "RSS ok"
/usr/local/sina_tools/scripts/ntp_cron.pl
echo "ntp ok"
else
echo -e "\033[31m Not Configer Hadoop \033[0m"
fi
}
Hadoop
