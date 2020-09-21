#!/bin/bash
tar xf `find ./ -maxdepth 1 -a -name 'jdk*' -a -type f` -C /usr/local  &> /dev/null || ( echo '当前目录下缺少jdk压缩包' && exit )
ln -s `find /usr/local/ -maxdepth 1 -a -name 'jdk*' -a -type d` /usr/local/java
cat > /etc/profile.d/java.sh << EOF
export JAVE_HOME=/usr/local/java
export PATH=\$PATH:\$JAVE_HOME/bin
EOF
source /etc/profile.d/java.sh
