#!/bin/bash
hostnamectl set-hostname $1
sed -ri "/^IPADDR/ s/\.[0-9]+$/\.$2/" /etc/sysconfig/network-scripts/ifcfg-ens33 && systemctl restart network
