#!/bin/bash
###
## NAME:         enum.sh
## AUTHOR:       vagnerd <vagner.rodrigues@gmail.com>
## DESCRIPTION:  Script for DNS,HTTP and PORTS enumeration
##

. ./scripts/jsd.sh r_check_envs

r_core() {
  ./scripts/jsd.sh r_banner
  echo -e "\033[0;31m[OFFENSIVE-PIPELINES] INIT\033[0m"
  rm -rf $JSD_PATH/tmp/$1
  mkdir -p $JSD_PATH/tmp/$1
  mkdir -p $JSD_PATH/reports/$1
  mkdir -p $JSD_PATH/wordlists
}

### SUBFINDER
#
r_subfinder() {
  echo -e "\n\033[0;32m[SUBFINDER] Enumerate DNS\033[0m"
  if test -f "$JSD_PATH/reports/$1/subfinder.txt"; then
    echo -e "\033[1;33m[SKIPED] SUBFINDER already executed to $1.\033[0m"
    cat $JSD_PATH/reports/$1/subfinder.txt
  else
    docker run -t --rm -v $JSD_PATH/reports/$1/:/tmp/subfinder/ projectdiscovery/subfinder:latest -stats -d $1 -o /tmp/subfinder/subfinder.txt
  fi
}

### WL PERMUTATION
#
r_alterx() {
  echo -e "\n\033[0;32m[ALTERX] Permutation DNS Wordlist\033[0m"
  if test -f "$JSD_PATH/wordlists/dns-names-alterx.txt"; then
    echo -e "\033[1;33m[SKIPED] ALTERX already executed to $1.\033[0m"
  else
    docker run -t --rm -v $JSD_PATH/wordlists/:/tmp/alterx/ projectdiscovery/alterx:latest -l /tmp/alterx/dns-names.txt -o /tmp/alterx/dns-names-alterx.txt
  fi
}

### DNSX BRUTE FORCE 
#  
r_dnsx() {
  echo -e "\n\033[0;32m[DNSX] Enumerate DNS\033[0m"
  if ! test -f "$JSD_PATH/wordlists/dns-names.txt"; then
    wget $JSD_WORDLIST_DNS -O $JSD_PATH/wordlists/dns-names.txt
  fi
  if test -f "$JSD_PATH/reports/$1/dnsx.txt"; then
    echo -e "\033[1;33m[SKIPED] DNSX already executed to $1.\033[0m"
    cat $JSD_PATH/reports/$1/dnsx.txt
  else
    if [ $JSD_DNS_PERMUTATION == "true" ]; then
      ./scripts/enum.sh r_alterx
      WL_DNS="dns-names-alterx.txt"
    else
      WL_DNS="dns-names.txt"
    fi
    docker run -t --rm -v $JSD_PATH/reports/$1/:/tmp/dnsx/ -v $JSD_PATH/wordlists/:/tmp/wordlists/ projectdiscovery/dnsx:latest -stats -w /tmp/wordlists/$WL_DNS -d $1 -o /tmp/dnsx/dnsx.txt
  fi
}

