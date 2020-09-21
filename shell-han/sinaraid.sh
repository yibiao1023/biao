#!/bin/bash
#set -x

[ $1 -eq 0 ] && exit

#MACHINE=`dmidecode -t system | awk '/Manufacturer:/{ if(match($0,/Dell/)) print "DELL"; else if(match($0,/HP/)) print "HP"; else if(match($0,/IBM/)) print "IBM"; else if(match($0,/Huawei/)) print "HUAWEI"; else if(match($0,/Inspur/)) print "INSPUR"; else if(match($0,/SuperCloud/)) print "SUPERCLOUD";else if(match($0,/Sugon/)) print "SUGON"; else if(match($0,/Quanta/)) print "QUANTA"; else print "Uknown"; }'`
MACHINE=`dmidecode -t system | awk '/Manufacturer:/{ if(match($0,/HP/)) print "HP";else print "NOT_HP" }'`
if [ $MACHINE = "NOT_HP" ]; then


if [ ! -f "/opt/MegaRAID/MegaCli/MegaCli64" ]; then
  MEGAPATH="/sbin/MegaCli64"
else
  MEGAPATH="/opt/MegaRAID/MegaCli/MegaCli64"
fi


#### the count of disk #####
PDCOUNT=`$MEGAPATH -pdlist -aall | awk '/Slot Number/{ count++; } END { print count; }'`

$MEGAPATH -pdlist -aall | awk -F': ' '/^PD Type/{ PDTYPE=$2 }
/^Raw Size/{ gsub(/ \[.*\]$/,""); RAWSIZE=$2; } 
{ printf "%s-%s\n",PDTYPE,RAWSIZE,UNIT }' | wc -l 

###### check disk foreign state ######
function check_foreign ()
{
	#$MEGAPATH -CfgForeign -Scan -a0
	$MEGAPATH -CfgForeign -Clear -a0
}

check_foreign

##### check raid controller #####
function check_raid()
{
	/sbin/lspci | grep "RAID bus controller"
	if [ $? -ne 0 ] ; then
		echo "Please be sure there is raid bus controller !!!!"
		exit;
	fi 
}

##### check pddisk type SASA/SCSI #####
function check_pd ()
{
	PDS=$1
	[ -z $PDS ] && PDS=0
	PDE=$2
	[ -z $PDE ] && PDE=$PDCOUNT
	$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count='"$PDS"'; }
	/^PD Type/{ if(match($0,/SAS/)) { PDTYPE[count]="SAS"; } else if(match($0,/SATA/)) { PDTYPE[count]="SATA"; }  else { PDTYPE[count]=$2 ; } }
	/^Raw Size/{ gsub(/ \[.*\]$/,""); RAWSIZE[count]=$2; ++count; } 
	END { for(i='"$PDS"';i<'"$PDE"';i++) printf "%s-%s\n",PDTYPE[i],RAWSIZE[i]; }' | sort -u > /tmp/pdsum.txt
	
	if [ `cat /tmp/pdsum.txt | wc -l` -ne 1 ] ; then
		echo "The PD TYPE is not yizhi !!!!"
		#exit
	fi

}

##### check disk count #####
function check_disk()
{
	echo "There is $PDCOUNT DISKS"
	if [ $PDCOUNT -lt $1 ] ; then
		echo "DISK COUNT is not enough !!!!"
	fi	
	if [ ! -z $2 ] && [ $2 = "oushu" ] ; then
		if [ $(($1%2)) -ne 0 ] ; then
			echo "DISK COUNT is not oushu !!!!"
			exit
		fi
	fi 
}

