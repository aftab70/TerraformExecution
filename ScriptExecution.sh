#!/bin/bash

set -x

sudo apt-get update 
cd /tmp
sudo apt-get install -y adduser libfontconfig1
sudo wget https://dl.grafana.com/oss/release/grafana_9.0.0_amd64.deb
sudo dpkg -i grafana_9.0.0_amd64.deb
systemctl daemon-reload
service grafana-server start


