#!/bin/sh
#
# Copyright (c) 2018-2020 Dave Hall <skwashd@gmail.com>
# MIT Licensed, see LICENSE for more information.
#

# Catch errors
set -ex

# Ensure certs are up to date
update-ca-certificates

# make saure we have the latest packages
/sbin/apk update
/sbin/apk upgrade

# Add a standard user.
adduser -D -u1000 worker
