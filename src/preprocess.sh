#!/bin/bash

sed 's/\s*#.*$//' <$1 \
| awk 'NF>0'
