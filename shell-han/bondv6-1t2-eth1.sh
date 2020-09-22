function Bond()
{
clear
echo "========Add Bond========"
cat /etc/sysconfig/network-scripts/ifcfg-eth0
echo "========================"
cat /etc/sysconfig/network-scripts/ifcfg-eth1

echo -n  -e "\033[31m  Are you sure Bond the eth0 and eth1 (Y/N): \033[0m"
read CHOOSE
if [ $CHOOSE = "y" ] || [ $CHOOSE = "Y" ] ;then
NET_DIR=/etc/sysconfig/network-scripts/
MOD_FILE=/etc/modprobe.d/modprobe.conf
TIME=$(date "+%Y-%m-%d_%H:%M:%S")
mkdir -p /tmp/guangyan/
cp -a /etc/modprobe.d/modprobe.conf /tmp/guangyan/modprobe.conf.$TIME.bk

#CP IFCONFIG FILES
if [ ! -f ${NET_DIR}/ifcfg-bond0 ];then
cp ${NET_DIR}/ifcfg-eth0 ${NET_DIR}/ifcfg-bond0
fi

sed -i '1s/eth1/bond0/' ${NET_DIR}/ifcfg-bond0
sed -i '/HWADDR/d' ${NET_DIR}/ifcfg-bond0
sed -i '/UUID/d' ${NET_DIR}/ifcfg-bond0

sed -i.$TIME.bk '/IPADDR/d' ${NET_DIR}/ifcfg-eth0
sed -i 's/ONBOOT=no/ONBOOT=yes/' ${NET_DIR}/ifcfg-eth0
sed -i '/BOOTPROTO/d' ${NET_DIR}/ifcfg-eth0
echo "BOOTPROTO=none" >> ${NET_DIR}/ifcfg-eth0
sed -i '/NETMASK/d' ${NET_DIR}/ifcfg-eth0
sed -i '/GATEWAY/d' ${NET_DIR}/ifcfg-eth0
sed -i '/MASTER/d' ${NET_DIR}/ifcfg-eth0
echo "MASTER=bond0" >> ${NET_DIR}/ifcfg-eth0
sed -i '/SLAVE/d' ${NET_DIR}/ifcfg-eth0
echo "SLAVE=yes" >> ${NET_DIR}/ifcfg-eth0

sed -i.$TIME.bk '/IPADDR/d' ${NET_DIR}/ifcfg-eth1
sed -i '/NETMASK/d' ${NET_DIR}/ifcfg-eth1
sed -i '/GATEWAY/d' ${NET_DIR}/ifcfg-eth1
sed -i 's/ONBOOT=no/ONBOOT=yes/' ${NET_DIR}/ifcfg-eth1
sed -i '/BOOTPROTO/d' ${NET_DIR}/ifcfg-eth1
echo "BOOTPROTO=none" >> ${NET_DIR}/ifcfg-eth1
sed -i '/MASTER/d' ${NET_DIR}/ifcfg-eth1
echo "MASTER=bond0" >> ${NET_DIR}/ifcfg-eth1
sed -i '/SLAVE/d' ${NET_DIR}/ifcfg-eth1
echo "SLAVE=yes" >> ${NET_DIR}/ifcfg-eth1

mv ${NET_DIR}/ifcfg-eth*.bk /tmp/guangyan/

sed -i '/bond0/d' ${MOD_FILE}
echo "alias bond0 bonding" >> ${MOD_FILE}
echo "options bond0 mode=balance-rr use_carrier=1 miimon=1" >> ${MOD_FILE}
else
echo -e "\033[31m Not Add Bond \033[0m"
fi

}
Bond
