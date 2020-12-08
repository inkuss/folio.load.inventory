#!/bin/bash
# Löscht Folio-Titeldatensätze anhand eines Verzeichnisses
# Autor: I. Kuss, hbz
# Hilfe: deleteInstances.sh -h

# Standard Parameter-Werte
directory="../sample_inventory/instances"
okapi_url="api.localhost/okapi"
tenant="diku"
login_datei="login.json"
silent_off=0
verbose=0

usage() {
  cat <<EOF
  Löscht Folio-Titeldatensätze
  Beispielaufruf:       ./deleteInstances.sh -d ../sample_inventory/instances -u myokapiurl -t mytenant

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Titeldaten (Format: FOLIO-JSON), Standardwert: $directory
   - h                  Hilfe (dieser Text)
   - l [Datei]      login.json Anmeldedaten. Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standard $login_datei
   - u [OKAPI_URL]  OKAPI_URL, Default: $okapi_url
   - s              silent off (nicht still), Standard: $silent_off
   - t [TENANT]     TENANT, Default: $tenant
   - v              verbose (gesprächig), Standard: $verbose
EOF
  exit 0
  }

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:h?l:u:st:v" opt; do
    case "$opt" in
    d)  directory=$OPTARG
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
inputDir=$directory
for instance in $inputDir/*.json; do
  ./deleteInstance.sh -f $instance -l $login_datei -u $okapi_url -s $silent_off -t $tenant -v $verbose
done

exit 0
