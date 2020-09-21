#!/bin/bash
function PLATFORM
{
value=$(/bin/uname -i)
if [[ $1 = 1 ]];then
 echo ${value}|awk -F'_' '{print $2}'
else 
 echo ${value}
fi
}

function MEGACLI
{
rpm -ql Lib_Utils > /dev/null 2>&1
if [ $? -ne 0 ];then
 echo -e "\033[33m Lib_Utils is not install \033[0m"
 rpm -ivh http://repos.sina.cn/sina/tools/Lib_Utils-1.00-09.noarch.rpm > /dev/null 2>&1
  if [ $? -eq 0 ];then
   echo -e "\033[32m Lib_Utils Installation success \033[0m"
  else
   echo -e "\033[31m Lib_Utils Installation failure \033[0m"
  fi
fi

rpm -ql MegaCli > /dev/null 2>&1
if [ $? -ne 0 ];then
 echo -e "\033[33m MegaCli is not install \033[0m"
 rpm -ivh http://repos.sina.cn/sina/tools/MegaCli-8.02.21-1.noarch.rpm > /dev/null 2>&1
  if [ $? -eq 0 ];then
   echo -e "\033[32m MegaCli Installation success \033[0m"
  else
   echo -e "\033[31m MegaCli Installation failure \033[0m"
  fi
fi
SOFT="/opt/MegaRAID/MegaCli/MegaCli$(PLATFORM 1)" && echo "{`$SOFT -CfgDsply -a0&& $SOFT -PDList -aALL `}"|egrep 'Enclosure Device ID:|Span Reference:|Number of PDs:|Number of VDs:|Number of dedicated Hotspares:|RAID Level|Mirror Data|State|Slot Number:|Media Error Count:|Last Predictive Failure Event Seq Number:|Firmware state:|Inquiry Data:'|grep -v ' State'|sed 's/ *//g'|sed 's/HotspareInformation://g'|sed 's/SpanReference:/\nSpanReference:/g'|sed 's/EnclosureDeviceID:/\n E:/g'|sed 's/SlotNumber:/Slot:/g'|sed 's/HotspareInformation://g'|sed 's/NumberofPDs/PD/g'|sed 's/NumberofVDs/VD/g'|sed 's/NumberofdedicatedHotspares/HPS/g'|sed 's/RAIDLevel/RAID/g'|sed 's/MirrorData/SIZE/g'|sed 's/State/State/g'|sed 's/SlotNumber:/Slot:/g'|sed 's/MediaErrorCount/MediaError/g'|sed 's/LastPredictiveFailureEventSeqNumber/FailNum/g'|sed 's/Firmwarestate/Status/g'|sed 's/InquiryData/SN/g'|sed 's/SpanReference:/LD/g'|sed ':a;N;$!ba;s/\n/  /g'|sed 's/  */ /g'|sed 's/LD/\nLD/g'|sed 's/ E:/\nE:/g'|sed '/$: /d'|sed 's/[ \t]*$//g'|awk ' !x[$0]++'
}

function STORCLI
{
rpm -ql Lib_Utils > /dev/null 2>&1
if [ $? -ne 0 ];then
 echo -e "\033[33m Lib_Utils is not install \033[0m"
 rpm -ivh http://repos.sina.cn/sina/tools/Lib_Utils-1.00-09.noarch.rpm > /dev/null 2>&1
  if [ $? -eq 0 ];then
   echo -e "\033[32m Lib_Utils Installation success \033[0m"
  else
   echo -e "\033[31m Lib_Utils Installation failure \033[0m"
  fi
fi

rpm -ql storcli > /dev/null 2>&1
if [ $? -ne 0 ];then
 echo -e "\033[33m StorCli is not install \033[0m"
 rpm -ivh http://repos.sina.cn/sina/tools/storcli-1.23.02-1.noarch.rpm > /dev/null 2>&1
  if [ $? -eq 0 ];then
   echo -e "\033[32m StorCli Installation success \033[0m"
  else
   echo -e "\033[31m StorCli Installation failure \033[0m"
  fi
fi
SOFT="/opt/MegaRAID/storcli/storcli$(PLATFORM 1)" && echo "{`$SOFT -CfgDsply -a0&& $SOFT -PDList -aALL `}"|egrep 'Enclosure Device ID:|Span Reference:|Number of PDs:|Number of VDs:|Number of dedicated Hotspares:|RAID Level|Mirror Data|State|Slot Number:|Media Error Count:|Last Predictive Failure Event Seq Number:|Firmware state:|Inquiry Data:'|grep -v ' State'|sed 's/ *//g'|sed 's/HotspareInformation://g'|sed 's/SpanReference:/\nSpanReference:/g'|sed 's/EnclosureDeviceID:/\n E:/g'|sed 's/SlotNumber:/Slot:/g'|sed 's/HotspareInformation://g'|sed 's/NumberofPDs/PD/g'|sed 's/NumberofVDs/VD/g'|sed 's/NumberofdedicatedHotspares/HPS/g'|sed 's/RAIDLevel/RAID/g'|sed 's/MirrorData/SIZE/g'|sed 's/State/State/g'|sed 's/SlotNumber:/Slot:/g'|sed 's/MediaErrorCount/MediaError/g'|sed 's/LastPredictiveFailureEventSeqNumber/FailNum/g'|sed 's/Firmwarestate/Status/g'|sed 's/InquiryData/SN/g'|sed 's/SpanReference:/LD/g'|sed ':a;N;$!ba;s/\n/  /g'|sed 's/  */ /g'|sed 's/LD/\nLD/g'|sed 's/ E:/\nE:/g'|sed '/$: /d'|sed 's/[ \t]*$//g'|awk ' !x[$0]++'
}

