#!/bin/bash
# Read IDs with name and code from a Folio endpoint.
# Code is not available in every endpoint. Might read source and other fields as well.
# Author: I. Kuss, HBZ-NRW
# Creation date: Dec. 7th, 2020
# Call script with option -h for Help

# Script parameters with default values
script=$0
okapi_url="api.localhost/okapi"
tenant="diku"
login_file="login.json"
silent_off=0
verbose=0
endpoint=""

usage() {
  cat <<EOF
  Reads IDs with name and code from a Folio endpoint.
  Usage: $script <Folio-Endpoint (URL fragment after Okapi's URL)>

  Command line options:
   - h          Print this help page
   - l [file]   Name of authentication file with LOGIN credentials for your folio instance.
                File Format: { "tenant" : "<your tenant>", "username" : "<your user name>", "password" : "<your password" }
                Defaults to: $login_file
   - s          silent off (not silent). Defaults to: $silent_off
   - t [tenant] TENANT, Default to: $tenant
   - u [url]    Okapi URL, URL of your Okapi instance. Defaults to: $okapi_url
   - v          verbose. Defaults to: $verbose

  Sample Call: $script -t mytenant -u myokapiurl contributor-types
EOF
  exit 0
  }

# Evaluate command line options
OPTIND=1  # Reset in case getopts has been used previously in the shell
while getopts "h?l:st:u:v" opt; do
    case "$opt" in
    h|\?) usage
        ;;
    l)  login_file=$OPTARG
        ;;
    s)  silent_off=1
        ;;
    t)  tenant=$OPTARG
        ;;
    u)  okapi_url=$OPTARG
        ;;
    v)  verbose=1
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Begin Main Processing
if [ -z "$1" ]; then
  echo "  ERROR: Please provide one parameter: Endpoint"
  usage
fi
endpoint=$1

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi

TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $tenant" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_file $okapi_url/authn/login | grep -i "^x-okapi-token: " )
curl $curlopts -S -X GET -H "$TOKEN" -H "X-Okapi-Tenant: $tenant" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" $okapi_url/$endpoint?limit=1000
echo

exit 0
