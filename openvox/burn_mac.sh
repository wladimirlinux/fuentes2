#!/bin/sh

burn_tools=/my_tools/rtunicpg/rtunicpg-i686
mac_head="A098050A"
lan_mac=""
wan_mac=""
lan_dev="eth0"
wan_dev="eth1"

print_usage()
{
	echo "The Usage of burn_mac.sh: "
	echo "$0 -l lan_mac -w wan_mac"
	echo "$0 -l lan_mac"
	echo "$0 -w wan_mac"
}

get_mac()
{
	opt=$1
	mac=$2

	mac_len=`echo ${#mac}`
	if [ $mac_len != 4 ]; then
		echo "mac_len=$mac_len. The length is not 4"
		return 0
	fi
	mac_check=`echo $mac | grep -o  "[a-f0-9A-F][a-f0-9A-F][a-f0-9A-F][a-f0-9A-F]"`
	if [ x"$mac_check" == x ]; then
		echo "mac=[$mac], The mac is invalid."
		return 0
	fi
	
	if [ x"$opt" == x"-l" -o x"$opt" == x"-L" ];then
		lan_mac=$mac
	elif [ x"$opt" == x"-w" -o x"$opt" == x"-W" ];then
		wan_mac=$mac
	fi
}

burn_mac()
{
	dev_input=$1
	mac_input=$2
	
	dev_id=${dev_input:3:1}
	mac=${mac_head}${mac_input^^}
#	echo "mac = [$mac], dev = [$dev_input]"
	
	
	# burn to mac chip
	$burn_tools /\# $dev_id /efuse /nodeid $mac > /dev/null
}

main()
{
	count=$#
	if [ $count != 2 -a $count != 4 ]; then
		print_usage
		exit 1
	fi
	
	arg1=$1
	arg2=$2
	arg3=$3
	arg4=$4
	burn_flag=0
	if [ x"$arg1" == x"$arg3" ]; then
		arg3=""
	fi
	
	get_mac $arg1 $arg2

	if [ x"$arg3" != x ]; then
		get_mac $arg3 $arg4
	fi
	
	if [ x"$wan_mac" != x ]; then
		burn_mac $wan_dev $wan_mac
		echo "Burn wan mac: ${wan_mac} finish!"
		burn_flag=1
		sleep 1
	fi
	
	if [ x"$lan_mac" != x ]; then 
		burn_mac $lan_dev $lan_mac
		echo "Burn lan mac: ${lan_mac} finish!" 
		burn_flag=1
		sleep 1
	fi

	if [ $burn_flag -eq 0 ]; then
		print_usage
		exit 1
	fi

	echo "The host will shutdown!"
	/bin/poweroff
}

main $*

exit 0