### PORT SCAN
#
r_portscan() {
  mkdir -p $JSD_PATH/reports/$1/ports
  echo -e "\n\033[0;32m[MASSCAN] Port Scan\033[0m"
  cat $JSD_PATH/reports/$1/subfinder.txt $JSD_PATH/reports/$1/dnsx.txt | tr '[:upper:]' '[:lower:]' | sort -n | uniq > $JSD_PATH/reports/$1/dnsnames.txt
  if ! test -f "$JSD_PATH/reports/$1/dnsnames-resolved.txt"; then
      docker run -t --rm -v $JSD_PATH/reports/$1/:/tmp/dnsx/ projectdiscovery/dnsx:latest -stats -l /tmp/dnsx/dnsnames.txt -o /tmp/dnsx/dnsnames-resolved.txt
  fi

  while read -r line; do
    if test -f "$JSD_PATH/reports/$1/ports/$line"; then
      echo -e "\033[1;33m[SKIPED] Port scan in $line already executed to $1.\033[0m"
      cat $JSD_PATH/reports/$1/ports/$line
    else
      RHOST_IP=`host $line | grep address | head -n1 | awk '{ print $4 }'`
      if test -f "$JSD_PATH/tmp/$1/$RHOST_IP"; then
	echo -e "\033[1;33m[SKIPED] $RHOST_IP already executed.. reuse scan to $line.\033[0m"
	cat $JSD_PATH/tmp/$1/$RHOST_IP | sed 's/'$RHOST_IP'/'$line'/g' > $JSD_PATH/reports/$1/ports/$line
      else
        echo -e "\n\033[0;32m[MASSCAN] Scanning host $line\033[0m"
        docker run -t --rm -v $JSD_PATH/reports/$1/ports/:/tmp/masscan/ adarnimrod/masscan $RHOST_IP -p 0-65535 --rate 10000 -oL /tmp/masscan/$line
	cp $JSD_PATH/reports/$1/ports/$line $JSD_PATH/tmp/$1/$RHOST_IP
        cat $JSD_PATH/reports/$1/ports/$line
      fi
    fi
  done < "$JSD_PATH/reports/$1/dnsnames-resolved.txt"

}

### BUILD HOSTS FOR SCAN
#
r_mergeall() {
  rm -f $JSD_PATH/reports/$1/scan-hosts.txt
  for XHOST in `ls $JSD_PATH/reports/$1/ports`; do
    grep open $JSD_PATH/reports/$1/ports/$XHOST | awk '{ print $3 }' > $JSD_PATH/tmp/$1/$XHOST.ports
    XHOST_IP=`grep open $JSD_PATH/reports/$1/ports/$XHOST | awk '{ print $4 }' | sort -n | uniq | head -n1`
    cat $JSD_PATH/tmp/$1/$XHOST.ports | awk '{ print "'$XHOST':" $1 }' >> $JSD_PATH/tmp/$1/scan-hosts.txt 
    cat $JSD_PATH/tmp/$1/$XHOST.ports | awk '{ print "'$XHOST_IP':" $1 }' >> $JSD_PATH/tmp/$1/scan-hosts.txt
  done
  cat $JSD_PATH/tmp/$1/scan-hosts.txt | sort -n | uniq > $JSD_PATH/reports/$1/scan-hosts.txt
}


### HTTPX
r_httpx() {
  echo -e "\n\033[0;32m[HTTPX] Inspect HTTP hosts\033[0m"

  if test -f "$JSD_PATH/reports/$1/httpx-inspect.txt"; then
    echo -e "\033[1;33m[SKIPED] HTTPX already executed to $1.\033[0m"
    cat $JSD_PATH/reports/$1/httpx-inspect.txt
  else
    ./scripts/enum.sh r_mergeall $1
    docker run -t --rm -v $JSD_PATH/reports/$1/:/tmp/httpx/ projectdiscovery/httpx:latest -stats -l /tmp/httpx/scan-hosts.txt -title -tech-detect -status-code -fr -nc -o /tmp/httpx/httpx-inspect.txt
    cat $JSD_PATH/reports/$1/httpx-inspect.txt | awk '{ print $1 }' > $JSD_PATH/reports/$1/httpx-hosts.txt
  fi
}

### ENDPOINTS
r_endpoints() {
  echo -e "\n\033[0;32m[ENDPOINTS] Inspect HTTP endpoints\033[0m"
  if test -f "$JSD_PATH/reports/$1/endpoints.txt"; then
    echo -e "\033[1;33m[SKIPED] Katana already executed to $1.\033[0m"
    cat $JSD_PATH/reports/$1/endpoints.txt
  else
      docker run -t --rm -v $JSD_PATH/reports/$1/:/tmp/katana/ projectdiscovery/katana:latest -list /tmp/katana/httpx-hosts.txt -f qurl -o /tmp/katana/endpoints-all.txt
      cat $JSD_PATH/reports/$1/endpoints-all.txt | grep "$1" | egrep -v "\.js" | egrep -v "\.css" > $JSD_PATH/reports/$1/endpoints.txt || echo "=( not found qurls"
  fi
}

$1 $2
