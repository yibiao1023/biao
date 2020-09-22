XianShi(){
echo    "*************************" 
echo    "* 1.安装nginx           *"
echo    "* 2.安装mysql           *"
echo    "* 3.安装php             *"
echo    "* 4.退出                *"
echo    "*************************" 
}

Choice(){
read -p "请选择你要进入的模式[1-4]:" choice
}

Install_nginx(){
    [ -d /usr/local/nginx ] && echo 'nginx以安装。' && continue
    [ ! -f ./nginx*.tar.gz ] && echo "该目录下没有nginx源码包。" && continue
    yum -y install   gcc   make   zlib-devel  pcre  pcre-devel  openssl-devel 
    [ $? ne 0 ] && echo "配置环境信息失败，请检查网络是否正常" && continue
    useradd -s /sbin/nologin nginx
    tar -xf nginx*.tar.gz
    dir=`find ./ -maxdepth 1 -a -name 'nginx*' -a -type d` && cd $dir
    ./configure --prefix=/usr/local/nginx --user=nginx --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre 
    make  && make install && echo "源码包安装nginx成功！"
    cd .. && rm -rf $dir
}

Install_mysql(){
    [ -d /usr/local/mysql ] && echo 'mysql以安装。' && continue
    [ ! -f ./mysql*.tar.gz ] && echo "该目录下没有mysql源码包。" && continue
    yum -y install ncurses ncurses-devel openssl-devel bison gcc gcc-c++ make cmake 
    [ $? ne 0 ] && echo "配置环境信息失败，请检查网络是否正常" && continue
    useradd -s /bin/nologin mysql
    tar -xf mysql*.tar.gz
    dir=`find ./ -maxdepth 1 -a -name 'mysql*' -a -type d` && cd $dir
    if [ ! -f ../boost*.tar.gz ];then
        wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
        [ $? ne 0 ] && echo "下载boost库下载失败" && continue   
    else
        cp ../boost*.tar.gz ./
    fi
    tar -xf boost*.tar.gz
    cmake . -DWITH_BOOST=boost_1_59_0/ -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DSYSCONFDIR=/etc -DMYSQL_DATADIR=/usr/local/mysql/data -DINSTALL_MANDIR=/usr/share/man -DMYSQL_TCP_PORT=3306 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8 -DEXTRA_CHARSETS=all -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1
    make && make install && echo "源码包安装mysql安装成功！"
    cd .. && rm -rf $dir
	
}

Install_php(){
    [ -d /usr/local/php ] && echo 'php以安装。' && continue
    [ ! -f ./php*.tar.* ] && echo "该目录下没有php源码包。" && continue
    yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel libcurl libcurl-devel libxslt-devel openssl-devel 
    [ $? ne 0 ] && echo "配置环境信息失败，请检查网络是否正常" && continue
    tar -xf php*.tar.*
    dir=`find ./ -maxdepth 1 -a -name 'php*' -a -type d` && cd $dir
    ./configure --prefix=/usr/local/php --with-curl --with-freetype-dir --with-gd --with-gettext --with-iconv-dir --with-jpeg-dir --with-kerberos --with-libdir=lib64 --with-libxml-dir --with-mysql --with-mysqli --with-openssl --with-pcre-regex --with-pdo-mysql --with-pdo-sqlite --with-pear --with-png-dir --with-xmlrpc --with-xsl --with-zlib --enable-fpm --enable-bcmath --enable-libxml --enable-inline-optimization --enable-gd-native-ttf --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-xml --enable-zip
    make && make install && echo "源码包安装php成功！"
    cd .. && rm -rf $dir
    
}

while :;do
    XianShi
    Choice
    case $choice in 
1 )
    Install_nginx
    ;;
2 )
    Install_mysql
    ;;
3 )
    Install_php
    ;;
4 )
    exit;
    ;;
* )
    echo "只能输入[1-4]模式！！！"
    esac
done
