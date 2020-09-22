#!/bin/bash
random=({1..33})
i=0
ball=()
while [ $i -lt 6 ];do
    a=$[$RANDOM%33]
    [ -n "${random[$a]}" ] && ball[$i]=${random[$a]} && unset random[$a]  && let i++
done
echo ${ball[*]}
