# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
FROM centos:7

ARG PFRING_VERSION
ARG MOLOCH_VERSION
ARG NDPI_VERSION
ARG MONITOR_INTERFACE

COPY ./yum-build-deps.spec /etc/yum.repos.d/

#Install Dependencies and Moloch
RUN yum install -q -y epel-release yum-utils && \
    yum install -q -y `cat /etc/yum.repos.d/yum-build-deps.spec` && \
    cd /usr/src && \
    rpm -ivh https://forensics.cert.org/centos/cert/7/x86_64/ndpi-${NDPI_VERSION}.x86_64.rpm && \
    wget -q --no-check-certificate -O pfring-${PFRING_VERSION}.x86_64.rpm https://forensics.cert.org/centos/cert/7/x86_64/pfring-${PFRING_VERSION}.x86_64.rpm && \
    wget -q --no-check-certificate -O pfring-dkms-${PFRING_VERSION}.noarch.rpm https://forensics.cert.org/centos/cert/7/x86_64/pfring-dkms-${PFRING_VERSION}.noarch.rpm && \
    wget -q -O moloch-${MOLOCH_VERSION}.x86_64.rpm https://s3.amazonaws.com/files.molo.ch/builds/centos-7/moloch-${MOLOCH_VERSION}.x86_64.rpm && \
    rpm -ih ./pfring-dkms-${PFRING_VERSION}.noarch.rpm ./pfring-${PFRING_VERSION}.x86_64.rpm && rpm -ih ./moloch-${MOLOCH_VERSION}.x86_64.rpm

RUN echo "Update Configuration" && \
    sed -i s/MOLOCH_ELASTICSEARCH/localhost:9200/ /data/moloch/etc/config.ini.sample && \
    sed -i s:MOLOCH_INSTALL_DIR:/data/moloch:g /data/moloch/etc/config.ini.sample && \
    sed -i s:MOLOCH_INTERFACE:${MONITOR_INTERFACE}:g /data/moloch/etc/config.ini.sample && \
    sed -i s:"# certFile":certFile:g /data/moloch/etc/config.ini.sample && \ 
    sed -i s:"# keyFile":keyFile:g /data/moloch/etc/config.ini.sample && \ 
    cp /data/moloch/etc/config.ini.sample /data/moloch/etc/config.ini && \
    echo "Get OUI File And rir assignments file" && \
    cd /data/moloch/etc/ && wget -q -O oui.txt https://raw.githubusercontent.com/wireshark/wireshark/master/manuf && \
    wget -q -O ipv4-address-space.csv https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv && \
    mkdir /var/log/supervisord/ && touch /var/log/supervisord/supervisord.log

#Copy Start up scripts
COPY ./run_viewer.sh ./run_capture.sh /data/moloch/bin/
RUN  sed -i s:MOLOCH_INTERFACE:${MONITOR_INTERFACE}:g /data/moloch/bin/run_capture.sh && \
     chmod 755 /data/moloch/bin/run_capture.sh && \
     chmod 755 /data/moloch/bin/run_viewer.sh

COPY ./openssl_request.conf /data/moloch/etc/
RUN cd /data/moloch/etc/ && \
    openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout moloch.key -out moloch.cert -config ./openssl_request.conf -extensions 'v3_req'

#Add Supervisord file
COPY ./supervisord.conf /etc/supervisord.d/

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.d/supervisord.conf"]  
