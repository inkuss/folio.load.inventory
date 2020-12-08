#!/bin/bash
# Löscht Folio-Instanzbeziehungen anhand eines Verzeichnisses
# Autor: I. Kuss, hbz
# Hilfe: deleteInstanceRelationships.sh -h

# Standard Parameter-Werte
directory="../sample_inventory/instanceRelationships"
okapi_url="api.localhost/okapi"
tenant="diku"
login_datei="login.json"
silent_off=0
verbose=0

usage() {
  cat <<EOF
  Löscht Folio-Instanzbeziehungen
  Beispielaufruf:  ./deleteInstanceRelationships.sh -d ../sample_inventory/instanceRelationships -u myokapiurl -t mytenant

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Instanzbeziehungen (Format: FOLIO-JSON), Standardwert: $directory
   - h                  Hilfe (dieser Text)
   - l [Datei]      login.json Anmeldedatem. Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standard $login_datei
   - u [OKAPI_URL]  OKAPI_URL, Default: $okapi_url
   - s              silent off (nicht still), Standard: $silent_off
   - t [TENANT]     TENANT (Mandant), Default: $tenant
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
for IR in $inputDir/*.json; do
  ./deleteInstanceRelationship.sh -f $IR -l $login_datei -u $okapi_url -s $silent_off -t $tenant -v $verbose
done

exit 0
