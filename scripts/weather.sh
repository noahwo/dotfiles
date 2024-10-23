#!/usr/bin/env bash

# This script requires curl:
IP=$(curl https://ipinfo.io/ip --silent)

# Build a suitable URL and call it
RESULT=$(curl --silent https://wttr.in/"$IP"?format="%C+%f" | xargs)

# Deal with some strange possible outcomes
if [[ $RESULT == Unknow* ]]; then
  echo "ei toimi"
elif [[ $RESULT == \<!DOCTYPE* ]]; then
  echo "ei toimi"
elif [[ $RESULT == Sorr* ]]; then
  echo "ei toimi"
elif [[ $RESULT == This* ]]; then
  echo "ei toimi"
else
  echo "$RESULT"
fi