function raid0_all ()
{
	PDSTART=$1
	[ -z $PDSTART ] && PDSTART=0
	PDEND=$2
	[ -z $PDEND ] && PDEND=$PDCOUNT
	check_disk $(($PDEND-$PDSTART))
	check_pd $PDSTART $PDEND
        PDLIST=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`
	
	echo $PDLIST

        $MEGAPATH -CfgClr -aALL 
        $MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST]" -Force -a0
        $MEGAPATH -CfgLdAdd -r0 "[$PDLIST]" -a0
	python /mnt/runtime/usr/lib/anaconda/isys.py driveDict

}

function raid0_single2 ()
{
	check_disk 1
	$MEGAPATH -CfgClr -aALL
	$MEGAPATH -CfgEachDskRaid0  -a0
	python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
}

#### usage : raid0_single [PDSTART] [PDEND] [VDNUM] [noclear] ######
function raid0_single ()
{

        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	VDNUM=$3
	check_disk $(($PDEND-$PDSTART))
	check_pd $PDSTART $PDEND
	$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) printf "%d:%d\n",ED[i],SN[i]; }' | sed 's/\,$/\n/' > /tmp/pdlist.txt

        if [ "$4" = "noclear" ]
        then :
        else
                $MEGAPATH -CfgClr -aALL
        fi
	while read line
	do
        	echo $line
		PDLIST=$line
		$MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST]" -Force -a0  
		$MEGAPATH -CfgLdAdd -r0 "[$PDLIST]" -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
	done < /tmp/pdlist.txt
	
}

function raid1 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	VDNUM=$3
	#check_disk 2 oushu
	check_disk $(($PDEND-$PDSTART)) oushu
	check_pd $PDSTART $PDEND
        PDLIST=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`

	if [ "$4" = "noclear" ]
	then :
	else
		$MEGAPATH -CfgClr -aALL  
	fi
	$MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST]" -Force -a0  
	if [ -z $VDNUM ] ; then
		$MEGAPATH -CfgLdAdd -r1 "[$PDLIST]" -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
	else
		$MEGAPATH -CfgLdAdd -r1 "[$PDLIST]" -Afterld${VDNUM} -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
	fi
}

function raid10 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
        check_disk 4 oushu
        check_disk $(($PDEND-$PDSTART)) oushu
        check_pd $PDSTART $PDEND
        $MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) { if((i%2)!=0) { printf "%d:%d\n",ED[i],SN[i]; } else { printf "%d:%d,",ED[i],SN[i]; } }}' > /tmp/raid10.log

        $MEGAPATH -CfgClr -aALL
        $MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST0,$PDLIST1]" -Force -a0
        linenum=`wc -l raid10.log`

        #for(i=0;i<$linenum;i++)
        arrnum=0
        for line in `cat /tmp/raid10.log`
        do
                ARGVS=$ARGVS\ -array${arrnum}"[$line]"
                arrnum=$(($arrnum+1))
        done < /tmp/raid10.log
        echo $ARGVS
        #$MEGAPATH -CfgSpanAdd -r10 -array0"[$]" -array1"[$PDLIST1]" -a0
        $MEGAPATH -CfgSpanAdd -r10 $ARGVS -a0
        python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
}

function raid5 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	VDNUM=$3
	check_disk 3
	check_disk $(($PDEND-$PDSTART))
	check_pd $PDSTART $PDEND
        PDLIST=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`

        if [ "$4" = "noclear" ]
        then :
        else
                $MEGAPATH -CfgClr -aALL
        fi
	$MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST]" -Force -a0  

        if [ -z $VDNUM ] ; then
                $MEGAPATH -CfgLdAdd -r5 "[$PDLIST]" -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        else
                $MEGAPATH -CfgLdAdd -r5 "[$PDLIST]" -Afterld${VDNUM} -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        fi
}

function raid5_h1 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	VDNUM=$3
	check_disk 4
	check_disk $(($PDEND-$PDSTART))
	check_pd $PDSTART $PDEND
	#$MEGAPATH -CfgClr -aALL 
	PDLIST=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`
	
        if [ "$4" = "noclear" ]
        then :
        else
                $MEGAPATH -CfgClr -aALL
        fi
	$MEGAPATH -PDMakeGood -PhysDrv "[${PDLIST}]"  -Force -a0 
        if [ -z $VDNUM ] ; then
                $MEGAPATH -CfgLdAdd -r5 "[${PDLIST%,*}]" -Hsp"[${PDLIST##*,}]" -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        else
                $MEGAPATH -CfgLdAdd -r5 "[${PDLIST%,*}]" -Hsp"[${PDLIST##*,}]" -Afterld${VDNUM} -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        fi
}

function raid50 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	#check_disk 4 oushu
	check_disk $(($PDEND-$PDSTART)) oushu
	check_pd $PDSTART $PDEND

	check_disk 6 oushu


        $MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) { if(((i+1)%3)==0) { printf "%d:%d\n",ED[i],SN[i]; } else { printf "%d:%d,",ED[i],SN[i]; } }}' > /tmp/raid50.log

        $MEGAPATH -CfgClr -aALL
        linenum=`wc -l raid50.log`

        #for(i=0;i<$linenum;i++)
        arrnum=0
        for line in `cat /tmp/raid50.log`
        do      
                ARGVS=$ARGVS\ -array${arrnum}"[$line]"
                arrnum=$(($arrnum+1))
        done < /tmp/raid50.log
        echo $ARGVS
        #$MEGAPATH -CfgSpanAdd -r10 -array0"[$]" -array1"[$PDLIST1]" -a0
        $MEGAPATH -CfgSpanAdd -r50 $ARGVS -a0
        python /mnt/runtime/usr/lib/anaconda/isys.py driveDict

}

