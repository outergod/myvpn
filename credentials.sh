#!/bin/bash
set -e

mkdir -p ~/.aws
cat >> ~/.aws/credentials <<'EOF'
[default]
aws_access_key_id = ${access_key}
aws_secret_access_key = ${secret_access_key}
EOF

chmod 600 ~/.aws/credentials
