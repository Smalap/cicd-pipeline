#!/bin/bash
# BeforeInstall: install Apache web server and clean the web root
dnf install -y httpd
rm -rf /var/www/html/*
