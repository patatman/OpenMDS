#!/bin/bash
#
# OpenMDS 0.2
#

# install prerequisites
sed -i 's/ubuntu/OpenMDS/g' /etc/hosts
sed -i 's/ubuntu/OpenMDS/g' /etc/hostname
cat > /etc/hostname <<EOF
OpenMDS
EOF

debconf-apt-progress -- apt-get install openssh-server software-properties-common -y
debconf-apt-progress -- add-apt-repository ppa:jcfp/ppa -y
debconf-apt-progress -- add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
debconf-apt-progress -- apt-get update -y
debconf-apt-progress -- apt-get upgrade -y

# install base OpenMDS system
debconf-apt-progress -- apt-get install apache2 apache2-bin apache2-utils libapache2-mod-php5 mysql-client php5-fpm php5-dev php5-mysql php5-dev php5 php-pear php-db php5-gd php5-curl php5-common php5-cli php5-cgi php5-mcrypt mcrypt php5-imagick imagemagick libruby libapache2-mod-python php5-curl php5-intl php5-memcache php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached libssh2-php libauthen-pam-perl libio-pty-perl libnet-ssleay-perl libapt-pkg-perl apt-show-versions libwww-perl git libssl-dev libxslt1-dev libxslt1.1 libxml2-dev libxml2 libssl-dev libffi-dev python-pip python-dev zlib1g-dev libxslt1-dev libxml2-dev python python-pip python-dev build-essential python-cherrypy python-gdbm python-cheetah python-openssl par2 unzip python-imaging python-setuptools vnstat smartmontools python-unidecode sqlite unrar default-jre curl stunnel4 html2text nfs-kernel-server nfs-common zlib1g-dev gcc make autoconf autogen automake pkg-config libexpat1 ssl-cert libapache2-mod-fcgid apache2-suexec-pristine php-pear php-auth ntopng -y
a2enmod suexec rewrite ssl actions include
a2enmod dav_fs dav auth_digest
rm /etc/php5/cli/conf.d/ming.ini
cat > /etc/php5/cli/conf.d/ming.ini <<"EOF"
extension=ming.so
EOF
cp /etc/apache2/mods-available/suphp.conf /etc/apache2/mods-available/suphp.conf.backup
rm /etc/apache2/mods-available/suphp.conf
cat > /etc/apache2/mods-available/suphp.conf <<"EOF"
<IfModule mod_suphp.c>
        AddType application/x-httpd-suphp .php .php3 .php4 .php5 .phtml
        suPHP_AddHandler application/x-httpd-suphp
    <Directory />
        suPHP_Engine on
    </Directory>
    <Directory /usr/share>
        suPHP_Engine off
    </Directory>
</IfModule>
EOF

sed -i 's|application/x-ruby|#application/x-ruby|' /etc/mime.types

debconf-apt-progress -- apt-get install php5-xcache -y

wget http://www.webmin.com/download/deb/webmin-current.deb
dpkg -i webmin*
rm webmin*
pip install cryptography --upgrade
pip install psutil
git clone https://github.com/firehol/netdata.git netdata.git
cd netdata.git
printf 'ENTER' | sudo ./netdata-installer.sh --install /opt
cd ..
rm netdata.git -r
sed -i 's/#-i=eth0/-i=eth0/g' /etc/ntopng.conf


# install OpenMDS components
debconf-apt-progress -- apt-get install qbittorrent-nox -y
cd /etc/init.d/
wget https://db.tt/57jbt580 -O qbittorrent-nox-daemon
chmod +x /etc/init.d/qbittorrent-nox-daemon
update-rc.d qbittorrent-nox-daemon defaults

git clone https://github.com/SickRage/SickRage.git /opt/sickrage
chown -R mds:mds /opt/sickrage
cat > /etc/default/sickrage <<EOF
SR_USER=mds
SR_HOME=/opt/sickrage
SR_DATA=/opt/sickrage
SR_PIDFILE=/home/mds/.sickrage.pid
EOF
FINDSICKRAGE=$(find /opt/sickrage -name init.ubuntu)
cp $FINDSICKRAGE /etc/init.d/sickrage
chmod +x /etc/init.d/sickrage
update-rc.d sickrage defaults
service sickrage start

git clone http://github.com/RuudBurger/CouchPotatoServer /opt/CouchPotato
chown -R mds:mds /opt/CouchPotato
cat > /etc/default/couchpotato <<EOF
CP_HOME=/opt/CouchPotato
CP_USER=mds
CP_PIDFILE=/home/mds/.couchpotato.pid
CP_DATA=/opt/CouchPotato
EOF
cp /opt/CouchPotato/init/ubuntu /etc/init.d/couchpotato
chmod +x /etc/init.d/couchpotato
update-rc.d couchpotato defaults
service couchpotato start

