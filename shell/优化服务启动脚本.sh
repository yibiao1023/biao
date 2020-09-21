#!/bin/bash
realpath=$(readlink -f $0)
basedir=$(cd $(dirname $realpath)/../;pwd)
cd $basedir
java -jar ./springboot.jar --spring.config.location=./conf/application.yml