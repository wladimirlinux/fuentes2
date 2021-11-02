#!/bin/sh

LIMIT_CLI=/my_tools/calllimit_cli
RET_RESULT="error"

cmd=$1
channel=$2

#echo "cmd=$cmd, channel=$channel."
case $cmd in
	"reload")
	$LIMIT_CLI set chn reload
	;;
	"unlock")
	$LIMIT_CLI set chn unlock $channel
	;;
	"unmark")
	$LIMIT_CLI set chn unmark $channel
	;;
	"unlimited")
        $LIMIT_CLI clean chn limited $channel
        ;;
	"status")
        $LIMIT_CLI show chn status $channel
        ;;
	"filewrite")
        $LIMIT_CLI set filewrite switch $2 
		;;
	"resetcalltime")
		$LIMIT_CLI set chn calltimecnt $channel 0
		;;
	*)
	;;
esac
RET_RESULT=$?
#echo "$RET_RESULT"

