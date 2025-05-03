#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)
GQL_ADMIN_ENDPOINT="https://api.blink.sv/graphql"

gql_file() {
  echo "${REPO_ROOT}/gql/$1.gql"
}

gql_query() {
  cat "$(gql_file $1)" | tr '\n' ' ' | sed 's/"/\\"/g'
}

variables_file() {
  filename="${REPO_ROOT}/results/.${1}-input.json"
  if [[ -z "$1" || ! -f "$filename" ]]; then
    echo "{}"
  else
    jq -c '.' "$filename"
  fi
}

exec_graphql() {
  local query_name=$1
  local variables=$(variables_file "$1")

  AUTH_HEADER="X-API-KEY: $TOKEN"

  curl -s \
    -X POST \
    ${AUTH_HEADER:+ -H "$AUTH_HEADER"} \
    -H "Content-Type: application/json" \
    -d "{\"query\": \"$(gql_query $query_name)\", \"variables\": $variables}" \
    "${GQL_ADMIN_ENDPOINT}"
}
