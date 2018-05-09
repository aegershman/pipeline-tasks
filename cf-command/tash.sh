#!/bin/bash
# vim: set ft=sh

set -eu
set -o pipefail

exec 3>&1 # make stdout available as fd 3 for the result
exec 1>&2 # redirect all output to stderr for logging

local api_endpoint=${api:?api_endpoint null or not set}
local cf_user=${username:?username null or not set}
local cf_pass=${password:?password null or not set}
local skip_ssl_validation=${skip_cert_check:-false}

local args=("$api_endpoint")
[ "$skip_ssl_validation" = "true" ] && args+=(--skip-ssl-validation)

cf api "${args[@]}"
cf auth "$cf_user" "$cf_pass"

local org=${org:?org null or not set}
local space=${space:-}

local args=(-o "$org")
[ -n "$space" ] && args+=(-s "$space")

cf target "${args[@]}"

cf ${COMMAND}