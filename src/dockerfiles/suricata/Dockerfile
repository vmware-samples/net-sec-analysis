# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
FROM centos:7

ARG PFRING_VERSION
ARG SURICATA_VERSION
ARG NDPI_VERSION
ARG MONITOR_INTERFACE

COPY ./yum-build-deps.spec /etc/yum.repos.d/

#Install Dependencies
RUN yum install -y -q epel-release && \
    yum install -y -q `cat /etc/yum.repos.d/yum-build-deps.spec` 

#Download and install PF_RING and suricata
RUN    cd /usr/src && \
    rpm -ivh https://forensics.cert.org/centos/cert/7/x86_64/ndpi-${NDPI_VERSION}.x86_64.rpm && \
    wget -q --no-check-certificate -O pfring-${PFRING_VERSION}.x86_64.rpm https://forensics.cert.org/centos/cert/7/x86_64/pfring-${PFRING_VERSION}.x86_64.rpm && \
    wget -q --no-check-certificate -O pfring-dkms-${PFRING_VERSION}.noarch.rpm https://forensics.cert.org/centos/cert/7/x86_64/pfring-dkms-${PFRING_VERSION}.noarch.rpm && \
    rpm -ivh ./pfring-dkms-${PFRING_VERSION}.noarch.rpm ./pfring-${PFRING_VERSION}.x86_64.rpm 

RUN cd /usr/src/ &&    wget -O suricata-${SURICATA_VERSION}.tar.gz https://www.openinfosecfoundation.org/download/suricata-${SURICATA_VERSION}.tar.gz && \
    tar -zxvf ./suricata-${SURICATA_VERSION}.tar.gz && \
    cd suricata-${SURICATA_VERSION} && \
    ./configure --enable-pfring --disable-rust --enable-lua --enable-laujit --enable-geoip --with-libjansson-libraries=/usr/lib64 --prefix=/usr/local --disable-gccmarch-native --silent && \
    make --silent && make install && ldconfig && make install-conf && \
    mkdir -p /var/log/suricata /usr/local/etc/suricata/  && \
    suricata-update enable-source et/open && suricata-update && \
    cp /usr/src/suricata-${SURICATA_VERSION}/classification.config /usr/local/etc/suricata/ && \
    cp /usr/src/suricata-${SURICATA_VERSION}/reference.config /usr/local/etc/suricata/ && \
    cp /usr/src/suricata-${SURICATA_VERSION}/threshold.config /usr/local/etc/suricata/ && \
#Clean Up
    rm -f pfring-${PFRING_VERSION}.x86_64.rpm pfring-dkms-${PFRING_VERSION}.noarch.rpm suricata-${SURICATA_VERSION}.tar.gz && \
    rm -rf suricata-${SURICATA_VERSION} 

ENV PATH=$PATH:/usr/local/bin

COPY ./suricata.yaml /usr/local/etc/suricata/

#Add Supervisord file
COPY ./supervisord.conf /etc/supervisord.d/ 

RUN sed -i s:MONITOR_INTERFACE:${MONITOR_INTERFACE}:g /etc/supervisord.d/supervisord.conf

#Kickoff Supervisor
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.d/supervisord.conf"]
