#!/bin/bash

clear

#Initialise scripts to view in real time the arp table (only for kde desktops eviroments)
#konsole --geometry 500x400+0+0 -e bash ~/arp_table.sh &

#To fix the two errors about driver=80211ln (nl80211: Could not configure driver mode and 
#nl80211: deinit infname=wlan0 disabled_lib_rates=0....)
echo "killing extras"
airmon-ng check
killall wpa_supplicant
airmon-ng check kill
killall dnsmasq
killall NetworkManager
pkill dhclient

#Start the AP
echo "------------------------------- START AP ----------------------------------"

#create two separate wifi interfaces on top of the wifi phy
echo "deleting wlan0"
iw dev wlan0 del
echo "creating wisp0"
iw phy phy0 interface add wisp0 type station
#echo "starting Network Manager"
#service network-manager start
echo "creating wlocal0"
iw phy phy0 interface add wlocal0 type __ap

# connect wisp0 to the available wifi
NetworkManager
echo "Networkmanger starting..."
sleep 10

#ifconfig wisp0 up
#ip link set dev wisp0 down
#ip addr flush dev wisp0
#ip link set dev wisp0 up
#wpa_supplicant -B -i wisp0 -Dnl80211 -c/home/kali/Linux-access-point/scripts/wpa_supplicant-Yelloh.conf
#dhclient -v wisp0

# spoof the mac address (alternatively set up MAC in Network Manager)
#ifconfig wisp0 down 
#macchanger -m 1e:de:0a:11:39:88 wisp0
#ifconfig wisp0 up
#macchanger -s wisp0
 
#Set the APIP IP (like default gateway)
ifconfig wlocal0 10.10.0.1/24
#Starts the DNS and DHCP server
#service dnsmasq restart
dnsmasq -C /home/kali/Linux-access-point/scripts/dnsmasq.conf
#Permits to our device routing the networks
sysctl net.ipv4.ip_forward=1
#Interface for NATting (translate) the IP's between our wireless interface and the eth0 interface.
#This allows to all devices connected to our wireless network to get access to internet thanks to
#the eth0 interface.
iptables -t nat -A POSTROUTING -o wisp0 -j MASQUERADE
#Permits communication for port 53 (default port for DNS)
iptables -t filter -I INPUT  -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
#Permits all entry communications
iptables -P INPUT ACCEPT
#Sets the AP as the DNS for the wireless network we have created
echo "nameserver 10.10.0.1" >> /etc/resolv.conf
#Initialises the AP.
#hostapd /etc/hostapd.conf
hostapd -B -d /home/kali/Linux-access-point/scripts/hostapd.conf
sleep 5
killall hostapd
hostapd /home/kali/Linux-access-point/scripts/hostapd.conf

#Stop the AP: when pressed Ctrl + C
echo "------------------------------- STOP AP ----------------------------------"
#Deletes the firewall rules of the AP.
iptables -D POSTROUTING -t nat -o wisp0 -j MASQUERADE
iptables -D INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
#Disable the routing between interfaces.
sysctl net.ipv4.ip_forward=0
#Stops the DHCP, DNS services and the AP.
#service dnsmasq stop
killall dnsmasq
#service hostapd stop
killall hostapd
