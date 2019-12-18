#!/bin/sh

# Date: 2016-02-12 
# Auth: tianchi
echo "installing binary and scripts curldownload curlhandbrake curlmp4tom4a"
cd `dirname $0`
cd /usr/bin && rm rename_and_compress rename_pl curldownload curlhandbrake curlmp4tom4a 2>&1 > /dev/null
cd - 2>&1 > /dev/null
cp rename_and_compress /usr/bin/rename_and_compress
chmod 755 /usr/bin/rename_and_compress
cp rename_pl /usr/bin/rename_pl
chmod 755 /usr/bin/rename_pl

whereis pip | grep /usr
if [ $? -ne 0 ]; then
	curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
	python get-pip.py
	rm get-pip.py
fi

pip install pafy

whereis youtube-dl |grep /usr
if [ $? -ne 0 ]; then
	curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
	chmod a+rx /usr/local/bin/youtube-dl
fi
# pip install --upgrade youtube_dl

cp curldownload /usr/bin/curldownload
cp curlhandbrake /usr/bin/curlhandbrake
cp curlmp4tom4a /usr/bin/curlmp4tom4a
cp dl /usr/bin/youtubedownload
cp dl /usr/bin/dl
cp youtubem4a /usr/bin/youtubem4a

echo "installing handbrake"
if [ ! -e /etc/yum.repos.d/linuxtech.repo ] ; then 
	cd /etc/yum.repos.d/ && sudo wget http://pkgrepo.linuxtech.net/el6/release/linuxtech.repo
	sudo yum install handbrake-cli -y 2>&1 > /dev/null # handbrake-gui
	cd -
fi

echo "installing ffmpeg"
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro 2>&1 > /dev/null
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm 2>&1 > /dev/null
yum install ffmpeg ffmpeg-devel -y 2>&1 > /dev/null
yum install transmission transmission-daemon -y 2>&1 > /dev/null

echo "config & start transmission daemon service to create settings.xml"

#service transmission-daemon start 
#service transmission-daemon stop

echo "shutdown service then modify settings and save, restart" 

echo "editing crontab manually
*/2 * * * * ( /Data/transmission/transmission-purge-complete.sh user:password /Data/transmission/downloaded >> /Data/transmission/transmission_complete.log 2>&1 )
0 0 * * * ( /Data/transmission/transmission-purge-no-seed.sh user:password >> /Data/transmission/transmission_no_seed.log 2>&1 )
0 0 1 * * ( cat /dev/null > /Data/transmission/transmission_complete.log )
0 0 1 * * ( cat /dev/null > /Data/transmission/transmission_no_seed.log ) 
done!"
