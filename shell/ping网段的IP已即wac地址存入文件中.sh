#!/bin/bash
PING(){
    ping -c 1 -i 0.05 -W 1 $1 &> /dev/null
	[ $? -eq 0 ] && echo -n "$1 is up  " >> /tmp/hosts && arp $1 | tail -1 | awk '{print $3}' >> /tmp/hosts   
} 
my=`ip a | grep -E "inet\s" | tail -1 | awk '{print $2}' | awk -F "/" '{print $1}'`
myadress=`ip a | grep  'link/' |tail -1 | awk '{print $2}'`
echo -n "$my is up  " >> /tmp/hosts && echo $myadress  >> /tmp/hosts
for i in {1..254};do
    [ "10.3.134.$i" != "$my" ] && PING 10.3.134.$i 
done
