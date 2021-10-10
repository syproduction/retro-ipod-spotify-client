#!/bin/bash

#screen

read -r -p "Add Adding 2inch display parameters to /boot/config.txt ? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    	echo -e "\e[1;36m Ok, writing to /boot/config.txt   \e[0m" 
	sudo bash -c 'echo "enable_uart=1" >> /boot/config.txt'
	sudo bash -c 'echo "hdmi_force_hotplug=1" >> /boot/config.txt'
	sudo bash -c 'echo "hdmi_cvt=320 240 60 1 0 0 0" >> /boot/config.txt'
	sudo bash -c 'echo "hdmi_group=2" >> /boot/config.txt'
	sudo bash -c 'echo "hdmi_mode=1" >> /boot/config.txt'
	sudo bash -c 'echo "hdmi_mode=87" >> /boot/config.txt'
	sudo bash -c 'echo "display_rotate=0" >> /boot/config.txt'
else
	echo Skipping..
    	exit 0
fi

echo -e "\e[1;36m apt update   \e[0m" 

sudo apt-get update -y
sudo apt-get upgrade -y

echo -e "\e[1;36m Now installing Waveshare_fbcp driver for 2inch display  \e[0m"  
sudo apt-get install cmake p7zip-full -y
cd ~
wget https://www.waveshare.com/w/upload/8/8d/Waveshare_fbcp-main.7z
7z x Waveshare_fbcp-main.7z
cd waveshare_fbcp-main
mkdir build
cd build
cmake -DSPI_BUS_CLOCK_DIVISOR=20 -DWAVESHARE_2INCH_LCD=ON -DBACKLIGHT_CONTROL=ON -DSTATISTICS=0 ..
make -j
#sudo ./fbcp

echo -e "\e[1;36m Now making 2inch display auto start on boot \e[0m"  
sudo cp ~/waveshare_fbcp-main/build/fbcp /usr/local/bin/fbcp
sudo sed -i -e '$ i\fbcp&' /etc/rc.local


#pigpio
echo -e "\e[1;36m Now installing pigpio \e[0m"  
sudo apt-get install -y python3-distutils
cd ~
wget https://github.com/joan2937/pigpio/archive/master.zip
unzip master.zip
cd pigpio-master
make
sudo make install

#clickwheel
echo -e "\e[1;36m Now installing clickwheel \e[0m"  
sudo apt-get install -y git
cd ~
git clone https://github.com/dupontgu/retro-ipod-spotify-client.git
cd retro-ipod-spotify-client/clickwheel
sudo sed -i 's/#define DATA_PIN 25/#define DATA_PIN 5/' ~/retro-ipod-spotify-client/clickwheel/click.c

gcc -Wall -pthread -o click click.c -lpigpio -lrt
sudo chmod +x click
sudo click &
sudo cp ~/retro-ipod-spotify-client/clickwheel/click /usr/local/bin/click
sudo sed -i -e '$ i\click&' /etc/rc.local


#btaudio
echo -e "\e[1;36m Now installing btaudio \e[0m" 
cd ~
git clone https://github.com/bablokb/pi-btaudio.git
cd pi-btaudio
sudo tools/install
success "Done"
echo


#pipod-nano -automatic
#git clone https://github.com/G-a-v-r-o-c-h-e/PIpod-Nano.git
#cd PIpod-Nano
#sudo chmod +x install.sh
#./install.sh /home/pi/Music