function raid6 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	VDNUM=$3
        check_disk $(($PDEND-$PDSTART))
	check_pd $PDSTART $PDEND
	check_disk 4 
        PDLIST=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i=0;i<count;i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`

        if [ "$4" = "noclear" ]
        then :
        else
                $MEGAPATH -CfgClr -aALL
        fi
	$MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST]" -Force -a0  
        if [ -z $VDNUM ] ; then
                $MEGAPATH -CfgLdAdd -r6 "[$PDLIST]" -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        else
                $MEGAPATH -CfgLdAdd -r6 "[$PDLIST]" -Afterld${VDNUM} -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        fi
}

function raid6_h1 ()
{
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
        check_disk $(($PDEND-$PDSTART))
	check_pd $PDSTART $PDEND
	check_disk 5 
        PDLIST=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i=0;i<count;i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`

        if [ "$4" = "noclear" ]
        then :
        else
                $MEGAPATH -CfgClr -aALL
        fi
	$MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST]" -Force -a0  
        if [ -z $VDNUM ] ; then
                $MEGAPATH -CfgLdAdd -r6 "[${PDLIST%,*}]" -Hsp"[${PDLIST##*,}]" -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        else
                $MEGAPATH -CfgLdAdd -r6 "[${PDLIST%,*}]" -Hsp"[${PDLIST##*,}]" -Afterld${VDNUM} -a0
		python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
        fi
}

function raid60 ()
{

        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	check_disk 4 oushu
	check_disk $(($PDEND-$PDSTART)) oushu
	check_pd $PDSTART $PDEND

	#check_disk 8 oushu


        $MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDSTART"';i<'"$PDEND"';i++) { if(((i+1)%4)==0) { printf "%d:%d\n",ED[i],SN[i]; } else { printf "%d:%d,",ED[i],SN[i]; } }}' > /tmp/raid60.log

        $MEGAPATH -CfgClr -aALL
        linenum=`wc -l raid60.log`

        #for(i=0;i<$linenum;i++)
        arrnum=0
        for line in `cat /tmp/raid60.log`
        do
                ARGVS=$ARGVS\ -array${arrnum}"[$line]"
                arrnum=$(($arrnum+1))
        done < /tmp/raid60.log
        echo $ARGVS
        #$MEGAPATH -CfgSpanAdd -r10 -array0"[$]" -array1"[$PDLIST1]" -a0
        $MEGAPATH -CfgSpanAdd -r60 $ARGVS -a0
        python /mnt/runtime/usr/lib/anaconda/isys.py driveDict

}

function raid_self ()
{
	PDB=$1
	PDB_RAID=$2
	PDA_RAID=$3
	check_disk $PDB
        PDLIST0=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i=0;i<'"$PDB"';i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`

        PDLIST1=`$MEGAPATH -pdlist -aall | awk -F': ' 'BEGIN { count=0; }
        /Enclosure Device ID/{ ED[count]=$2; }
        /Slot Number/{ SN[count]=$2;  ++count; }
        END { for(i='"$PDB"';i<count;i++) printf "%d:%d,",ED[i],SN[i]; }' | sed 's/\,$/\n/'`

        $MEGAPATH -CfgClr -aALL
        $MEGAPATH -PDMakeGood -PhysDrv "[$PDLIST0,$PDLIST1]" -Force -a0
        $MEGAPATH -CfgldAdd -r${PDB_RAID} "[$PDLIST0]" -a0
        $MEGAPATH -CfgldAdd -r${PDA_RAID} "[$PDLIST1]" -a0
        #$MEGAPATH -CfgSpanAdd -r60 -array0"[$PDLIST0]" -array1"[$PDLIST1]" -a0
	python /mnt/runtime/usr/lib/anaconda/isys.py driveDict
}

RAID_LEVEL=$1

