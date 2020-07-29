# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
#!/bin/bash
src_pcap='/home/netsec/net-sec-analysis/test/test.pcap'
zeek_script='/home/netsec/net-sec-analysis/test/zeek_load_pcap.sh'
container='zeek'
host_log_file='/docker/zeek/var/manager/http.log'
test_ip='192.168.68.110'

sudo docker ps | grep zeek > /dev/null
if [ $? == 0 ]; then
  echo "Copy and parse raw pcap file: ${src_pcap}"
  docker cp ${src_pcap} zeek:/tmp
  docker cp ${zeek_script} zeek:/tmp
  docker exec ${container} bash -x /tmp/zeek_load_pcap.sh
else
  echo "Ensure zeek container is running!"
fi

echo "Validate Zeek http log: ${host_log_file}"
if [[ -f ${host_log_file} ]]; then
  grep ${test_ip} ${host_log_file} > /dev/null
  if [ $? == 0 ]; then
    echo "Test Successful"
  else
    echo "Could not find ${test_ip} in: ${host_log_file}"
    exit 127
  fi
else
  echo "${host_log_file} NotFound"
  exit 127
fi
