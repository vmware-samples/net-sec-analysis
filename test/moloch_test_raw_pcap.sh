#!/bin/bash
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
src_pcap='/home/netsec/net-sec-analysis/test/test.pcap'
container='moloch_cap'
command='/data/moloch/bin/moloch-capture -r /tmp/test.pcap'
test_ip='192.168.68.110'

sudo docker ps | grep moloch_cap > /dev/null
if [ $? == 0 ]; then
  echo "Copy and parse raw pcap file: ${src_pcap}"
  docker cp ${src_pcap} ${container}:/tmp
  docker exec ${container} chown root /tmp/test.pcap
  docker exec ${container} chgrp root /tmp/test.pcap
  docker exec ${container} ${command}
else
  echo "Ensure ${container} container is running!"
fi

echo "Validate raw pcap"
/usr/bin/python3 /home/netsec/net-sec-analysis/test/moloch_test.py
