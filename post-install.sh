#!/bin/sh

# Catch errors
set -e

# Ensure certs are up to date
update-ca-certificates

# make saure we have the latest packages
/sbin/apk update
/sbin/apk upgrade

# Add a standard user.
adduser -D -u1000 worker
