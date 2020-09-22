#!/bin/bash
#in use update MAC


dmesg |grep " ..:..:..:..:.."
if [ $? -ne 0 ];then
DMESG='cat /var/log/dmesg.old'
else
DMESG='dmesg'
fi

#for net device
NET_COUNT=0

lsmod | grep bond
if [ $? -ne 0 ];then
MAC=$(cat /sys/devices/*/*/*/net/*/address|sed 's@ @\n@g'|grep "..:..:..:..:.." |sort -u)
else
MAC=$(cat /proc/net/bonding/* /sys/devices/*/*/*/net/*/address|sed 's@ @\n@g'|grep "..:..:..:..:.."|sort -u)
fi

BIOS=$(${DMESG} |grep -E 'igb|ixgbe|bnx2|tg3|e1000|pcnet32'  |sed 's@ @\n@g'|grep "..:..:..:..:.."|sort -u)
NOBIOS=$(echo "${MAC}"|grep -E -v "${BIOS}")
IXGBE=$(${DMESG} |grep -i 'ixgbe'|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:..")
BNX2X=$(${DMESG} |grep -i 'bnx2x'|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:..")
BNX2=$(${DMESG} |grep -i 'bnx2 '|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:..")
IGB=$(${DMESG} |grep -i 'igb'|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:..")
TG3=$(${DMESG} |grep -i 'tg3'|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:..")
E1000=$(${DMESG} |grep -i 'e1000'|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:.."=)
PCNET32=$(${DMESG} |grep -i 'pcnet32'|sort -u|sed 's@ @\n@g'|grep "..:..:..:..:..")

function NET_DEV()
{
DEV=$1
DEV_NU=$(echo "${DEV}"|awk '{if($0!=""){x=x+1}}END{print int(x)}')
for ((i=0;i<${DEV_NU};i++))
do
HWADDR=$(echo "${DEV}"|sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'|awk "NR==$[${i}+1]{print}")

sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth${NET_COUNT}
echo "HWADDR=${HWADDR}" | tee -a /etc/sysconfig/network-scripts/ifcfg-eth${NET_COUNT}
NET_COUNT=$((NET_COUNT+1))
done
}

for DEV in "${NOBIOS}" "${IXGBE}" "${BNX2X}" "${BNX2}" "${IGB}" "${TG3}" "${E1000}" "${PCNET32}"
do 
NET_DEV "${DEV}"
done
