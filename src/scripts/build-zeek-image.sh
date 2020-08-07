#!/bin/bash
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
PFRING_RPM_VERSION=$1
ZEEK_VERSION=$2
NDPI_VERSION=$3
MONITOR_INTERFACE=$4


cd ../dockerfiles/zeek/

echo "Build Zeek Docker Image"

docker build \
-t=zeek:${ZEEK_VERSION} \
--build-arg PFRING_VERSION=${PFRING_RPM_VERSION} \
--build-arg ZEEK_VERSION=${ZEEK_VERSION} \
--build-arg NDPI_VERSION=${NDPI_VERSION} \
--build-arg MONITOR_INTERFACE=${MONITOR_INTERFACE} \
.

docker tag zeek:${ZEEK_VERSION} zeek
