#!/bin/bash
su ubuntu -c 'export PORT=${server_port}; export SECRET_ID=${db_secert_arn}; export DB_ENDPOINT=${db_endpoint}; nohup /home/ubuntu/.nvm/versions/node/v16.3.0/bin/node /home/ubuntu/app/index.js &'
