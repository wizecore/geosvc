#!/bin/sh
DIR=/var/www/geosvc

if [ ! -f $DIR/kladrapi/apps/core/config/config.ini ]; then
    Installing default config
    chmod a+rw  $DIR/kladrapi/cache
fi

if [ ! -f $DIR/kladrapi/files_local ]; then
    ln -s $DIR/loader $DIR/kladrapi/files_local
fi

# Makes kladr csv files
cd $DIR/loader
./download
./convertall

# Loades in kladr db
cd ../kladrapi/loader/
php index.php
php address_collect.php
php XmlGenerator.php

# Rename DB and update config
sed -re "s/#BASE#//" core_config.ini  $DIR/kladrapi/apps/core/config/config.ini
STAMP=`date +%Y%m%d%H%M`

# Clean cache
echo 
