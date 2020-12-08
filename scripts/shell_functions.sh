#!/bin/bash
# Eine Funktionssammlung zu benutzen in bash-Skripten
# Autor: I. Kuss, hbz

# allgemeiner Kram, Zeichenkettenverarbeitung

# Funktionsdefinitionen
function stripOffQuotes {
  local string=$1;
  local len=${#string};
  echo ${string:1:$len-2};
}

func2() {
  echo "Starting func2"
  }
