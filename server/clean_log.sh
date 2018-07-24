#!/usr/bin/env bash
#find . -name "*.log" -type f -print -exec rm -f {} \;
find . -type d -name "*20[0-9][0-9]_[0-9][0-9]_[0-9][0-9]" -print -exec rm -rf {} \;