function SSACLI()
{
rpm -ql ssacli > /dev/null 2>&1
if [ $? -ne 0 ];then
 echo -e "\033[33m SsaCli is not install \033[0m"
 rpm -ivh http://repos.sina.cn/sina/tools/ssacli-3.10-3.0.$(PLATFORM).rpm > /dev/null 2>&1
  if [ $? -eq 0 ];then
   echo -e "\033[32m SsaCli Installation success \033[0m"
  else
   echo -e "\033[31m SsaCli Installation failure \033[0m"
  fi
fi
/sbin/modprobe sg
SOFT='/opt/smartstorageadmin/ssacli/bin/ssacli'&&ID=`$SOFT ctrl all show status |grep Slot |awk '{print $6}'` && $SOFT ctrl slot=$ID show config detail|sed 's/ *//g'|egrep 'LogicalDrive|^Array|MultiDomainStatus|DiskName|^physicaldrive|InterfaceType|^Size|DriveAuthenticationStatus|Model|^SerialNumber'|egrep -v 'Strip|ArrayType|\('|sed ':a;N;$!ba;s/\n/ /g'|sed 's/physicaldrive/\nphysicaldrive:/g'|sed 's/Array/\nArray/g'|sed 's/physicaldrive/slot/g'|sed 's/DriveAuthenticationStatus/DriverStatus/g'|sed 's/Model://g'|sed 's/MultiDomainStatus/ArrayStatus/g'|sed 's/InterfaceType/Type/g'|sed 's/SerialNumber/SN/g'
}

function Adaptec()
{
rpm -ql Arcconf > /dev/null 2>&1
if [ $? -ne 0 ];then
 echo -e "\033[33m Arcconf is not install \033[0m"
 rpm -ivh http://repos.sina.cn/sina/tools/Arcconf-2.01-22270.$(PLATFORM).rpm
  if [ $? -eq 0 ];then
   echo -e "\033[32m Arcconf Installation success \033[0m"
  else
   echo -e "\033[31m Arcconf Installation failure \033[0m"
  fi
fi
SOFT='/usr/Arcconf/arcconf' &&ID=`$SOFT list|grep Controller|egrep -v 'Controller ID|found|information'|cut -d: -f1|awk '{print $2}'`&& $SOFT getconfig $ID AL|sed 's/  */ /g'|sed 's/^ //g'|egrep 'Logical Device number|Status of Logical Device :|Size :|RAID level :|Device #|State :|Reported Channel,Device|Reported Location :|Vendor :|Model :|Serial number|Medium Error Count :|Aborted Command Count :'|egrep -v ' State| Size'|sed 's/Reported Channel,Device(T:L) /Channel,Device/g'|cut -d'(' -f1|sed ':a;N;$!ba;s/\n/  /g'|sed 's/Logical Device number /\nLD:/g'|sed 's/RAID level :/RAID:/g'|sed 's/Status of Logical Device :/Status:/g'|sed 's/Size :/Size:/g'|sed 's/ Device #/\nDevice:/g'|sed 's/State :/State:/g'|sed 's/Reported Location ://g'|sed 's/Vendor : /SN:/g'|sed 's/ *Model : *//g'|sed 's/Serial number : *//g'|sed 's/Medium Error Count /MediaError/g'|sed 's/Aborted Command Count /FailNum/g'|sed 's/ :/:/'|grep -v 'SXP'
}

function NORAID()
{
NX=`parted -l| grep 'Disk /dev' | wc | awk '{print $1}'`
NU=0
until [ $NU -ge $NX ]
do
NM=`expr $NU + 1`
DISK=`parted -l| grep 'Disk /dev' | awk '{print $2}' | sed 's/://g' |sort|sed -n "$NM, 1p"`
SOFT='smartctl' &&  echo "`echo $DISK && $SOFT -i $DISK && $SOFT -H $DISK `"|sed 's/ *//g'| egrep -i 'result|/dev|Vendor|Product|Serialnumber|SMARTHealthStatus'|sed ':a;N;$!ba;s/\n//g'|sed 's/Vendor:/ SN:/g'|sed 's/Product://g'|sed 's/Serialnumber://g'|sed 's/SMARTHealthStatus:/ Status:/g'|sed 's/\/dev/\n\/dev/g'
NU=`expr $NU + 1`
done
}

function RAID()
{
echo "========check RAID========"
/sbin/lspci|grep -i lsi|grep -i sas > /dev/null && RAID=SAS
/sbin/lspci|grep -i RAID|grep -i sata > /dev/null && RAID=SATA
/sbin/lspci|grep -i RAID|grep -i lsi > /dev/null && RAID=MEGA
/sbin/lspci|grep -i RAID|grep -i lsi|egrep -i '9280|9260cv|9266cv|9285' > /dev/null && RAID=STOR
/sbin/lspci|grep -i RAID|grep -i Hewlett > /dev/null && RAID=SSA
/sbin/lspci|grep -i RAID|grep -i Adaptec > /dev/null && RAID=Adaptec
if [ $RAID == STOR ];then
STORCLI
elif [ $RAID == MEGA ];then
MEGACLI
elif [ $RAID == SSA ];then
SSACLI
elif [ $RAID == Adaptec ];then
Adaptec
elif [ $RAID == SAS ]||[ $RAID == SATA ];then
NORAID
else
NORAID
echo -e "\033[31m This is NEW !!! \033[0m"
/sbin/lspci| egrep -i 'LSI|SCSI|IDE'
fi
}
RAID
