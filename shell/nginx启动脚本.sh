  1 #!/bin/bash
  2
  3 # Comments to support chkconfig on RedHat Linux
  4 # chkconfig: 2345 60 90
  5 # description: A very useful lightweight WEB framework.
  6
  7 nginx=/usr/local/nginx/sbin/nginx
  8 case $1 in
  9 start)
 10     ( $nginx -s reopen 2> /dev/null && echo 'Starting Nginx SUCCESS!' ) || ( $nginx 2> /dev/null && echo 'Starting Nginx SUCCESS!') || echo echo 'ERROR! Nginx start falsed!' ;
 11     ;;
 12 stop)
 13     $nginx -s stop 2> /dev/null && echo 'Shutting down Nginx Success!' || echo 'ERROR! Nginx server PID file could not be found!' ;
 14     ;;
 15 restart)
 16     $nginx -s stop 2> /dev/null && echo 'Shutting down Nginx Success!' || echo 'ERROR! Nginx server PID file could not be found!'
 17     $nginx && echo 'Starting Nginx Success!';
 18     ;;
 19 reload)
 20     $nginx -s reload 2> /dev/null && echo 'Reloading Nginx Success!'|| echo 'ERROR! Nginx server PID file could not be found!';
 21     ;;
 22 *)
 23    echo 'Usage: nginx  {start|stop|restart|reload}  [ Nginx server options ]';
 24     ;;
 25 esac
