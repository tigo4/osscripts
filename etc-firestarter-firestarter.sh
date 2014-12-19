#!/bin/bash
#-----------( Firestarter Control Script )-----------#

# Load Configuration
source /etc/firestarter/configuration 2>&1

# --(Set program paths)--

IPT=/sbin/iptables
IFC=/sbin/ifconfig
MPB=/sbin/modprobe
LSM=/sbin/lsmod
RMM=/sbin/rmmod


# --(Extract Network Information)--

# External network interface data
IP=`LANG=C /sbin/ifconfig $IF | grep inet | cut -d : -f 2 | cut -d \  -f 1`
MASK=`LANG=C /sbin/ifconfig $IF | grep Mas | cut -d : -f 4`
BCAST=`LANG=C /sbin/ifconfig $IF |grep Bcast: | cut -d : -f 3 | cut -d \  -f 1`
NET=$IP/$MASK

if [ "$NAT" = "on" ]; then
	# Internal network interface data
	INIP=`LANG=C /sbin/ifconfig $INIF | grep inet | cut -d : -f 2 | cut -d \  -f 1`
	INMASK=`LANG=C /sbin/ifconfig $INIF | grep Mas | cut -d : -f 4`
	INBCAST=`LANC=C /sbin/ifconfig $INIF |grep Bcast: | cut -d : -f 3 | cut -d \  -f 1`
	INNET=$INIP/$INMASK
fi

if [ "$MASK" = "" -a "$1" != "stop" ]; then
	echo "External network device $IF is not ready. Aborting.."
	exit 2
fi

if [ "$NAT" = "on" ]; then
	if [ "$INMASK" = "" -a "$1" != "stop" ]; then
		echo "Internal network device $INIF is not ready. Aborting.."
		exit 3
	fi
fi


# --(Helper Functions)--

# Scrub data parameters before use
scrub_parameters () {
	target=`echo $target | sed 's/ //'g`
	port=`echo $port | sed 's/ //'g |  sed "s/-/:/"`
	ext_port=`echo $ext_port | sed 's/ //'g |  sed "s/-/:/"`
	int_port_dashed=`echo $int_port | sed 's/ //'g |  sed "s/:/-/"`
	int_port=`echo $int_port | sed 's/ //'g |  sed "s/-/:/"`
	if [ "$target" == "everyone" ]; then target=0/0
	else if [ "$target" == "firewall" ]; then target=$IP
	else if [ "$target" == "lan" ]; then target=$INNET
	fi fi fi
}


# --(Control Functions)--

# Create Firestarter lock file
lock_firestarter () {
	if [ -e /var/lock/subsys ]; then
		touch /var/lock/subsys/firestarter
	else
		touch /var/lock/firestarter
	fi
}

# Remove Firestarter lock file
unlock_firestarter () {
	if [ -e /var/lock/subsys ]; then

		rm -f /var/lock/subsys/firestarter
	else
		rm -f /var/lock/firestarter
	fi
}

