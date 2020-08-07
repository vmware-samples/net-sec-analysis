# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
FROM centos:7

ARG PFRING_VERSION
ARG ZEEK_VERSION
ARG NDPI_VERSION
ARG MONITOR_INTERFACE

#
COPY ./zeek.repo /etc/yum.repos.d/

#Install Dependencies
RUN yum install -y -q epel-release && \
    yum install -y -q cmake3 cmake make gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig zlib-devel supervisor wget python-pip git dkms kernel-devel ethtool net-tools numactl && \
    pip install --upgrade pip && \
    pip install zkg && \
    yum update -y -q

#Download and install PF_RING and zeek 
RUN cd /usr/src && \
    echo "Download files" && \
    rpm -ivh https://forensics.cert.org/centos/cert/7/x86_64/ndpi-${NDPI_VERSION}.x86_64.rpm && \
    wget -q --no-check-certificate -O pfring-${PFRING_VERSION}.x86_64.rpm https://forensics.cert.org/centos/cert/7/x86_64/pfring-${PFRING_VERSION}.x86_64.rpm && \
    wget -q --no-check-certificate -O pfring-dkms-${PFRING_VERSION}.noarch.rpm https://forensics.cert.org/centos/cert/7/x86_64/pfring-dkms-${PFRING_VERSION}.noarch.rpm && \
    rpm -ivh ./pfring-dkms-${PFRING_VERSION}.noarch.rpm ./pfring-${PFRING_VERSION}.x86_64.rpm && \
    wget -q https://download.zeek.org/zeek-${ZEEK_VERSION}.tar.gz && tar -zxf zeek-${ZEEK_VERSION}.tar.gz && cd zeek-${ZEEK_VERSION} && \
    LDFLAGS="-lpfring -lpcap" ./configure --with-pcap=/usr/local --prefix=/opt/zeek > /dev/null 2>&1 && make -j 1 -s && make install -s && \
    mkdir -p /var/log/zeek

ENV PATH="$PATH:/opt/zeek/bin"
RUN zkg autoconfig && \
    zkg install ja3 --force  && \
    zkg install zeek-community-id --skiptests --force --version 1.3

COPY ./local.zeek /opt/zeek/share/zeek/site/
COPY ./node.cfg /opt/zeek/etc/
RUN sed -i s:MONITOR_INTERFACE:${MONITOR_INTERFACE}:g /opt/zeek/etc/node.cfg

#Clean Up
RUN echo "Clean-Up" && \
    yum clean all && \
    cd /usr/src && rm -f pfring-${PFRING_VERSION}.x86_64.rpm pfring-dkms-${PFRING_VERSION}.noarch.rpm

#Add Supervisord file
COPY ./supervisord.conf /etc/supervisord.d/ 

#Kickoff Supervisor
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.d/supervisord.conf"]
