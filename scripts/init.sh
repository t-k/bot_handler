#!/bin/sh
#
# chkconfig: 35 99 99
# description: Script for starting phantomjs.
#

. /etc/rc.d/init.d/functions

USER="phantomjs"
APP="/usr/local/bot_handler/server.js"
DAEMON="path_to/phantomjs"
LOG_FILE="/dev/null"
ENVIRONMENT="production"
PID="/var/run/phantomjs/phantomjs.pid"
SLOCK="/var/lock/subsys/phantomjs"

do_start()
{
        echo -n $"Starting PhantomJS : "
        runuser -l "$USER" -c "PHANTOM_ENV=$ENVIRONMENT $DAEMON $APP >> $LOG_FILE &" && echo_success || echo_failure
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch $SLOCK
        return $RETVAL
}
do_stop()
{
        # Stop PhantomJS
        if [ -e "$PID" ]; then
            echo -n $"Stopping PhantomJS: "
            killproc -p $PID
            RETVAL=$?
            echo
            [ $RETVAL -eq 0 ] && rm -f $SLOCK
            return $RETVAL
        else
            echo "Error! PhantomJS server is not running!" 1>&2
            exit 1
        fi
}
get_status() {
    status -p $PID phantomjs
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
        status)
                get_status
                ;;
        *)
                echo "Usage: $0 {start|stop|restart|status}"
                RETVAL=1
esac

exit $RETVAL