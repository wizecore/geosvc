geosvc
======

Geo services based on garakh/kladrapi. Complete environment for private hosting.

Hardware/OS requirements
===============

Current DB size is 15 GiB (KladrSize).
You must create VM with atleast KladrSize * 3 + 10GiB = 55 GiB
To clarify:
2 vCPU
2 GB RAM
55 GiB HDD
OS: Ubuntu 14.04 x64 (tested) or similar.

Installation
============

Prepequisites
---

- Apache2, php5, php5-mongo
- Configure php5 settings in (/etc/php5/apache/php.ini): short_open_tag = On, mbstring.internal_encoding = UTF-8
- Mongodb (10gen)
- Memcached
- Sphinxsearch - Download dpkg and install
- dbf2py - http://dbfpy.sourceforge.net
- Phalcon

Recommended
---
- memcache-stats -> git clone https://github.com/huksley/memcached-stats into  into /var/www/geosvc
- linux-dash -> git clone https://github.com/afaqurk/linux-dash into /var/www/geosvc
- rockmongo -> http://rockmongo.com/downloads into /var/www/geosvc

Source
---

1. Checkout this project

  git clone in /var/www http://github.com/wizecore/geosvc

2. Checkout kladrapi inside this project

  git clone in /var/www/geosvc http://github.com/wizecore/kladrapi (or origin http://github.com/garakh/kladrapi)

3. Enable kladrapi site

  sudo ln -s /var/www/geosvc/apache.conf /etc/apache2/sites-available/geosvc.conf

4. Enable cphalcon

  sudo ln -s /var/www/geosvc/phalcon.ini /etc/php5/apache2/conf.d/30-phalcon.in

5. Run ONCE to create examples user

  ./initmongo.sh

6. Run first time manually

  ./update.sh

7. Add to cron for daily update

  echo "00 01 * * * /var/www/geosvc/update.sh" | crontab -
