#!/bin/bash
PS3="Your choice is[10 for quit]:"
[ $USER != "root" ] && echo "Please use the root account operation." && exit 1
! which vmstat &> /dev/null  && echo "vmstat command not found,now the install." && yum -y install procps && echo "---------------------------------------------"
! which iostat &> /dev/null  && echo "iostat command not found,now the install." && yum -y install sysstat && echo "---------------------------------------------"
READ(){
read -p "Press any key to continue:" biao
}
CPU_load(){
# CPU利用率和负载
echo "----------------------------------------------------"
for i in {1..3};do
    echo -e  "\033[32m    参考值$i\033[0m"
    util=`vmstat | sed -n '3p' | awk '{print $15}'`
    user_load=`vmstat | sed -n '3p' | awk '{print $13}'`
    sys_load=`vmstat | sed -n '3p' | awk '{print $14}'`
    io_wait=`vmstat | sed -n '3p' | awk '{print $16}'`
    echo -e "Util: \033[31m$[100-$util]%\033[0m"
    echo -e "User load: \033[31m$user_load%\033[0m"
    echo -e "System load: \033[31m$sys_load%\033[0m"
    echo -e "I/O wait: \033[31m$io_wait%\033[0m"
    sleep 1
done
echo "---------------------------------------------------"
READ
}

# 硬盘IO负载
IO_load(){
echo "---------------------------------------------------"
for i in {1..3};do
    echo -e  "\033[32m    参考值$i\033[0m"
    util=`iostat -x -k | awk '/^s/{print $1": "$NF}'`
    io_wait=`vmstat | sed -n '3p' | awk '{print $16}'`
    reads=`iostat -x -k | awk '/^s/{print $1": "$6"KB"}'`
    write=`iostat -x -k | awk '/^s/{print $1": "$7"KB"}'`
    echo -e "\033[33mUtil:\n$util%\033[0m"
    echo -e "\033[33mI/O Wait: $io_wait%\033[0m"
    echo -e "\033[33mRead/s:\n$reads%\033[0m"
    echo -e "\033[33mWrite/s:\n$write%\033[0m"
    sleep 1
done
echo "--------------------------------------------------"
READ
}

#硬盘利用率
DISK_use(){
disk_log=/tmp/disk.log
disk_total=`fdisk -l | awk '/^Disk \/dev.*bytes/{print $2,$3$4}' | sed -r 's/,$//'`
disk_util=`df -h | grep -v 'Use'|awk -F " +|%" '{print $7"="$5"%"}'`
for i in $disk_util;do
    a=`echo $i | awk -F "=|%" '{print $2}'`
    b=`echo $i | awk -F "=" '{print $1}'`
    [ $a -ge 90 ] && echo "$b = $a%" >> $disk_log
done
echo "--------------------------------------------------"
echo -e "Disk total:\n\033[33m$disk_total\033[0m"
if [ -f $disk_log ];then
    echo "--------------------------------------------------"
    cat $disk_log
    echo "--------------------------------------------------"
    rm -rf $disk_log
else
    echo "--------------------------------------------------"
    echo "Diek use rate no than 90% of the partition."
    echo "--------------------------------------------------"
fi
READ
}

#磁盘inode利用率
DISK_inode(){
disk_log=/tmp/disk.log
disk_util=`df -i | grep -v 'IUse'|awk -F " +|%" '{print $7"="$5"%"}'`
for i in $disk_util;do
    a=`echo $i | awk -F "=|%" '{print $2}'`
    b=`echo $i | awk -F "=" '{print $1}'`
    [ $a -ge 90 ] && echo "$b = $a%" >> $disk_log
done

if [ -f $disk_log ];then
    echo "--------------------------------------------------"
    cat $disk_log
    echo "--------------------------------------------------"
    rm -rf $disk_log
else
    echo "--------------------------------------------------"
    echo "Diek use rate no than 90% of the partition."
    echo "--------------------------------------------------"
fi
READ
}