# Start system DHCP server
start_dhcp_server () {
	if [ "$DHCP_DYNAMIC_DNS" = "on" ]; then
		NAMESERVER=
		# Load the DNS information into the dhcp configuration
		while read keyword value garbage
			do
			if [ "$keyword" = "nameserver" ]; then
				if [ "$NAMESERVER" = "" ]; then
					NAMESERVER="$value"
				else
					NAMESERVER="$NAMESERVER, $value"
				fi
			fi
			done < /etc/resolv.conf

		if [ "$NAMESERVER" != "" ]; then
			if [ -f /etc/dhcpd.conf ]; then
				sed "s/domain-name-servers.*$/domain-name-servers $NAMESERVER;/" /etc/dhcpd.conf > /etc/dhcpd.conf.tmp
				mv /etc/dhcpd.conf.tmp /etc/dhcpd.conf
			fi
			if [ -f /etc/dhcp3/dhcpd.conf ]; then
				sed "s/domain-name-servers.*$/domain-name-servers $NAMESERVER;/" /etc/dhcp3/dhcpd.conf > /etc/dhcp3/dhcpd.conf.tmp
				mv /etc/dhcp3/dhcpd.conf.tmp /etc/dhcp3/dhcpd.conf
			fi
			if [ -f /etc/dhcpd/dhcpd.conf ]; then
				sed "s/domain-name-servers.*$/domain-name-servers $NAMESERVER;/" /etc/dhcpd/dhcpd.conf > /etc/dhcpd/dhcpd.conf.tmp
				mv /etc/dhcpd/dhcpd.conf.tmp /etc/dhcpd/dhcpd.conf
			fi
		else
			echo -e "Warning: Could not determine new DNS settings for DHCP\nKeeping old configuration"
		fi
	fi

	if [ -e /etc/init.d/isc-dhcp-server ]; then
		  /etc/init.d/isc-dhcp-server restart > /dev/null
	elif [ -e /etc/init.d/dhcp3-server ]; then
		  /etc/init.d/dhcp3-server restart > /dev/null
	elif [ -e /etc/init.d/dhcpd ]; then
		  /etc/init.d/dhcpd restart > /dev/null
	elif [ -e /etc/init.d/dnsmasq ]; then
		  /etc/init.d/dnsmasq restart > /dev/null
	else
		  /usr/sbin/dhcpd 2> /dev/null
	fi

	if [ $? -ne 0 ]; then
		echo Failed to start DHCP server
		exit 200
	fi
}

# Start the firewall, enforcing traffic policy
start_firewall () {
	lock_firestarter
	source /etc/firestarter/firewall 2>&1
	retval=$?
	if [ $retval -eq 0 ]; then
		echo "Firewall started"
	else
		echo "Firewall not started"
		unlock_firestarter
	exit $retval
fi
}

# Stop the firewall, traffic flows freely
stop_firewall () {
	$IPT -F
	$IPT -X
	$IPT -Z
	##$IPT -P INPUT ACCEPT
	##$IPT -P FORWARD ACCEPT
	##$IPT -P OUTPUT ACCEPT
	$IPT -t mangle -F 2>/dev/null
	$IPT -t mangle -X 2>/dev/null
	$IPT -t mangle -Z 2>/dev/null
	$IPT -t nat -F 2>/dev/null
	$IPT -t nat -X 2>/dev/null
	$IPT -t nat -Z 2>/dev/null
	retval=$?
	if [ $retval -eq 0 ]; then
		unlock_firestarter
		echo "Firewall stopped"
	fi
	exit $retval
}

# Lock the firewall, blocking all traffic
lock_firewall () {
	$IPT -F;
	$IPT -X
	$IPT -A INPUT -i lo -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
	$IPT -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
	$IPT -P INPUT DROP
	$IPT -P FORWARD DROP
	$IPT -P OUTPUT DROP
	$IPT -Z
	retval=$?
	if [ $? -eq 0 ]; then
		echo "Firewall locked"
	fi
	exit $retval
}

# Report the status of the firewall
status () {
	if [ -e /var/lock/subsys/firestarter -o -e /var/lock/firestarter ]; then
		echo "Firestarter is running..."
	else
		echo "Firestarter is stopped"
	fi
}

case "$1" in
start)
	start_firewall
 	if [ "$NAT" = "on" -a "$DHCP_SERVER" = "on" ]; then
		start_dhcp_server
	fi
;;
stop)
	stop_firewall
;;
lock)
	lock_firewall
;;
status)
	status
;;
reload-inbound-policy)
	source /etc/firestarter/inbound/setup 2>&1
;;
reload-outbound-policy)
	source /etc/firestarter/outbound/setup 2>&1
;;
*)
	echo "usage: $0 {start|stop|lock|status}"
	exit 1
esac
exit 0
