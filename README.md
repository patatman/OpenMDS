# OpenMDS
Open Media Download Station

This is still very much a work in progress, including this readme, but it's intended use will be an all-in-one out-of-the-box Media Download Server for downloading and (Plex focused) serving media, with all bells and whistles.

Think
- Couchpotato
- Sickrage
- Headphones
- Mylar
- Plex Media Server
- HTPC Manager
- PlexPy
- PlexRequest
- Bittorrent Sync
- Spotweb
- Ubooquity
- Mopidy/Mopify
- NtopNG
- Wordpress
- Netdata
- (L)AMP
- Webmin
- Etc.

This is all executed on Ubuntu 15.10, and has not been tested on other Distro's

<h3>Minimal system requirements:</h3>

- 2gb DDR3 Ram
- 20 GB Diskspace
- Intel Core 2 Duo (2,4 GHz or more)
- Common sense

<h3> Recommended system requirement:</h3>

- 4gb Ram DDR3
- 30 GB Diskspace
- Intel Core i3 (3,2 GHz or more)
- Basic knowledge


<h3> Installation </h3>

On a clean Ubuntu 15.10 installation get the script:
```Bash
$ wget https://raw.githubusercontent.com/patatman/OpenMDS/master/OpenMDS.sh
```

Then make the script executable
```Bash
$ chmod +x OpenMDS.sh
```

Execute the script and wait, this can take up to 30 min.
```bash
$ ./OpenMDS.sh
```

If done, the system will reboot and you will have a fully working MDS.

