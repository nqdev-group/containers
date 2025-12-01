#!/bin/bash

# Kiểm tra xem biến TOKEN và URL có được set không
if [ -z "$GITHUB_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
    echo "GITHUB_URL and RUNNER_TOKEN must be set"
    exit 1
fi

# Cấu hình runner
./config.sh --url $GITHUB_URL --token $RUNNER_TOKEN

# Chạy runner
./run.sh
