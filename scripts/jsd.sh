#!/bin/bash

r_banner() {
echo -e '\033[0;32m
     _ ____  ____
    | / ___||  _ \
 _  | \___ \| | | |
| |_| |___) | |_| |
 \___/|____/|____/

Jenkins Surface Discovery
https://github.com/vagnerd/jenkins-surface-discovery

\033[0m'
}

r_check_envs() {

  [[ -v JSD_PATH ]] || export JSD_PATH="/var/lib/jenkins/jenkins-surface-discovery"
  [[ -v JSD_WORDLIST_DNS ]] || export JSD_WORDLIST_DNS="https://raw.githubusercontent.com/theMiddleBlue/DNSenum/master/wordlist/subdomains-top1mil-20000.txt"
  [[ -v JSD_WORDLIST_FUZZ ]] || export JSD_WORDLIST_FUZZ="https://raw.githubusercontent.com/sec-fx/wordlists/master/commom/basic-tech-paths.txt"
  [[ -v JSD_DNS_PERMUTATION ]] || export JSD_DNS_PERMUTATION="false"

}


$1 $2
