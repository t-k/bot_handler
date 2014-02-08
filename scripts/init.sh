#!/bin/sh
#
# chkconfig: 35 99 99
# description: Script for starting phantomjs.
#

. /etc/rc.d/init.d/functions

USER="phantomjs"
APP="/usr/local/bot_handler/server.js"
DAEMON="path_to/phantomjs $APP"
LOG_FILE="/dev/null"

do_start()
{
        echo -n $"Starting PhantomJS : "
        runuser -l "$USER" -c "$DAEMON >> $LOG_FILE &" && echo_success || echo_failure
        RETVAL=$?
  echo
        [ $RETVAL -eq 0 ]
}
do_stop()
{
        echo -n $"Stopping PhantomJS : "
        pid=`ps -aefw | grep "$DAEMON" | grep -v " grep " | awk '{print $2}'`
        kill -9 $pid > /dev/null 2>&1 && echo_success || echo_failure
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ]
}

case "$1" in
        start)
                do_start
                ;;
        stop)
                do_stop
                ;;
        restart)
                do_stop
                do_start
                ;;
        *)
                echo "Usage: $0 {start|stop|restart}"
                RETVAL=1
esac

exit $RETVAL