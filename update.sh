#!/bin/sh
DIR=/var/www/geosvc
if [ -f $DIR/.updating ]; then
    echo Update already in progress!
fi
touch $DIR/.updating

if [ ! -f $DIR/kladrapi/apps/core/config/config.ini ]; then
    Installing default config
    sed -re "s/#BASE#//" core_config.ini > $DIR/kladrapi/apps/core/config/config.ini
    chmod a+rw  $DIR/kladrapi/cache
fi

if [ ! -f $DIR/kladrapi/apps/frontend/config/config.ini ]; then
    cat frontend_config.ini > $DIR/kladrapi/apps/frontend/config/config.ini
fi

if [ ! -d $DIR/kladrapi/files_local ]; then
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

# Copy db
STAMP=`date +%Y%m%d%H%M`
rm -Rf $DIR/dump
mongodumb -db kladr --out $DIR/dump
mongorestore -db kladr$STAMP $DIR/dump/kladr
sed -re "s/#BASE#/$STAMP/" core_config.ini > $DIR/kladrapi/apps/core/config/config.ini
echo -e "use caches\ndb.dropDatabase()" | mongo --quiet
rm -Rf $DIR/dump

# Drop other databases
DBS=`echo "show dbs" | mongo --quiet | grep kladr2`
for N in $DBS; do
    if [ "$N" != "kladr$STAMP" ]; then
	echo "Dropping $N
	echo -e "use $N\ndb.dropDatabase()" | mongo --quiet
    fi
done

rm $DIR/.updating

