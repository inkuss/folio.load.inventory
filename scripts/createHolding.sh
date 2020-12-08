#!/bin/bash
# Legt ein Folio-Holding (Lokaldatensatz) an.
# Autor: I. Kuss, hbz
# Anlagedatum: 23.11.2020
# Hile: Aufruf mit Option -h
source shell_functions.sh

# Zuweisung der Skript-Parameter-Defaults
folio_json_datei="../sample_inventory/holdings/10000001.json"
okapi_url="api.localhost/okapi"
tenant="diku";
login_datei="login.json"
silent_off=0
verbose=0

usage() {
  cat <<EOF
  Legt einen Folio-Lokaldatensatz an.
  Anlage anahnd einer Datei im Format FOLIO-JSON.
  Beispielaufruf:        ./createHolding.sh -f ../sample_inventory/holdings/10000001.json -u myokapiurl

  Optionen:
   - f [Datei]      Lokaldaten im Format FOLIO-JSON
   - h              Hilfe (dieser Text)
   - l [Datei]      login.json Anmeldedaten; Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standardwert: $login_datei
   - u [OKAPI_URL]  OKAPI_URL, Default: $okapi_url
   - s              silent off (nicht still), Standardwert: $silent_off
   - t [TENANT]     TENANT (Folio-Mandant), Default: $tenant
   - v              verbose (gesprächig), Standardwert: $verbose
EOF
  exit 0
  }

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "f:h?l:u:st:v" opt; do
    case "$opt" in
    f)  folio_json_datei=$OPTARG
        ;;
    h|\?) usage
        ;;
    l)  login_datei=$OPTARG
        ;;
    u)  okapi_url=$OPTARG
        ;;
    s)  silent_off=1
        ;;
    t)  tenant=$OPTARG
        ;;
    v)  verbose=1
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Beginn der Hauptverarbeitung
if [ ! -f $folio_json_datei ]; then
  echo "ERROR: ($folio_json_datei) ist keine reguläre Datei !"
  exit 0
fi

echo "Lege Lokaldatensatz an anhand von Datei: $folio_json_datei"

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi

TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $tenant" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $okapi_url/authn/login | grep -i "^x-okapi-token: " )
curl $curlopts -S -X POST -H "$TOKEN" -H "X-Okapi-Tenant: $tenant" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" -d \@$folio_json_datei $okapi_url/holdings-storage/holdings
echo

exit 0
