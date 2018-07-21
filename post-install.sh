#!/bin/sh

# Catch errors
set -e

# make saure we have the latest packages
/sbin/apk update
/sbin/apk upgrade

# Add a standard user.
adduser -D -u1000 worker
