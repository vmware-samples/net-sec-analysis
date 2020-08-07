# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
cd /opt/zeek/spool/manager
/opt/zeek/bin/zeek -Cr /tmp/test.pcap -e 'redef LogAscii::use_json=T;'
