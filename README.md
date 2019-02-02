# Linux-access-point
Configuration to create an AP in Linux (also works in Raspberry Pi!!). 

This configuration allow us to create a new network IEEE 802.11 using the wireless interface of any Linux PC.

## Configuration
First, we need to install hostapd and dnsmasq.
```sh
sudo apt-get update
sudo apt-get -y install hostapd dnsmasq
```

   · hostapd let us to create the access point
   · dnsmasq is used to create a dhcp and dns server

Now let's stop the services of the new packets.
```sh
sudo service hostapd stop
sudo service dnsmasq stop
sudo update-rc.d hostapd disable
sudo update-rc.d dnsmasq disable
```

Its time to configure our AP with hostapd. This configuration its founded in `/etc/hostapd.conf`.