#内存利用率
MEM_use(){
echo "--------------------------------------------------"
mem_total=`free -mh |grep 'Mem' |awk '{print $2}'`
mem_use=`free -mh |grep 'Mem' |awk '{print $3}'`
mem_free=`free -mh |grep 'Mem' |awk '{print $4}'`
mem_cache=`free -mh |grep 'Mem' |awk '{print $6}'`
echo -e "Total: \033[33m$mem_total\033[0m"
echo -e "Use: \033[33m$mem_use\033[0m"
echo -e "Free: \033[33m$mem_free\033[0m"
echo -e "Cache: \033[33m$mem_cache\033[0m"
echo "--------------------------------------------------"
READ
}

#TCP连接状态
TCP_status(){
echo "--------------------------------------------------"
tcp_status=`netstat -ant | sed -n '3,$p' |awk '{state[$6]++}END{for(i in state){print i,state[i]}}'`
echo -e "TCP connection status:\n\033[32m$tcp_status\033[0m"
echo "--------------------------------------------------"
READ
}

#CPU占有率进程TOP10
CPU_top10(){
echo "--------------------------------------------------"
cpu_log=/tmp/cpu_progress.log
for i in {1..3};do
    ps aux --sort -%cpu |sed -n '2,11p' |awk '{if($3>=0.1){{printf "PID: "$2" CPU: "$3"% --> "}{for(a=11;a<=NF;a++){printf $a" "};printf"\n"}}}' > $cpu_log
    #commands=`ps aux --sort -%cpu |sed -n '2,11p' |awk '{for(a=11;a<=NF;a++){printf $a" "};printf"\n"}'`
    if [ -n "`cat $cpu_log`" ];then
        echo -e  "\033[32m   参考值$i\033[0m"
        cat $cpu_log && rm -rf $cpu_log
    else
        echo -e "\033[33mNo process using the CPU.\033[0m"
    fi
    sleep 1
done
echo "--------------------------------------------------"
READ
}

#MEM内存占有率进程TOP10
MEM_top10(){
echo "--------------------------------------------------"
mem_log=/tmp/mem_progress.log
for i in {1..3};do
    ps aux --sort -%mem |sed -n '2,11p' |awk '{if($4>0.1){{printf "PID: "$2" MEM: "$4"% --> "}{for(a=11;a<=NF;a++){printf $a" "};printf"\n"}}}' > $mem_log
    if [ -n "`cat $mem_log`" ];then
        echo -e  "\033[32m   参考值$i\033[0m"
        cat $mem_log && rm -rf $mem_log
    else
        echo -e "\033[33mNo process using the MEM.\033[0m"
    fi
    sleep 1
done
echo "--------------------------------------------------"
READ
}

#查看当前网络流量
NET_flow(){
while true;do
    read -p "Please enter the network card name(eth[0-9] or em[0-9] or team[0-9] or ensXX): " eth
    if [ `ifconfig |grep -c "\<$eth\>" 2> /dev/null` -eq 1 ];then
        break
    else
        echo "Input format error or Don't have the card name,please input again."
    fi
done
echo "--------------------------------------------------"
echo -e  " In------Out"
for i in {1..3};do
    rx_old=`ifconfig $eth |sed -n '5p'|awk '{print $5}'`
    tx_old=`ifconfig $eth |sed -n '7p'|awk '{print $5}'`
    sleep 1
    rx_new=`ifconfig $eth |sed -n '5p'|awk '{print $5}'`
    tx_new=`ifconfig $eth |sed -n '7p'|awk '{print $5}'`
    let rx_in=(rx_new-rx_old)/128 && let tx_out=(tx_new-tx_old)/128
    echo -e "\033[33m ${rx_in}KB/s ${tx_out}KB/s\033[0m"
done
echo "--------------------------------------------------"
READ
}

while true;do
    clear
    select choice in CPU_load IO_load DISK_use DISK_inode MEM_use TCP_status CPU_top10 MEM_top10 NET_flow quit;do
        case "$choice" in
            CPU_load)
                CPU_load;
                break;;
            IO_load)
                IO_load;
                break;;
            DISK_use)
                DISK_use;
                break;;
            DISK_inode)
                DISK_inode
                break;;
            MEM_use)
                MEM_use
                break;;
            TCP_status)
                TCP_status
                break;;
            CPU_top10)
                CPU_top10
                break;;
            MEM_top10)
                MEM_top10
                break;;
            NET_flow)
                NET_flow
                break;;
            quit)
                exit
                 ;;
            *)
                echo "Invalid input,Please enter a valid format."
                break;;
        esac
    done
done
