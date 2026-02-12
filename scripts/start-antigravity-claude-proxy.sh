#!/bin/bash

# Define the log file location
LOG_FILE="antigravity.log"

echo "Starting antigravity-claude-proxy in the background..."

# 1. nohup: prevents the process from being killed when you close the terminal
# 2. > $LOG_FILE: redirects standard output to the log file
# 3. 2>&1: redirects errors to the same log file
# 4. &: runs the command in the background
nohup antigravity-claude-proxy start >"$LOG_FILE" 2>&1 &

# Capture the Process ID (PID) of the last command
PID=$!

echo "Success! Process started with PID: $PID"
echo "Logs are being written to: $LOG_FILE"
