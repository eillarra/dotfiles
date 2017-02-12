#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


echo
print_step 'Update `hosts` file'

sudo curl -s 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' >> /etc/hosts
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
print_info 'Hosts file updated'
