#!/bin/bash

# The NextDNS TLD list does not match the IANA list. Since the PUT method will
# validate against the nextdns list, using the IANA list will produce errors
#
# NextDNS, JSON:    https://api.nextdns.io/security/tlds
# IANA, plain text: https://data.iana.org/TLD/tlds-alpha-by-domain.txt

printf "load global TLDs\n\n"

TLDS=$(
    curl https://api.nextdns.io/security/tlds \
    | jq -r '.data[].id'
)

printf "remove allowed TLDs from list\n\n"

ALLOWED=$(cat allowed-tlds.txt)
BLOCKED=""
for TLD in $TLDS; do
    grep -iE '^'$TLD'$' <<< "$ALLOWED" >/dev/null
    if [[ $? -eq 1 ]]; then
        BLOCKED+=$TLD$'\n'
    fi
done

printf "convert back to JSON format\n\n"

JSON=$(
    for BLOCK in $BLOCKED; do
        jq --raw-output --null-input --arg BLOCK $BLOCK '{ id: $BLOCK }'
    done \
    | jq --raw-output --slurp '.'
)

printf "push new TLD block list\n\n"

curl \
    -X PUT \
    -d "$JSON" \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: $API_KEY" \
    https://api.nextdns.io/profiles/$PROFILE/security/tlds
