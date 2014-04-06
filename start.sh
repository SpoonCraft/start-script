#!/bin/bash
# /etc/init.d/spooncraft
# version 0.0.4 2014-06-04 (YYYY-MM-DD)

### BEGIN INIT INFO
# Provides:	 spooncraft
# Required-Start: $local_fs $remote_fs
# Required-Stop:	$local_fs $remote_fs
# Should-Start:	 $network
# Should-Stop:		$network
# Default-Start:	2 3 4 5
# Default-Stop:	 0 1 6
# Short-Description:		spooncraft server
# Description:		Starts the spooncraft server
### END INIT INFO

#Settings
### At the moment, we're not starting this as a service on system boot
SERVICENAME='spooncraft'
SERVICE='craftbukkit-beta.jar'
OPTIONS='nogui'
USERNAME='spooncraft'
MCPATH='server/'
INVOCATION="java -server -d64 -Djline.terminal=jline.UnsupportedTerminal -Xmx10G -Xms3G -Xmn512M -XX:+UseG1GC -XX:+AggressiveOpts -XX:+UseFastAccessorMethods  -XX:TargetSurvivorRatio=90 -XX:MaxGCPauseMillis=200 -XX:MaxPermSize=256m -jar $SERVICE --log-strip-color $OPTIONS"

ME=`whoami`
as_user() {
	if [ $ME == $USERNAME ] ; then
		bash -c "$1"
	else
		su - $USERNAME -c "$1"
	fi
}

mc_start() {
	if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
	then
		echo "$SERVICENAME is already running!"
	else
		echo "\e[0;31mStarting $SERVICENAME..."
		cd $MCPATH
		as_user "cd $MCPATH && screen -dmS spooncraft $INVOCATION"
		sleep 15
		if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
		then
			echo "$SERVICENAME is now running."
		else
			echo "Error! Could not start $SERVICENAME!"
		fi
	fi
}

mc_stop() {
	if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
	then
		echo "Stopping $SERVICENAME"
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"say Der Server wird in 10 Sekunden ausgeschaltet. Speichere Karte...\"\015'"
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"save-all\"\015'"
		sleep 10
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"kickall Server wird ausgeschaltet.\"\015'"
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"stop\"\015'"
		sleep 15
	else
		echo "$SERVICENAME was not running."
	fi
	if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
	then
		echo "Error! $SERVICENAME could not be stopped."
	else
		echo "$SERVICENAME is stopped."
	fi
}

mc_restart() {
	if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
	then
		echo "Restarting $SERVICENAME"
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"say Der Server startet in 10 Sekunden neu! Speichere Karte...\"\015'"
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"save-all\"\015'"
		sleep 10
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"kickall Server is restarting.\"\015'"
		as_user "screen -p 0 -S spooncraft -X eval 'stuff \"stop\"\015'"
		sleep 15
	else
		echo "$SERVICENAME was not running."
	fi
	if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
	then
		echo "Error! $SERVICENAME could not be stopped."
	else
		echo "$SERVICENAME is stopped."
	fi
}

#Start-Stop here
case "$1" in
	start)
		mc_start
		;;
	stop)
		mc_stop
		;;
	restart)
		mc_restart
		mc_start
		;;
	status)
		if ps ax | grep -v grep | grep -v -i SCREEN | grep $SERVICE > /dev/null
		then
			echo "$SERVICENAME is running."
		else
			echo "$SERVICENAME is not running."
		fi
		;;
	*)
	echo "Usage: service spooncraft {start|stop|status|restart}"
	exit 1
	;;
esac

exit 0
