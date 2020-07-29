# network-security-analyser

[![Photon OS 3.0](https://img.shields.io/badge/Photon%20OS-3.0-orange)](https://vmware.github.io/photon/)

## Table of Contents

- [Network-security-analyser](#Network-security-analyser)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Prerequisites](#Prerequisites)
  - [QuickStart Guide](#QuickStart Guide)
  - [Samples](#Samples)
  - [Getting in touch](#Getting in touch)
  - [Contributing](#contributing)
  - [License](#license)

## Overview

The Network Security analyzer is a collection of open source network security montioring tools configured to work together that enables security personals to keep an eye on the data traversing through their network by analyzing and storing the network packets captured.

While suricata performs signature based intrusion detection, zeek does an in-depth analysis for multiple protocols as well detects anamolies. Moloch being a full packet capture engine, provides evidence and artifacts for further investigation.


## Architecture

VMware Photon OS can be deployed to any vSphere-based infrastructure, including an on-premises and/or any public cloud environment, running on vSphere such as VMware Cloud on AWS or VMware Cloud on Dell-EMC.

Setup requires a minimal Photon OS to be deployed using an OVA or ISO image.

Network Security Analysis comprises of multiple OpenSource solutions:
 - [Zeek](https://github.com/zeek/zeek)
 - [Suricata](https://suricata-ids.org/)
 - [Moloch](https://github.com/aol/moloch)
 - Photon OS ([Github](https://github.com/vmware/photon))

The install also includes PF_RING installation that helps improve packet capture rate.

Insert architecture diag image???

## Prerequisites
 - A PhotonOS VM with outbound internet connection, refer [PhotonOS Network Configuration](https://vmware.github.io/photon/assets/files/html/3.0/photon_admin/configuring-network-interfaces.html)
 - VM requires a network adaptor for management interface and depending on the requirement add a secondary NIC for ingesting traffic from a SPAN or TAP device.
 - Create a local user called 'netsec' and provide sudo priviliges.

## QuickStart Guide
 - Login as netsec user
 - Setup Network and resovler/DNS.
 - Git Clone: git clone https://github.com/vmware-samples/net-sec-analysis
 - Run the install script: cd net-sec-analysis && bash src/install.sh

## Modify configuration
- MONITOR_INTERFACE, Moloch credentails, PF_RING version etc can be updated by modifying src/scripts/install.sh script.
- By default all applications are configured to listen on eth0 interface, this can be changed to second NIC added to the VM in case of ingesting span/tap traffic.
- When a secondary network interface is configured for span/tap, use the below command to bring up the interface:
  /sbin/ip link set eth1 up
- A systemd service can be configured to bring up the interface automatically -

```
cat /etc/systemd/system/span_iface.service
[Unit]
Description=Bring up Span interface
[Service]
Type=oneshot
ExecStart=/sbin/ip link set eth1 up
[Install]
WantedBy=multi-user.target
```

- Enable at boot and start interface

```
systemctl enable span_iface
systemctl start span_iface
```

## Tests
 - Tests are performed by loading a sample PCAP provided in the install package and can be run using the scripts provided in test dir. 

## Getting in touch

Feel free to reach out to the Team:
  - Email us at (mailto: <net-security-analysis@vmware.com>)

## Contributing

The Network security analyzer team welcomes contributions from the community. Before you start working with Network security analyzer, please
read our [Developer Certificate of Origin](https://cla.vmware.com/dco). All contributions to this repository must be
signed as described on that page. Your signature certifies that you wrote the patch or have the right to pass it on
as an open-source patch. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Network Security Analyzer is available under the BSD-2 license. Please see [LICENSE.txt](LICENSE.txt).
