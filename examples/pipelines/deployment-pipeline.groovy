pipeline {

  agent any

    stages 
    {
        stage('Build Code') {
            steps {
                sh 'echo code'
            }
        }

        stage('Deploy Code') {
            steps {
                sh 'echo deploy code'
            }
        }
        
        stage ('Invoke Jenkins Surface Discovery') {
            steps {
                build job: 'jenkins-surface-discovery-single', parameters: [
                string(name: 'SCAN_DOMAIN', value: "testphp.vulnweb.com"),
                booleanParam(name: 'RESCAN', value: "true")
                ]
            }
        }
        
    }
}
