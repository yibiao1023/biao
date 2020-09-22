#!/bin/bash
file_path=a.txt
[ ! -f /usr/bin/expect ] && yum install expect -y # &> /dev/null
/usr/bin/expect <<EOF
set timeout 30
spawn ssh-keygen
expect "Enter file in which to save the key (/root/.ssh/id_rsa):"
send "\n"
expect {
    "Overwrite " { send "n\n" }
    "Enter passphrase (empty for no passphrase):" {
        send "\n"
        expect "Enter same passphrase again:"
        send "\n" }
}
expect eof
EOF
length=`cat $file_path | wc -l`
i=0
while [ $i -lt $length ];do
    let a=i+1
    ip=`sed -nr "${a}p" $file_path | awk '{print $1}'`
    pass=`sed -nr "${a}p" $file_path | awk '{print $2}'`
    let i++
    /usr/bin/expect <<EOF
    set timeout 30
    spawn  ssh-copy-id  $ip
    expect {
        "yes/no" { send "yes\n"; exp_continue }
        "root@$ip's password:" { send "$pass\n" }
    }
    expect eof
EOF
done

