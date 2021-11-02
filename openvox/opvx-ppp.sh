#!/bin/sh

source /etc/profile

#opvx-pppd devname apn user password
echo "opvx-pppd options in effect:"
OPVX_PORT=/dev/opvx/internet/0
OPVX_APN=3gnet
OPVX_USER=user
OPVX_PASSWORD=passwd
OPVX_PORT=1
OPVX_PPP="ppp0"
OPVX_PING="ping"
BSP_CLI=/my_tools/bsp_cli
PING_TIME=10
URL="www.baidu.com"
INTERNET_APP=/my_tools/curl
KILL_APP=/my_tools/opvx-ppp-kill
TMP_PORT=1
SECTION=port1

#config
internet_sw=on
username=
passwd=
apn=3gnet
flow_total_size=1
flow_use_size=0
domain=www.baidu.com
url=www.baidu.com

total_channel=0
size=$[1*1024*1024]
use_size=0
one_size=0

select_internet_channel()
{
	$BSP_CLI upgrade sel $OPVX_PORT
	sleep 1
}

#check the network is connected?
test_internet()
{
	echo "$OPVX_PING -I $OPVX_PPP -w $PING_TIME $URL"
	$OPVX_PING -I $OPVX_PPP -w $PING_TIME $domain
	if [ $? -ne 0 ]; then
		echo " No network, exit "
		return 1
	fi
	return 0
}

get_one_size()
{

	tmp=`ls -al /tmp/internet1_log |awk '{print $5}'`
	one_size=$[tmp*3]
}

#get ppp0 rx size and tx size
get_use_size()
{
	use_size=`cat /proc/net/dev|grep ppp0|awk '{print $2+$10}'`
}

#surf the internet
go_to_internet()
{
	count=5
	while [ $count -gt 0 ]
	do
		$INTERNET_APP --interface $OPVX_PPP --insecure $URL -o /tmp/internet${OPVX_PORT}_log
		if [ $? -eq 0 ];then
			echo "get $URL success"
			return 0
		fi
		sleep 1
		count=$[count-1]
	done
	return 1
}

#get bord channel
get_module_channel()
{

    total_channel=`grep -rn total_chan_count /tmp/hw_info.cfg | awk -F = '{print $2}'`
    if [ $total_channel -eq 20 ];then
		mod_channel=4
    elif [ $total_channel -eq 44 ];then
		mod_channel=4
    else
		mod_channel=16
    fi 
}

#get the modem port syslink
set_internet_devname()
{
	select_internet_channel

	USB_PORT=$[$[$OPVX_PORT-1]/$mod_channel]
	OPVX_DEVNAME="/dev/opvx/internet/$USB_PORT"

}


get_value()
{
    SECTION=$1
    KEY=$2
    CONFILE=/etc/asterisk/gw_internet.conf
    eval $2=`awk -F '=' '/\['"$SECTION"'\]/{a=1}a==1&&$1~/'"$KEY"'/{print $2;exit}' $CONFILE`
}


get_config()
{
    get_value $1 internet_sw
    get_value $1 user
    get_value $1 passwd
    get_value $1 apn
    get_value $1 flow_total_size
    get_value $1 flow_use_size
	get_value $1 domain
    get_value $1 url

    use_size=$flow_use_size
	size=$[flow_total_size * 1024 * 1024]
	echo "$size"
    OPVX_APN=$apn
    OPVX_USER=$user
    OPVX_PASSWORD=$passwd
    URL=$url

    if [[ $internet_sw == "on" ]];then
		return 0
    fi

    return 1    
}

#pppd
ppp_and_internet()
{
	CONNECT="'chat -s -v ABORT BUSY ABORT \"NO CARRIER\" ABORT \"NO DIALTONE\" ABORT ERROR ABORT \"NO ANSWER\" TIMEOUT 30 \
	\"\" AT OK ATE0 OK ATI\;+CSUB\;+CSQ\;+CPIN?\;+COPS?\;+CGREG?\;\&D2 \
	OK AT+CGDCONT=1,\\\"IP\\\",\\\"$OPVX_APN\\\",,0,0 OK ATD*99# CONNECT'"

	pppd $OPVX_DEVNAME 115200 user "$OPVX_USER" password "$OPVX_PASSWORD" \
	connect "'$CONNECT'" \
	disconnect 'chat -s -v ABORT ERROR ABORT "NO DIALTONE" SAY "\nSending break to the modem\n" "" +++ "" +++ "" +++ SAY "\nGood bay\n"' \
	noauth debug defaultroute noipdefault novj novjccomp noccp ipcp-accept-local ipcp-accept-remote ipcp-max-configure 30 local lock modem dump nodetach nocrtscts usepeerdns >/dev/null &

	sleep 5

	test_internet
	if [ $? != 0 ];then
		$KILL_APP
		return 1
	fi

	go_to_internet
	get_use_size
	one_size=$use_size
	while [ `expr $use_size + $one_size` -le $size ]
	do
		if [ $? != 0 ];then
			return 1
		fi
		go_to_internet
		
		/my_tools/set_config /etc/asterisk/gw_internet.conf set option_value $SECTION flow_use_size $use_size
		
		get_use_size
	done

	$KILL_APP

	return 0
}


everyone_port_internet()
{
	get_module_channel
	test_count=3
	for ((OPVX_PORT=1; OPVX_PORT<=$total_channel;OPVX_PORT++))
	do
		get_config port$OPVX_PORT
		if [ $? -eq 1 ];then
			continue
		fi
		set_internet_devname
		ppp_and_internet
		for((i=0;i<$test_count && $?!=0;i++))
		do
			ppp_and_internet
		done
	done
}

everyone_port_internet
