# Linux-access-point
Configuration to create an AP in Linux (also works in Raspberry Pi!!). 

This configuration allow us to create a new network IEEE 802.11 using the wireless interface of any Linux PC.

## Configuration
First, we need to install hostapd and dnsmasq.
```sh
sudo apt-get update
sudo apt-get -y install hostapd dnsmasq
```

   * hostapd let us to create the access point
   * dnsmasq is used to create a dhcp and dns server

Now let's stop the services of the new packets.
```sh
sudo service hostapd stop
sudo service dnsmasq stop
sudo update-rc.d hostapd disable
sudo update-rc.d dnsmasq disable
```

It's time to configure our AP with hostapd. This configuration its founded in `/etc/hostapd.conf`.
```sh
interface=wlan0
driver=nl80211
ssid=WifiGratis
#Enable WPA2 encryption password
wpa_key_mgmt=WPA-PSK
wpa=2
wpa_passphrase=S3cur3_p@ssw0rd
#Set access point harware mode to 802.11n
hw_mode=g
ieee80211n=1
channel=6
```

And now, we configure the DHCP server to assign an IP address to any device that connects to our AP. We are going to edit the file `/etc/dnsmasq.conf` and add these lines at the end of the file.
```sh
interface=wlan0
dhcp-range=10.10.0.2,10.10.0.100,12h
server=10.10.0.1
```

Now let's create the shell script that initializes all requirements for the AP.
```sh
sudo nano ~/access_point.sh
```

And we just need to copy this inside.
```sh
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
```

As an added we can create this other script to view the ARP table to know who connected and which is their IP.
```sh
sudo nano ~/arp_table.sh
```
```sh
#!/bin/bash

while [ True ];
do
  ip neighbor show > /tmp/arp_table
	echo "IP	DEV"
	cat /tmp/arp_table
	sleep 1
	clear
done
```
