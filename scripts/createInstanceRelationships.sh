#!/bin/bash
# Legt Instanzbeziehungen (Über- oder Unterordnungen) an.
# Autor: I. Kuss, hbz
# Hilfe: Aufruf mit Option -h

# Default Parameter-Werte
directory="../sample_inventory/instanceRelationships"
okapi_url="api.localhost/okapi"
tenant="diku"
login_datei="login.json"
silent_off=0
verbose=0

usage() {
  cat <<EOF
  Legt Folio-Instanzbeziehungen an
  Beispielaufruf:   ./createInstanceRelationships.sh -d ../sample_inventory/instanceRelationships -u myokapiurl -t tenant

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Instanzbeziehungen (Format: FOLIO-JSON), Standardwert: $directory
   - h                  Hilfe (dieser Text)
   - l [Datei]      login.json Anmeldedaten. Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standardwert: $login_datei
   - u [OKAPI_URL]  OKAPI_URL, Default: $okapi_url
   - s              silent off (nicht still), Standardwert: $silent_off
   - t [TENANT]     TENANT (Mandant), Default: $tenant
   - v              verbose (gesprächig), Standardwert: $verbose
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
  ./createInstanceRelationship.sh -f $IR -l $login_datei -u $okapi_url -s $silent_off -f $tenant -v $verbose
done

exit 0
