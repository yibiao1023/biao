function Bond_V7()
{
clear
echo "========Add Bond Use eth0========"
cat /etc/sysconfig/network-scripts/ifcfg-eth[0-1]

echo -n  -e "\033[31m  Are you sure CentOS7 bonding the eth0 and eth1 (Y/N): \033[0m"
CHOOSE=y
if [ $CHOOSE = "y" ] || [ $CHOOSE = "Y" ] ;then
NET_DIR=/etc/sysconfig/network-scripts/
TIME=$(date "+%Y-%m-%d_%H:%M:%S")
mkdir -p /tmp/guangyan/

#CP IFCONFIG FILES
if [ ! -f ${NET_DIR}/ifcfg-bond0 ];then
cp ${NET_DIR}/ifcfg-eth0 ${NET_DIR}/ifcfg-bond0
fi

sed -i '1s/eth0/bond0/' ${NET_DIR}/ifcfg-bond0
sed -i '/HWADDR/d' ${NET_DIR}/ifcfg-bond0
sed -i '/UUID/d' ${NET_DIR}/ifcfg-bond0
sed -i '/BONDING_/d' ${NET_DIR}/ifcfg-bond0
echo 'BONDING_MASTER=yes' >> ${NET_DIR}/ifcfg-bond0
echo 'BONDING_OPTS="miimon=1 mode=balance-rr use_carrier=1"' >> ${NET_DIR}/ifcfg-bond0

sed -i.$TIME.bk '/IPADDR/d' ${NET_DIR}/ifcfg-eth0
sed -i 's/ONBOOT=no/ONBOOT=yes/' ${NET_DIR}/ifcfg-eth0
sed -i '/BOOTPROTO/d' ${NET_DIR}/ifcfg-eth0
echo "BOOTPROTO=none" >> ${NET_DIR}/ifcfg-eth0
sed -i '/NETMASK/d' ${NET_DIR}/ifcfg-eth0
sed -i '/IPADDR/d' ${NET_DIR}/ifcfg-eth0
sed -i '/GATEWAY/d' ${NET_DIR}/ifcfg-eth0

sed -i.$TIME.bk '/IPADDR/d' ${NET_DIR}/ifcfg-eth1
sed -i '/NETMASK/d' ${NET_DIR}/ifcfg-eth1
sed -i '/IPADDR/d' ${NET_DIR}/ifcfg-eth1
sed -i '/GATEWAY/d' ${NET_DIR}/ifcfg-eth1
sed -i 's/ONBOOT=no/ONBOOT=yes/' ${NET_DIR}/ifcfg-eth1
sed -i '/BOOTPROTO/d' ${NET_DIR}/ifcfg-eth1
echo "BOOTPROTO=none" >> ${NET_DIR}/ifcfg-eth1

mv ${NET_DIR}/ifcfg-eth*.bk /tmp/guangyan/

cat > ${NET_DIR}/ifcfg-bond-slave-eth0 <<EOF
TYPE=Ethernet
NAME=bond-slave-eth0
DEVICE=eth0
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF

cat > ${NET_DIR}/ifcfg-bond-slave-eth1 << EOF
TYPE=Ethernet
NAME=bond-slave-eth1
DEVICE=eth1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF

sed -i '/N\/A/d' /etc/rc3.d/S27route
sed -i '/N\/A/d' /etc/sysconfig/static-routes

else
echo -e "\033[31m Not Add Bond \033[0m"
fi
}
Bond_V7
