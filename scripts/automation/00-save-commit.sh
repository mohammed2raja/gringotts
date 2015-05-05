#!/usr/bin/env bash

set -xe
git submodule update --init
git rev-parse HEAD > commit.txt
