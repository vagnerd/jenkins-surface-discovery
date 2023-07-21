#!/bin/bash
###
## NAME:         fuzz.sh
## AUTHOR:       vagnerd <vagner.rodrigues@gmail.com>
## DESCRIPTION:  Script for fuzzing scanning
##

. ./scripts/jsd.sh r_check_envs

r_ffuf() {
  LIMIT_RESULT=50
  echo -e "\n\033[0;32m[FFUF] Basic discover files\033[0m"
  mkdir -p $JSD_PATH/reports/$1/ffuf

  if ! test -f "$JSD_PATH/wordlists/fuzz-wordlist.txt"; then
    wget $JSD_WORDLIST_FUZZ -O $JSD_PATH/wordlists/fuzz-wordlist.txt
  fi

  while read -r line
  do
    DFFILE=`echo $line | awk '{ print $1 }' | cut -d/ -f3 | sed 's/\:/_/g'`
    SCAN_URL=`echo $line | awk '{ print $1 }'`
    if test -f "$JSD_PATH/reports/$1/ffuf/$DFFILE.txt"; then
      echo -e "\033[1;33m[SKIPED] ffuf $SCAN_URL already executed.\033[0m"
      cat $JSD_PATH/reports/$1/ffuf/$DFFILE.txt | cut -d\, -f3 | sort -n | uniq | egrep -v redirectlocation | head -n $LIMIT_RESULT
      echo ""
    else
      echo -e "\n\033[0;32m[FFUF] Fuzzing URL $line\033[0m"
      docker run --rm -v $JSD_PATH/reports/$1/ffuf/:/tmp/ffuf/ -v $JSD_PATH/wordlists/:/tmp/wordlists/ secsi/ffuf -s -fs 0 -ac -c -v -w /tmp/wordlists/fuzz-wordlist.txt -u $SCAN_URL/FUZZ -sf -of csv -o /tmp/ffuf/$DFFILE.txt
      cat $JSD_PATH/reports/$1/ffuf/$DFFILE.txt | cut -d\, -f3 | sort -n | uniq | egrep -v redirectlocation | head -n $LIMIT_RESULT
      cat $JSD_PATH/reports/$1/ffuf/* | cut -d\, -f3 | sort -n | uniq | egrep -v redirectlocation > $JSD_PATH/reports/$1/ffuf.txt
    fi
  done < "$JSD_PATH/reports/$1/httpx-hosts.txt"
}

$1 $2
