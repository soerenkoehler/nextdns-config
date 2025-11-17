#!/bin/bash

deploy_list() {
    printf "create $1 list JSON\n\n"

    JSON=$(
        src/preprocess.sh data/${1}-list.txt \
        | jq --raw-input '{ id: ., active: true }' \
        | jq 'select(.id!="")' \
        | jq --slurp
    )

    printf "push new $1 list:\n"
    printf "%s\n\n" "$JSON"

    curl \
        -X PUT \
        -d "$JSON" \
        -H "Content-Type: application/json" \
        -H "X-API-KEY: $API_KEY" \
        https://api.nextdns.io/profiles/$PROFILE/${1}list
}

deploy_list allow
deploy_list deny
