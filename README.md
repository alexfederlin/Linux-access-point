# Linux-access-point
Configuration to create an AP in Linux (also works in Raspberry Pi!!). 

This configuration allow us to create a new network IEEE 802.11 using the wireless interface of any Linux PC.

### Configuration
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

As an added, we can use the [arp_table.sh](https://github.com/davidahid/Linux-access-point/blob/master/scripts/arp_table.sh) script to view the ARP table to know who connected and which is their IP. Finally we just need to execute [access_point.sh](https://github.com/davidahid/Linux-access-point/blob/master/scripts/access_point.sh) and [arp_table.sh](https://github.com/davidahid/Linux-access-point/blob/master/scripts/arp_table.sh) scripts in different terminals.
```sh
sudo bash ~/access_point.sh
```
```sh
sudo bash ~/arp_table.sh
```

### Example
