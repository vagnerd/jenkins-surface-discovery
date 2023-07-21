#!/bin/bash
###
## NAME:         vul.sh
## AUTHOR:       vagnerd <vagner.rodrigues@gmail.com>
## DESCRIPTION:  Script for vulnerability scanning
##

. ./scripts/jsd.sh r_check_envs

r_install_nulei_templates() {
  mkdir -p $JSD_PATH/nuclei-templates
  docker run -t --rm -v $JSD_PATH/nuclei-templates:/root/nuclei-templates/ projectdiscovery/nuclei:latest -update-templates

  if [ ! -d "$JSD_PATH/nuclei-templates/fuzzing-templates" ]; then
      git clone https://github.com/projectdiscovery/fuzzing-templates.git $JSD_PATH/nuclei-templates/fuzzing-templates
  fi
}


r_xss() {
  echo -e "\n\033[0;32m[XSS] Scan vulns\033[0m"
    if test -f "$JSD_PATH/reports/$1/xss.txt"; then
      echo -e "\033[1;33m[SKIPED] XSS $1 already executed.\033[0m"
      cat $JSD_PATH/reports/$1/xss.txt
    else
      ./scripts/vul.sh r_install_nulei_templates
      docker run -t --rm -v $JSD_PATH/reports/$1/:/tmp/nuclei/ -v $JSD_PATH/nuclei-templates/:/root/nuclei-templates/ projectdiscovery/nuclei:latest -l /tmp/nuclei/endpoints.txt -t fuzzing-templates -o /tmp/nuclei/xss.txt -stats
    fi
}

r_nuclei() {
  echo -e "\n\033[0;32m[NUCLEI] Scan vulns\033[0m"
  mkdir -p $JSD_PATH/reports/$1/nuclei

  while read -r line
  do
    DFFILE=`echo $line | awk '{ print $1 }' | cut -d/ -f3 | sed 's/\:/_/g'`
    SCAN_URL=`echo $line | awk '{ print $1 }'`
    if test -f "$JSD_PATH/reports/$1/nuclei/$DFFILE.txt"; then
      echo -e "\033[1;33m[SKIPED] nuclei $SCAN_URL already executed.\033[0m"
      cat $JSD_PATH/reports/$1/nuclei/$DFFILE.txt
    else
        echo $SCAN_URL
        docker run -t --rm -v $JSD_PATH/reports/$1/nuclei/:/tmp/nuclei/ -v $JSD_PATH/nuclei-templates/:/root/nuclei-templates/ projectdiscovery/nuclei:latest -scan-strategy template-spray -concurrency 40 -u $SCAN_URL -o /tmp/nuclei/$DFFILE.txt -stats
    fi
  done < "$JSD_PATH/reports/$1/httpx-inspect.txt"
}

$1 $2
