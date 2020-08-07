#!/bin/bash
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
PFRING_RPM_VERSION=$1
SURICATA_VERSION=$2
NDPI_VERSION=$3
MONITOR_INTERFACE=$4

cd ../dockerfiles/suricata/

echo "Build Suricata Docker Image"

docker build \
-t=suricata:${SURICATA_VERSION} \
--build-arg PFRING_VERSION=${PFRING_RPM_VERSION} \
--build-arg SURICATA_VERSION=${SURICATA_VERSION} \
--build-arg NDPI_VERSION=${NDPI_VERSION} \
--build-arg MONITOR_INTERFACE=${MONITOR_INTERFACE} \
.
docker tag suricata:${SURICATA_VERSION} suricata
