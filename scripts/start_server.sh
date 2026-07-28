#!/bin/bash
# ApplicationStart: start Apache and enable it on boot
systemctl start httpd
systemctl enable httpd
