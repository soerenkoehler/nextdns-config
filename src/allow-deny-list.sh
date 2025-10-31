#!/bin/bash

deploy_list() {
    printf "create $1 list JSON\n\n"

    JSON=$(
        jq <data/${1}-list.txt --raw-input '{ id: ., active: true }' \
        | jq --slurp
    )

    printf "push new $1 list\n\n"

    curl \
        -X PUT \
        -d "$JSON" \
        -H "Content-Type: application/json" \
        -H "X-API-KEY: $API_KEY" \
        https://api.nextdns.io/profiles/$PROFILE/${1}list
}

deploy_list allow
deploy_list deny