if [ -z $RAID_LEVEL ] ; then
cat <<- RAID
	1. RAID0_ALL
	2. RAID0_SINGLE
	3. RAID1
	4. RAID10
	5. RAID5
	6. RAID5_HOTSPARE1
	7. raid50
	8. RAID6
	9. RAID6_HOTSPARE1
	10. RAID60
	11. RAID_SELF
RAID
read -p "Input raid level : " RAID_LEVEL
fi

case $RAID_LEVEL in
	1|RAID0_ALL)	raid0_all
	;;
	2|RAID0_SINGLE)	raid0_single
	;;
	3|RAID1)	raid1 0 2
	;;
	4|RAID10)	raid10
	;;
	5|RAID5)	raid5
	;;
	6|RAID5_HOTSPARE1)	raid5_h1
	;;
	7|RAID50)	raid50
	;;
	8|RAID6)	raid6
	;;
	9|RAID6_HOTSPARE1)	raid6_h1
	;;
	10|RAID60)	raid60
	;;
	11|RAID_SELF)	
			B1=$2
			[ -z ${B1} ] && read -p "BEFORE xx DISK : " B1
			cat <<- BEFORE_RAID_SELF
       	1. BEFORE xx DISK raid1
       	5. BEFORE xx DISK raid5
BEFORE_RAID_SELF
			B1_raid=$3
			[ -z ${B1_raid}] && read -p "BEFORE xx RAID_LEVEL : " B1_raid
			PDLEFT=$(($PDCOUNT-$B1))
			cat <<- AFTER_RAID_SELF
	1. AFTER xx DISK raid1
	0. AFTER xx DISK raid0_single 
	5. AFTER xx DISK raid5
	51. AFTER xx DISK raid5_hotspare1
AFTER_RAID_SELF
			A_raid=$4
			[ -z $A_raid ] && read -p "OTHER RAID_LEVEL : " A_raid
			#raid_self $B1 $B1_raid $A_raid

		        case $B1_raid in
                		1)      raid1 0 $B1
                		;;
                		5)      raid5 0 $B1
                		;;
                		*)      echo "Unknown pipei B_raid"
					exit
                		;;
        		esac

        		case $A_raid in
                		1)      raid1 $B1 $PDCOUNT 0 noclear
                		;;
                		0)      raid0_single $B1 $PDCOUNT 0 noclear
                		;;
                		5)      raid5 $B1 $PDCOUNT 0 noclear
                		;;
				51)	raid5_h1 $B1 $PDCOUNT 0 noclear
				;;
				*)	echo "Unknown pipei A_raid"
					exit
			esac

	;;
	*)	echo "unknown raid level"
		exit
	;;
esac


elif [ $MACHINE = "HP" ]; then

HPCLIPATH="/sbin/hpacucli"

#$HPCLIPATH ctrl all show | awk 'BEGIN { count=0; }
#/Smart Array/{ Slot[count]=$6 }
#END { for(i=0;i<count;i++) printf "%d\n",Slot[i]; }' > /tmp/slot.txt

SLOT=`$HPCLIPATH ctrl all show status| awk '/Slot/{print $6}'`
PDCOUNT=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk -F', ' '/physicaldrive/' | wc -l `

function check_raid()
{
        lspci | grep "RAID bus controller"
        if [ $? -ne 0 ] ; then
                echo "Please be sure there is raid bus controller !!!!"
                exit;
        fi
}
check_raid

function check_disk()
{
        echo "There is $PDCOUNT DISKS"
        if [ $PDCOUNT -lt $1 ] ; then
                echo "DISK COUNT is not enough !!!!"
        fi
        if [ ! -z "$2" ] && [ $2 = "oushu" ] ; then
                if [ $(($1%2)) -ne 0 ] ; then
                        echo "DISK COUNT is not oushu !!!!"
                        exit
                fi
        fi	
}

function raid_clear ()
{
	echo "**************** start *************"
	$HPCLIPATH ctrl slot=$SLOT ld all show | awk '/array/' > /tmp/hparray.txt
	tac /tmp/hparray.txt > /tmp/hparray2.txt
	if [ "$1" = "clear" ] ; then
		while read line
		do
			echo y | $HPCLIPATH ctrl slot=$SLOT $line delete 
		done < /tmp/hparray2.txt
		#done < <($HPCLIPATH ctrl slot=0 ld all show | awk '/array/')
	fi
}

function check_pd()
{
	$HPCLIPATH ctrl slot=$SLOT pd all show | awk -F', ' '/physicaldrive/{ printf "%s-%s\n",$2,$3  }' | sort -u > /tmp/hppd.txt	

        if [ `cat /tmp/hppd.txt | wc -l` -ne 1 ] ; then
                echo "The PD TYPE is not yizhi !!!!"
                #exit
        fi
	
}

function raid0_all ()
{
raid_clear clear
	PDLIST=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
	/physicaldrive/{ PD[count]=$2 ; count++; }
	END { for(i=0;i<count;i++) printf "%s,",PD[i]; }' | sed 's/\,$/\n/'`
	echo $PDLIST 

	echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=$PDLIST raid=0
}


