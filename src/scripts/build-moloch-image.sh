#!/bin/bash
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
PFRING_RPM_VERSION=$1
MOLOCH_VERSION=$2
NDPI_VERSION=$3
MONITOR_INTERFACE=$4

cd ../dockerfiles/moloch/

echo "Build Moloch Docker Image"

docker build \
-t=moloch:${MOLOCH_VERSION} \
--build-arg PFRING_VERSION=${PFRING_RPM_VERSION} \
--build-arg MOLOCH_VERSION=${MOLOCH_VERSION} \
--build-arg NDPI_VERSION=${NDPI_VERSION} \
--build-arg MONITOR_INTERFACE=${MONITOR_INTERFACE} \
.
docker tag moloch:${MOLOCH_VERSION} moloch
