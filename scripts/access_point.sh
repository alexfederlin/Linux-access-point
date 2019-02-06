#!/bin/bash

clear

#Initialise scripts to view in real time the arp table (only for kde desktops eviroments)
#konsole --geometry 500x400+0+0 -e bash ~/arp_table.sh &

#To fix the two errors about driver=80211ln (nl80211: Could not configure driver mode and 
#nl80211: deinit infname=wlan0 disabled_lib_rates=0....)
airmon-ng check
killall wpa_supplicant
airmon-ng check kill



#Start the AP
echo "------------------------------- START AP ----------------------------------"
#Set the APIP IP (like default gateway)
ifconfig wlan0 10.10.0.1/24
#Starts the DNS and DHCP server
service dnsmasq restart
#Permits to our device routing the networks
sysctl net.ipv4.ip_forward=1
#Interface for NATting (translate) the IP's between our wireless interface and the eth0 interface.
#This allows to all devices connected to our wireless network to get access to internet thanks to
#the eth0 interface.
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#Permits communication for port 53 (default port for DNS)
iptables -t filter -I INPUT  -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
#Permits all entry communications
iptables -P INPUT ACCEPT
#Sets the AP as the DNS for the wireless network we have created
echo "nameserver 10.10.0.1" >> /etc/resolv.conf
#Initialises the AP.
hostapd /etc/hostapd.conf



#Stop the AP: when pressed Ctrl + C
echo "------------------------------- STOP AP ----------------------------------"
#Deletes the firewall rules of the AP.
iptables -D POSTROUTING -t nat -o wlan0 -j MASQUERADE
iptables -D INPUT ACCEPT
#Disable the routing between interfaces.
sysctl net.ipv4.ip_forward=0
#Stops the DHCP, DNS services and the AP.
service dnsmasq stop
service hostapd stop
