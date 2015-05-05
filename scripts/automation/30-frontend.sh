#!/usr/bin/env bash

# Setting up the path to properly use phantomjs on builders, and our node
# modules
export PATH=./node_modules/.bin/:/opt/phantomjs/bin:$PATH

set -xe

grunt test:ci
grunt test
