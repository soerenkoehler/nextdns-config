#!/bin/bash

# get TLD list from next dns
#
# hint: nextdns TLD list does not match the IANA list under
# https://data.iana.org/TLD/tlds-alpha-by-domain.txt and the PUT method will
# validate against the nextdns list

TLDS=$(
    curl https://api.nextdns.io/security/tlds \
    | jq -r '.data[].id'
)

# remove allowed TLDs from list

ALLOWED=$(cat allowed-tlds.txt)
BLOCKED=""
for TLD in $TLDS; do
    grep -iE '^'$TLD'$' <<< "$ALLOWED" >/dev/null
    if [[ $? -eq 1 ]]; then
        BLOCKED+=$TLD$'\n'
    fi
done

# convert back to JSON format

JSON=$(
    for BLOCK in $BLOCKED; do
        jq --raw-output --null-input --arg BLOCK $BLOCK '{ id: $BLOCK }'
    done \
    | jq --raw-output --slurp '.'
)

jq <<< $JSON

# read profile credentials and push new TLD block list

# read -p "Profile: " PROFILE
# read -p "API-Key: " API-KEY
curl \
    -X PUT \
    -d "$JSON" \
    -H "X-API-KEY: $API-KEY" \
    https://api.nextdns.io/profiles/$PROFILE/security/tlds
