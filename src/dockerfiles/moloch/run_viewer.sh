#!/bin/sh
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
TDIR=/data/moloch
cd ${TDIR}/viewer
/bin/rm -f ${TDIR}/logs/viewer.log.old
/bin/mv ${TDIR}/logs/viewer.log ${TDIR}/logs/viewer.log.old
export NODE_ENV=production 
exec ${TDIR}/bin/node viewer.js -c ${TDIR}/etc/config.ini > ${TDIR}/logs/viewer.log 2>&1