function raid0_single ()
{
raid_clear clear
	$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
      	/physicaldrive/{ PD[count]=$2 ; count++; }
       	END { for(i=0; i<count; i++) printf "%s\n",PD[i]; }' > /tmp/hparray.txt
	while read line
	do
               	echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=${line} raid=0
	done < /tmp/hparray.txt
}

function raid1 ()
{
raid_clear clear
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	check_disk 2 oushu
	check_disk $(($PDEND-$PDSTART)) oushu
        check_pd $PDSTART $PDEND
        PDLIST=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
        /physicaldrive/{ PD[count]=$2 ; count++; }
        END { for(i=0; i<count; i++) printf "%s,",PD[i]; }' | sed 's/\,$/\n/'`

        echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=$PDLIST raid=1+0

}

function raid5 ()
{
raid_clear clear
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
	check_disk 3 
        check_disk $(($PDEND-$PDSTART))
        check_pd $PDSTART $PDEND
        PDLIST=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
        /physicaldrive/{ PD[count]=$2 ; count++; }
        END { for(i=0; i<count; i++) printf "%s,",PD[i]; }' | sed 's/\,$/\n/'`

        echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=$PDLIST raid=5

}


function raid5_h1 ()
{
raid_clear clear
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
        check_disk 4 
        check_disk $(($PDEND-$PDSTART))
        check_pd $PDSTART $PDEND
        PDLIST=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
        /physicaldrive/{ PD[count]=$2 ; count++; }
        END { for(i=0; i<count; i++) printf "%s,",PD[i]; }' | sed 's/\,$/\n/'`

        echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=${PDLIST%,*} raid=5
        echo y | $HPCLIPATH ctrl slot=$SLOT array A add spares=${PDLIST##*,}
}

function raid50 ()
{
raid_clear clear
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
        check_disk 6 
        check_disk $(($PDEND-$PDSTART))
        check_pd $PDSTART $PDEND
        PDLIST=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
        /physicaldrive/{ PD[count]=$2 ; count++; }
        END { for(i=0; i<count; i++) printf "%s,",PD[i]; }' | sed 's/\,$/\n/'`

        echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=${PDLIST} raid=50
}

function raid6 ()
{
raid_clear clear
        PDSTART=$1
        [ -z $PDSTART ] && PDSTART=0
        PDEND=$2
        [ -z $PDEND ] && PDEND=$PDCOUNT
        check_disk 6 
        check_disk $(($PDEND-$PDSTART))
        check_pd $PDSTART $PDEND
        PDLIST=`$HPCLIPATH ctrl slot=$SLOT pd all show | awk 'BEGIN { count=0; }
        /physicaldrive/{ PD[count]=$2 ; count++; }
        END { for(i=0; i<count; i++) printf "%s,",PD[i]; }' | sed 's/\,$/\n/'`

        echo y | $HPCLIPATH ctrl slot=$SLOT create type=ld drives=${PDLIST} raid=6
}



RAID_LEVEL=$1

if [ -z $RAID_LEVEL ] ; then
cat <<- RAID
	1. raid0_all
	2. raid0_single
	3. raid1+0
	4. raid5
	5. raid5_hotspare1
	6. raid50
RAID
read -p "Input raid level : " RAID_LEVEL
fi

case $RAID_LEVEL in
	1|raid0_all)	raid0_all
	;;
	2|raid0_single)	raid0_single
	;;
	3|raid1)	raid1
	;;
	4|raid5)	raid5
	;;
	5|raid5_hotspare1)	raid5_h1
	;;
	6|raid50)	raid50
	;;
	7|raid6)	raid6
	;;
	*)	echo "Unknown raid level !!!!"
		exit
	;;
esac

else 
	echo "Uknown Machine Manufacturer!!!!"
	exit

fi
