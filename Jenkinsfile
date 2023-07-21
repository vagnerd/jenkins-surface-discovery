pipeline {

  // Jenkins Surface Discovery Pipeline
  // Author: Vagnerd Fernandes <vagner.rodrigues@gmail.com>
  // https://github.com/vagnerd/jenkins-surface-discovery

  agent any

  parameters {
    string(name: 'SCAN_DOMAIN', defaultValue: '', description: 'Wildcard domain target ex: vulnweb.com')
    booleanParam(name: 'RESCAN', defaultValue: false, description: 'Discard old scans')
  }

  options {
    ansiColor('xterm')
  }

  stages {
    stage('Init Scan') {
      steps {
        sh '''
          if [ -z ${JSD_PATH} ]; then
            export JSD_PATH="/var/lib/jenkins/jenkins-surface-discovery"
          fi

          if [ "${RESCAN}" = "true" ]; then
            rm -rf $JSD_PATH/reports/${SCAN_DOMAIN}/*
            rm -rf $JSD_PATH/tmp/${SCAN_DOMAIN}/*
          fi
          scripts/enum.sh r_core ${SCAN_DOMAIN}
        '''
      }
    }

    stage('Enumeration') {
      steps {
        parallel (
          "Subdomain Enumeration": {
            sh "scripts/enum.sh r_subfinder ${params.SCAN_DOMAIN}"
          },
          "DNS Enumeration": {
            sh "scripts/enum.sh r_dnsx ${params.SCAN_DOMAIN}"
          }
        )
      }
    }

    stage('Ports Enumeration') {
      steps {
        sh "scripts/enum.sh r_portscan ${params.SCAN_DOMAIN}"
      }
    }

    stage('HTTP Enumeration') {
      steps {
        sh "scripts/enum.sh r_httpx ${params.SCAN_DOMAIN}"
      }
    }

    stage('qURL Enumeration') {
      steps {
        sh "scripts/enum.sh r_endpoints ${params.SCAN_DOMAIN}"
      }
    }

    stage('Nuclei XSS/SQLi Scan') {
      steps {
        sh "scripts/vul.sh r_xss ${params.SCAN_DOMAIN}"
      }
    }

    stage('Nuclei Vulnerability Scan') {
      steps {
        sh "scripts/vul.sh r_nuclei ${params.SCAN_DOMAIN}"
      }
    }

    stage('Fuzzing Discovery Files') {
      steps {
        sh "scripts/fuzz.sh r_ffuf ${params.SCAN_DOMAIN}"
      }
    }

    stage('Fix ownership files') {
      steps {
        sh '''
          if [ -z ${JSD_PATH} ]; then
            export JSD_PATH="/var/lib/jenkins/jenkins-surface-discovery"
          fi

          JENKINS_UID="`id -u jenkins`:`id -g jenkins`"
          docker run --rm -v $JSD_PATH:/tmp/fix-dir alpine:latest sh -c "chown -R $JENKINS_UID /tmp/fix-dir"
        '''
      }
    }

    stage('Build Reports') {
      steps {
        sh "scripts/build-report.sh ${params.SCAN_DOMAIN}"
        archiveArtifacts("report-${params.SCAN_DOMAIN}.html")
      }
    }

  }
}
