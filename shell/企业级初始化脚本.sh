#!/bin/bash
# 判断centos版本
releasever=$(rpm -q --qf "%{Version}\n" `rpm -q --whatprovides redhat-release`)
# 配置yum源
echo '配置yum源'
cd /etc/yum.repos.d/
mkdir /etc/yum.repos.d/bak 
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
if [ $releasever == 6 ];then
    curl https://mirrors.aliyun.com/repo/Centos-6.repo > AliyumBase.repo
	curl http://mirrors.aliyun.com/repo/epel-7.repo > AliyumEpel.repo
fi
if [ $releasever == 7 ];then
    curl https://mirrors.aliyun.com/repo/Centos-7.repo > AliyumBase.repo
	curl http://mirrors.aliyun.com/repo/epel-7.repo > AliyumEpel.repo
fi
yum clean all && yum check-update

# install base package 安装基本软件包
echo '安装基本软件包'
yum -y install nc vim iftop iotop dstat tcpdump bash-completion
yum -y install ipmitool bind-libs bind-utils net-tools
yum -y install libselinux-python ntpdate
if [ $releasever == 6 ];then
    test -f /etc/security/limits.d/90-nproc.conf && rm -rf /etc/security/limits.d/90-nproc.conf && touch /etc/security/limits.d/90-nproc.conf
fi
if [ $releasever == 7 ];then
    test -f /etc/security/limits.d/20-nproc.conf && rm -rf /etc/security/limits.d/20-nproc.conf && touch /etc/security/limits.d/20-nproc.conf
fi
> /etc/security/limits.conf
cat >> /etc/security/limits.conf << EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF

# set timezone 修改时区
echo '修改时区'
test -f /etc/localtime && rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# set LANG 修改语言
echo '修改语言'
if [ $releasever == 6 ];then
	sed -i 's@LANG=.*@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
fi
if [ $releasever == 7 ];then
	sed -i 's@LANG=.*@LANG="en_US.UTF-8"@g' /etc/locale.conf
fi

# update time 自动对时
echo '自动对时'
if [ $releasever == 6 ];then
	/usr/sbin/ntpdate pool.ntp.org
	grep -q ntpdate /var/spool/cron/root
    if [ $? -ne 0 ];then
	echo '* * * * * /usr/sbin/ntpdate pool.ntp.org &> /dev/null' >> /var/spool/cron/root;chmod 600 /var/spool/cron/root
	fi
	/etc/init.d/crond restart
fi
if [ $releasever == 7 ];then
	grep -q ntpdate /var/spool/cron/root &> /dev/null
	if [ $? -ne 0 ];then
	echo '* * * * * /usr/sbin/ntpdate -s ntp.ntsc.ac.cn &> /dev/null' >> /var/spool/cron/root;chmod 600 /var/spool/cron/root
	fi
fi
# clean iptables default rules 关闭防火墙
echo '关闭防火墙'
if [ $releasever == 6 ];then
	/sbin/iptables -F
	service iptables save
	chkconfig iptables off
fi
if [ $releasever == 7 ];then
    systemctl stop firewalld
	systemctl disable firewalld
fi

# disable unused service 禁用审计服务
echo '禁用审计服务'
chkconfig auditd off

#disable ipv6 禁用ipv6
echo '禁用ipv6'
cd /etc/modprobe.d/ && touch ipv6.conf
> /etc/modprobe.d/ipv6.conf
cat >> /etc/modprobe.d/ipv6.conf << EOF
alias net-pf-10 off
alias ipv6 off
EOF

# disable iptable nat moudule 重新防火墙规则
#echo '重新防火墙规则'
#cd /etc/modprobe.d/ && touch connectiontracking.conf
#> /etc/modprobe.d/connectiontracking.conf
#cat >> /etc/modprobe.d/connectiontracking.conf << EOF
#install nf_nat /bin/true
#install xt_state /bin/true
#install iptable_nat /bin/true
#install nf_conntrack /bin/true
#install nf_defrag_ipv4 /bin/true
#install nf_conntrack_ipv4 /bin/true
#install nf_conntrack_ipv6 /bin/true
#EOF

# disable SELinux 关闭SELinux
echo '关闭SELinux'
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# update record command 优化历史命令
echo '优化历史命令'
sed -i 's/^HISTSIZE=.*$/HISTSIZE=100000' /etc/profile
grep -q 'HISTTIMEFORMAT' /etc/profile
if [[ $? -eq 0 ]];then
    sed -i 's/^HISTTIMEFORMAT=.*$/HISTTIMEFORMAT="%F %T "/' /etc/profile
else
    echo 'HISTTIMEFORMAT="%F %T "' >> /etc/profile
fi

# install dsnmasq and update configure 配置本地DNS缓存
#echo '配置本地DNS缓存'
#yum -y install dnsmasq
#> /etc/dnsmasq.conf
#cat >> /etc/dnsmasq.conf << EOF
#listen-address=127.0.0.1
#no-dhcp-interface=lo
#log-queries
#log-facility=/var/log/dnsmasq.log
#all-servers
#no-negcache
#cache-size=1023
#dns-forward-max=512
#EOF

if [ $releasever == 6 ];then
	/etc/init.d/dnsmasq restart
fi
if [ $releasever == 7 ];then
	systemctl restart dnsmasq
	systemctl enable dnsmasq
fi

# update /etc/resolv.conf 
> /etc/resolv.conf
cat >> /etc/resolv.conf << EOF
options timeout:1
# nameserver 127.0.0.1
nameserver 223.5.5.5
EOF

# update /etc/sysctl.conf 优化内核参数
echo '优化内核参数'
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies=1
kernel.core_uses_pid=1
kernel.core_pattern=/tmp/core-%e-%p
fs.suid_dumpable=2
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_tw_recycle=0
net.ipv4.tcp_timestamps=1
EOF
sysctl -p

cat >> /etc/vimrc << EOF
set nu
set ts=4
EOF
