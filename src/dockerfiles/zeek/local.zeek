# This script logs which scripts were loaded during each run.
@load misc/loaded-scripts
@load tuning/defaults
@load misc/capture-loss
@load misc/stats
@load misc/scan
@load misc/detect-traceroute
@load frameworks/software/vulnerable
@load frameworks/software/version-changes
@load-sigs frameworks/signatures/detect-windows-shells
@load protocols/ftp/software
@load protocols/smtp/software
@load protocols/ssh/software
@load protocols/http/software
#@load protocols/http/detect-webapps
@load protocols/dns/detect-external-names
@load protocols/ftp/detect
@load protocols/conn/known-hosts
@load protocols/conn/known-services
@load protocols/ssl/known-certs
@load protocols/ssl/validate-certs
@load protocols/ssl/log-hostcerts-only
# @load protocols/ssl/notary
@load protocols/ssh/geo-data
@load protocols/ssh/detect-bruteforcing
@load protocols/ssh/interesting-hostnames
@load protocols/http/detect-sqli
@load frameworks/files/hash-all-files
@load frameworks/files/detect-MHR
@load policy/frameworks/notice/extend-email/hostnames
# @load policy/protocols/ssl/heartbleed
@load policy/protocols/conn/vlan-logging
@load policy/protocols/conn/mac-logging
@load policy/protocols/smb/log-cmds
@load policy/tuning/json-logs.zeek
@load ./ja3
@load ./zeek-community-id