git clone https://github.com/evilhero/mylar -b development /opt/Mylar
chown -R mds:mds /opt/Mylar
cat > /etc/default/mylar<<EOF
MYLAR_USER=mds
MYLAR_HOME=/opt/Mylar
MYLAR_DATA=/opt/Mylar
MYLAR_PORT=8090
EOF
cp /opt/Mylar/init-scripts/ubuntu.init.d /etc/init.d/mylar
chmod +x /etc/init.d/mylar
update-rc.d mylar defaults
service mylar start

git clone -b develop https://github.com/rembo10/headphones.git /opt/headphones
chown -R mds:mds /opt/headphones
cat > /etc/default/headphones<<EOF
HP_USER=mds
HP_HOME=/opt/headphones
HP_PORT=8181
EOF
cp /opt/headphones/init-scripts/init.ubuntu /etc/init.d/headphones
chmod +x /etc/init.d/headphones
update-rc.d headphones defaults
service headphones start
sleep 15
service headphones stop
sed -i "/http_host = /c\http_host = 0.0.0.0" /opt/headphones/config.ini
service headphones start

if !(cat /etc/apt/sources.list | grep -q Sabnzbd > /dev/null);then
cat >> /etc/apt/sources.list.d/sabnzbdplus.list <<EOF
deb http://ppa.launchpad.net/jcfp/ppa/ubuntu precise main
EOF
apt-key adv --keyserver hkp://pool.sks-keyservers.net:11371 --recv-keys 0x98703123E0F52B2BE16D586EF13930B14BB9F05F
fi
debconf-apt-progress -- apt-get update
debconf-apt-progress -- apt-get install sabnzbdplus -y
cat > /etc/default/sabnzbdplus <<EOF
USER=mds
HOST=0.0.0.0
PORT=8080
EOF
service sabnzbdplus restart

git clone https://github.com/Hellowlol/HTPC-Manager /opt/HTPCManager
chown -R mds:mds /opt/HTPCManager
cp /opt/HTPCManager/initscripts/initd /etc/init.d/htpcmanager
sed -i "/APP_PATH=/c\APP_PATH=/opt/HTPCManager" /etc/init.d/htpcmanager
chmod +x /etc/init.d/htpcmanager
update-rc.d htpcmanager defaults
service htpcmanager start

git clone https://github.com/drzoidberg33/plexpy.git /opt/plexpy
chown -R mds:mds /opt/plexpy
cat > /etc/default/plexpy<<EOF
HP_USER=mds
HP_HOME=/opt/plexpy
HP_PORT=8989
EOF
cp /opt/plexpy/init-scripts/init.ubuntu /etc/init.d/plexpy
chmod +x /etc/init.d/plexpy
update-rc.d plexpy defaults
service plexpy start
sleep 15
service plexpy stop
sed -i "/http_host = /c\http_host = 0.0.0.0" /opt/plexpy/config.ini
service plexpy start

mkdir -p /opt/ubooquity
cd /opt/ubooquity
wget "http://vaemendis.net/ubooquity/service/download.php" -O ubooquity.zip
unzip ubooquity*.zip
rm ubooquity.zip
chown -R mds:mds /opt/ubooquity
cd /etc/init.d/
wget https://raw.github.com/blindpet/MediaServerInstaller/usenet/scripts/ubooquity
sed -i "/DAEMON_USER=/c\DAEMON_USER=mds" /etc/init.d/ubooquity
chmod +x /etc/init.d/ubooquity
update-rc.d ubooquity defaults

cd /tmp
wget https://downloads.plex.tv/plex-media-server/0.9.15.2.1663-7efd046/plexmediaserver_0.9.15.2.1663-7efd046_amd64.deb
dpkg -i plexmediaserver_0.9.15.2.1663-7efd046_amd64.deb

cd /tmp
wget http://debian.yeasoft.net/add-btsync-repository.sh
( echo yes && \
  echo yes ) \
 | sh add-btsync-repository.sh
apt-get update
apt-get install btsync -y

apt-get install mysql-server -y
mysqladmin -u root password mds

debconf-apt-progress -- apt-get update -y
debconf-apt-progress -- apt-get upgrade -y


# service couchpotato stop



reboot

# start OpenMDS
# qbittorrent-nox
# Username: admin
# Password: adminadmin
