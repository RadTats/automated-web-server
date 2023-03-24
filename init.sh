#!/bin/bash
sudo yum update
sudo yum install -y nginx
sudo systemctl start nginx.service
echo "Hello Cydar" > /usr/share/nginx/html/index.html