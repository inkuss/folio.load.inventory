#!/bin/bash
# Löscht eine Instanzbeziehung (Über- oder Unterordnung)
# Autor: I. Kuss, hbz
# Anlagedatum: 23.11.2020
source shell_functions.sh

# Default-Parameter-Werte
useFile=0
folio_json_file="../sample_inventory/instanceRelationships/1891_IR1.json"
okapi_url="api.localhost/okapi"
tenant="diku"
login_datei="login.json"
silent_off=0
verbose=0

usage() {
  cat <<EOF
  Löscht eine Instanzbeziehung (Über- oder Unterordnung)
  1. Aufruf ohne Optionen : Löscht ein Instanzbeziehung anhand ihrer ID.
     Aufruf:         ./deleteInstanceRelationship.sh ID -u myokapiurl
     benötigt: login.json im gleichen Verzeichnis.
     Beispielaufruf: ./deleteInstanceRelationship.sh 7433c70e-8887-550b-a048-0e421ad628f2 -u myokapiurl
  2. Aufruf mit Parameteroption -f : Löscht eine Instanzbeziehung anahnd einer Datei im Format FOLIO-JSON.
                                     Parst Item-ID aus Datei.
     Beispielaufruf: ./deleteInstanceRelationship.sh -f ../sample_inventory/instanceRelationships/1891_IR1.json -u myokapiurl

  Optionen:
   - f [Datei]      ID wird aus Datei gelesen, Standardwert: $folio_json_file
   - h              Hilfe (dieser Text)
   - l [Datei]      login.json Anmeldedatem. Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standard $login_datei
   - u [OKAPI_URL]  OKAPI_URL, Default: $okapi_url
   - s              silent off (nicht still), Standard: $silent_off
   - t [TENANT]     TENANT (Mandant), Default: $tenant
   - v              verbose (gesprächig), Standard: $verbose
  
  Parameter:
    \$1 : Item-ID
  
EOF
  exit 0
  }

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "f:h?l:u:st:v" opt; do
    case "$opt" in
    f)  useFile=1
        folio_json_file=$OPTARG
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
id=""
if [ $useFile == 1 ]; then
  echo "Datei=$folio_json_file"
  if [ ! -f $folio_json_file ]; then
    echo "ERROR: ($folio_json_file) ist keine reguläre Datei!"
    exit 0
  fi
  id=`cat $folio_json_file | jq ".id"`
  id=$(stripOffQuotes $id)
else
  id=$1
fi
echo "Lösche Instanzbeziehung id=$id"

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $tenant" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $okapi_url/authn/login | grep -i "^x-okapi-token: " )
curl $curlopts -S -X DELETE -H "$TOKEN" -H "X-Okapi-Tenant: $tenant" -H "Content-type: application/json; charset=utf-8" $okapi_url/instance-storage/instance-relationships/$id
echo

exit 0
