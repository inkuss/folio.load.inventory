#!/bin/bash
# Erzeugt Folio-Holdings (Lokaldatensätze) anhand eines Verzeichnisses
# Autor: I. Kuss, hbz
# Hilfe: createHoldings.sh -h

# Defaults für die Skript-Parameter
directory="../sample_inventory/holdings"
okapi_url="api.localhost/okapi"
tenant="diku";
login_datei="login.json"
silent_off=0
verbose=0

usage() {
  cat <<EOF
  Legt Folio-Lokalsätze (Holdings) an
  Beispielaufruf:        ./createHoldings.sh -d ../sample_inventory/holdings -u myokapiurl -t mytenant

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Holdings-Dateien (Format: FOLIO-JSON), Standardwert: $directory
   - h                  Hilfe (dieser Text)
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
for holding in $inputDir/*.json; do
  ./createHolding.sh -f $holding -l $login_datei -u $okapi_url -s $silent_off -t $tenant -v $verbose
done

exit 0
