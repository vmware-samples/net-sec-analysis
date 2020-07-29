#!/bin/bash
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
PFRING_RPM_VERSION='7.6.0-3000'
PFRING_VERSION='7.6.0'
NDPI_VERSION='3.2.0-2477'
MOLOCH_VERSION='2.3.1-1'
SURICATA_VERSION='4.1.8'
ZEEK_VERSION='3.0.6'
MONITOR_INTERFACE='eth0'
SCRIPTS_DIR='/home/netsec/net-sec-analysis/src/scripts'
INSTANCE_NAME=$1
ES_HOST='localhost'
ES_PORT='9200'
MOLOCH_ADMIN='admin'
MOLOCH_PASS='QkCuZA34LT'

echo "Preparing the host for installation"

if [ -f ${SCRIPTS_DIR}/tdnf-build-deps.spec ]
then
  echo "Install dependencies from file:"
  sudo tdnf install -yq `cat ${SCRIPTS_DIR}/tdnf-build-deps.spec`
  sudo pip3 install --upgrade pip3 -q
  sudo pip3 install docker-compose -q
else
  echo "File ${SCRIPTS_DIR}/tdnf-build-deps.spec is missing!"
  exit 127
fi


echo "Update build dir to make sure to point to kernel-headers! needed for pf_ring install"
  cd /lib/modules/`uname -r`/
  sudo unlink build
  sudo ln -s /usr/src/linux-headers-`uname -r` build

echo "Validate linux kernel and devel package"
  KERNEL=`uname -r | sed 's/-esx//'`
  rpm -qa linux-esx-devel | grep $KERNEL
  if [ $? != 0 ]
  then
    echo "Please ensure the booted kernel version and linux-esx-devel package version match!"
    echo "A reboot might be required!"
    exit 127
  fi

echo "Verify PF_RING"
  install_pf_ring='true'
  cat /proc/net/pf_ring/info > /dev/null
  if [ $? == 0 ]
  then
    echo "PF_Ring installed! Check Version"
    pfring_existing_version=`cat /proc/net/pf_ring/info  | grep 'PF_RING Version' | cut -d : -f2 | awk '{print $1}'`
    if [ ${pfring_existing_version} == ${PFRING_VERSION} ]
    then
      echo "pf_ring: ${PFRING_VERSION} already installed"
      install_pf_ring='false'
    fi
  fi

if [ ${install_pf_ring} == 'true' ]
then
  cd /home/netsec/
  wget -q -O pf_ring_$PFRING_VERSION.tar.gz https://github.com/ntop/PF_RING/archive/$PFRING_VERSION.tar.gz
  if [ $? == 0 ] 
    then
      tar -zxf pf_ring_$PFRING_VERSION.tar.gz
      sudo chown netsec:wheel PF_RING-$PFRING_VERSION -R
      cd PF_RING-$PFRING_VERSION/kernel
      make 
      sudo make install
      sudo modprobe pf_ring
      cat /proc/net/pf_ring/info > /dev/null
      if [ $? == 0 ]
      then
        echo "PF_Ring installed successfully!"
      else
        echo "PF_Ring Installation Failed!"
        exit 127
      fi
    else
      echo "PF_Ring Download failed"
      exit 127
    fi
  fi

echo "Create Logs directory structure"
  if [ -e /docker ]
  then
    echo "/docker exists!"
  else 
    sudo mkdir /docker/suricata/var/logs -p
    sudo mkdir /docker/suricata/{etc,rules} -p
    sudo mkdir /docker/bro/var/{logs,spool} -p
    sudo ln -s /docker/bro /docker/zeek
    sudo mkdir /docker/moloch_es/ -p
    sudo mkdir /docker/moloch_cap/var/logs -p
    sudo mkdir /docker/moloch_cap/raw -p -m 777
    sudo mkdir /docker/moloch_cap/etc -p
  fi

sudo systemctl enable docker && sudo systemctl start docker


echo "Building Docker images"

  cd ${SCRIPTS_DIR}
  sudo bash -x build-moloch-image.sh $PFRING_RPM_VERSION $MOLOCH_VERSION $NDPI_VERSION $MONITOR_INTERFACE
  cd ${SCRIPTS_DIR} && sleep 1
  sudo bash -x build-suricata-image.sh $PFRING_RPM_VERSION $SURICATA_VERSION $NDPI_VERSION $MONITOR_INTERFACE
  cd ${SCRIPTS_DIR} && sleep 1
  sudo bash -x build-zeek-image.sh $PFRING_RPM_VERSION $ZEEK_VERSION $NDPI_VERSION $MONITOR_INTERFACE
  sleep 5
  echo "Start containers using docker-compose.yml"
  sudo sysctl -w vm.max_map_count=262144
  sudo docker-compose -f /home/netsec/net-sec-analysis/src/dockerfiles/docker-compose.yml up -d

echo "Initialize Elasticsearch DB for Moloch"
sudo /bin/bash ${SCRIPTS_DIR}/moloch-db-init.sh ${ES_HOST} ${ES_PORT} ${MOLOCH_ADMIN} ${MOLOCH_PASS}

echo "Update iptables for Moloch"
sudo iptables -A INPUT -p tcp -m tcp --dport 8005 -j ACCEPT && sudo iptables-save
