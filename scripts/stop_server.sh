#!/bin/bash
# ApplicationStop: stop Apache if it is running (safe on first deploy)
if systemctl is-active --quiet httpd; then
  systemctl stop httpd
fi
exit 0
