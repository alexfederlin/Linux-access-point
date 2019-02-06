#!/bin/bash

clear

#Initialise scripts to view in real time the arp table
konsole --geometry 500x400+0+0 -e bash /root/Scripts/arp_table.sh &

#To fix the errors about driver=80211ln
airmon-ng check
killall wpa_supplicant
airmon-ng check kill

#Start
echo "------------------------------- START AP ----------------------------------"
ifconfig wlan0 10.10.0.1/24
service dnsmasq restart
sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
iptables -t filter -I INPUT  -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
iptables -P INPUT ACCEPT
echo "nameserver 10.10.0.1" >> /etc/resolv.conf
hostapd /etc/hostapd.conf

#Stop: when pressed Ctrl + C
echo "------------------------------- STOP AP ----------------------------------"
iptables -D POSTROUTING -t nat -o wlan0 -j MASQUERADE
iptables -D INPUT ACCEPT
sysctl net.ipv4.ip_forward=0
service dnsmasq stop
service hostapd stop
