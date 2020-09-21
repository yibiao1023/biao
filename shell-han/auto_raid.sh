#!/bin/bash
SOFT='/opt/MegaRAID/MegaCli/MegaCli64'

DISK_ID_LIST()
{
CMD=$1
SOFT=$2
NUM=$(${SOFT} -pdlist -aall| grep -E 'Enclosure Device ID:|Slot Number: 11|Firmware state:|Inquiry Data:|PD Type:'|sed  ':a;N;$!ba;s@\n@#@g'| sed 's@Enclosure Device ID:@\nEnclosure Device ID:@g' |${CMD}|wc|awk '{print $1}')

#${SOFT} -pdlist -aall|grep -E 'Enclosure Device ID:|Slot Number:|Firmware state:|Inquiry Data:|PD Type:'|sed  ':a;N;$!ba;s@\n@#@g'|sed 's@Enclosure Device ID:@\nEnclosure Device ID:@g' |${CMD}|wc -l
#${SOFT} -pdlist -aall|grep -E 'Enclosure Device ID:|Slot Number:|Firmware state:|Inquiry Data:|PD Type:'|sed  ':a;N;$!ba;s@\n@#@g'|sed 's@Enclosure Device ID:@\nEnclosure Device ID:@g' |${CMD}

${SOFT} -pdlist -aall|grep -E 'Enclosure Device ID:|Slot Number:|Firmware state:|Inquiry Data:|PD Type:'|sed  ':a;N;$!ba;s@\n@#@g'|sed 's@Enclosure Device ID:@\nEnclosure Device ID:@g' |${CMD}|sed 's@#@\n@g'|
awk -F': ' 'BEGIN { count=0; }
/Enclosure Device ID/{ ENCL[count]=$2; }
/Slot Number/{ SLOT[count]=$2;  ++count; }
END { for(i=0;i<'${NUM}';i++) printf "%d:%d,",ENCL[i],SLOT[i]; }' | sed 's/\,$/\n/'
}

#echo $(DISK_ID_LIST 'grep -i Online' ${SOFT} )

#${SOFT} -PDMakeGood -PhysDrv [$(DISK_ID_LIST 'grep bad' ${SOFT})] -Force -a0
#echo $(DISK_ID_LIST 'grep -i sata.*ssd' ${SOFT} )

${SOFT} -AdpSetProp -EnableJBOD -0  -a0 
${SOFT} -CfgForeign -Clear -a0
${SOFT} -PDMakeGood -PhysDrv [$(DISK_ID_LIST 'grep bad' ${SOFT})] -Force -a0
${SOFT} CfgLdAdd -r0[$(DISK_ID_LIST 'grep -i sata.*good.*ssd' ${SOFT} )] WB Direct -a0
${SOFT} CfgLdAdd -r1[$(DISK_ID_LIST 'grep -i sas.*good' ${SOFT} )] WB Direct -a0

sleep 2
partprobe
sleep 2
parted -s /dev/sdb mklabel gpt  mkpart primary 0 100%
parted -s /dev/sdc mklabel gpt  mkpart primary 0 100%

mkdir -p /data1
mkdir -p /data2 
mkfs.ext4  /dev/sdb1 
mkfs.ext4  /dev/sdc1
sleep 3
echo "$(blkid  | grep sdb | sed 's/ /\n/g' | grep UUID | grep -v PART | sed 's/"//g')        /data1                  ext4    defaults        0 0"|tee -a /etc/fstab 
echo "$(blkid  | grep sdc | sed 's/ /\n/g' | grep UUID | grep -v PART | sed 's/"//g')        /data2                  ext4    defaults        0 0"|tee -a /etc/fstab
mount -a
