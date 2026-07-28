#!/bin/bash
# ValidateService: fail the deployment if the site is not responding
sleep 5
curl -f http://localhost/ > /dev/null 2>&1
