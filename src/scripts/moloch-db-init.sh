#!/bin/bash
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
#this script initializes ES DB for Moloch Node and Adds an admin user in dev env!

ES_HOST=$1
ES_PORT=$2
MOLOCH_ADMIN=$3
MOLOCH_PASS=$4

ES_URL="http://"${ES_HOST}":"${ES_PORT}

#Is moloch_cap container running?
sudo docker ps | grep moloch_cap > /dev/null
if [ $? == 0 ]; then
  #Check if ES is up
  retry=0
  while :
  do
    ES_STATUS=`curl --silent -XGET ${ES_URL}/_cluster/health?pretty | jq .status | sed 's/"//g'`
    if [[ ! -z ${ES_STATUS} ]]
    then
      if [ ${ES_STATUS} == "yellow" ] || [ ${ES_STATUS} == "green" ] ; then 
        DB_INIT=`sudo docker exec moloch_cap /data/moloch/db/db.pl --insecure ${ES_URL} info | grep 'DB Version' | cut -d : -f2`
        if [ ${DB_INIT} == -1 ]; then
          echo "Initializing Database!"
          sudo docker exec moloch_cap /data/moloch/db/db.pl ${ES_URL} init && sudo docker restart moloch_cap
        else
          echo "Index Exists!"
        fi
        break
      fi
    else
      echo "Elasticsearch is not up" && sleep 30 && ((retry++))
    fi
    ((retry>=6)) && break
  done
else
  echo "moloch_cap container is not running!" && exit 1
fi


#Add Admin user for dev env 
echo "Add admin user for DEV env"
echo "Adding $MOLOCH_ADMIN and Password $MOLOCH_PASS"
sudo docker exec moloch_cap /data/moloch/bin/moloch_add_user.sh $MOLOCH_ADMIN "Admin User" $MOLOCH_PASS --admin > /dev/null
