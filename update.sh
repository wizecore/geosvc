#!/bin/bash

if [ -f /home/$USER/.profile ]; then
    source /home/$USER/.profile
fi

DIR=/var/www/geosvc
if [ -f $DIR/.updating ]; then
    echo Update already in progress!
    exit 1
fi
touch $DIR/.updating

# Copy default core config
if [ ! -f $DIR/kladrapi/apps/core/config/config.ini ]; then
    Installing default config
    sed -re "s/#BASE#//" core_config.ini > $DIR/kladrapi/apps/core/config/config.ini
    chmod a+rw  $DIR/kladrapi/cache
fi

# Copy default frontend config
if [ ! -f $DIR/kladrapi/apps/frontend/config/config.ini ]; then
    cat frontend_config.ini > $DIR/kladrapi/apps/frontend/config/config.ini
fi

# Link dir with files
if [ ! -d $DIR/kladrapi/files_local ]; then
    ln -s $DIR/loader $DIR/kladrapi/files_local
fi

# Make kladr csv files

cd $DIR/loader
./download
./convertall

# Load CSV in kladr db
cd ../kladrapi/loader/
php index.php
php address_collect.php
php XmlGenerator.php

# Copy db to timestamped DB
rm -Rf $DIR/dump
mongodump -db kladr --out $DIR/dump
if [ "$?" != "0" ]; then
    echo "ERROR: mongodb dump kladr failed"
    exit 1
fi

# Drop kladr to conserve space
echo -e "use kladr\ndb.dropDatabase()" | mongo --quiet

STAMP=`date +%Y%m%d%H%M`
mongorestore -db kladr$STAMP $DIR/dump/kladr
if [ "$?" != "0" ]; then
    echo "ERROR: mongodb restore kladr -> kladr$STAMP failed"
    exit 2
fi

# Point core to timestamped DB
sed -re "s/#BASE#/$STAMP/" $DIR/core_config.ini > $DIR/kladrapi/apps/core/config/config.ini
echo -e "use caches\ndb.dropDatabase()" | mongo --quiet
rm -Rf $DIR/dump

# Drop other databases
DBS=`echo "show dbs" | mongo --quiet | sed -re "s/\t/ /g" | cut -d" " -f1 | grep kladr`
for N in $DBS; do
    if [ "$N" != "kladr$STAMP" -a "$N" != "kladr-api" ]; then
	echo "Dropping $N"
	echo -e "use $N\ndb.dropDatabase()" | mongo --quiet
    fi
done

rm $DIR/.updating
