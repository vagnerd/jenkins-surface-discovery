# jenkins-surface-discovery
Jenkins Attack Surface Discovery Pipeline

[Readme in portuguese version](https://github.com/vagnerd/jenkins-surface-discovery/blob/master/README-pt.md) 🇧🇷

![1](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/5222e73d-3bb9-4807-a605-967de4c3d502)

### 

Jenkins Surface Discovery is a dynamic DAST (Dynamic application security testing) automation for external (black box) security testing to identify attack surfaces and that enables integration with continuous delivery processes (DevSecOps). The project consolidates techniques used in pentesting for surface attacks and open source tools to performing pentesting.

The project is a set of scripts developed in bash scripting for running docker containers and managing the results between the tools, the motivation for using Docker and Shell Scripting is to keep the pipeline simple and easy to use.

Shell scripts can be used in other Linux-based CI/CD engines, the motivation for using Jenkins is unique and exclusive because it is a free tool and allows proof of concept.

### Features
* *Subdomain enumeration*
* *Brute-force subdomain enumeration*
* *Wordlist permutation*
* *Host, IPs and ports enumeration*
* *HTTP header enumeration*
* *Query URLs enumeration*
* *Basic XSS and SQLi scanner*
* *Vulnerability scanner*
* *Fuzzing of files and dirs*
* *Reports in HTML*
  
### Tools Arsenal
* *subfinder*
* *dnsx*
* *alterx*
* *massscan*
* *httpx*
* *katana*
* *nuclei*
* *ffuf*

### Prerequisites
The scripts are executed in Jenkins nodes and for the correct operation it is necessary to install the following tools as prerequisites:

```bash docker git wget```

*The Jenkins user needs access to the docker group so that he can manage containers on node:*
```
sudo usermod -aG docker jenkins
```
https://stackoverflow.com/questions/44444099/how-to-solve-docker-permission-error-when-trigger-by-jenkins

*For a better visualization of the pipelines it is recommended to install the plugin **blueocean** in Jenkins.*

### Create new pipeline (installation)

The pipeline can be used in different ways including other CI/CD engines adapting the use of the scripts available in this project, but the main objective of this project is to run the scripts and the pipeline in Jenkins.

To setup jenkins-surface-discovery you need to install the prerequisites on your Jenkins node and then add a new SCM GIT pipeline to this repository:

*New Item > Pipeline > Pipeline script from SCM > SCM GIT > Repository URL = https://github.com/vagnerd/jenkins-surface-discovery.git*

![2](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/4f4ecaa5-7be1-4b78-a513-1e230360e51a)

**Script Path**

The project contains two (modes) different execution pipelines:

* *Jenkinsfile*: Complete surface discovery.
* *Jenkinsfile-singlehost*: Surface discovery of a host.

*Optional:*

When running the pipeline for the first time without the following parameters an error occurs because Jenkins only imports parameter settings after the first build:
* *SCAN_DOMAIN* - String Parameter
* *RESCAN* - Boolean Parameter

*Launching the pipeline for the first time without the parameters causes the error explained above but Jenkins imports the parameters automatically.*

**Environments (settings)**

The pipeline needs some environments for it to work there are several ways to do this the Jenkins default is through its global configuration:

*Manage Jenkins > System > Environment variables*

* **JSD_PATH** - *Defines where the pipelines will store the results and part of the arsenal.*
  
  *Default: /var/lib/jenkins/jenkins-surface-discovery/*
  
* **JSD_WORDLIST_DNS** - *Defines which wordlist to use for dns brute-force.*

  *Default: https://raw.githubusercontent.com/theMiddleBlue/DNSenum/master/wordlist/subdomains-top1mil-20000.txt*
  
* **JSD_WORDLIST_FUZZ** - *Defines which wordlist to use to find files in fuzzing.*

  *Default: https://raw.githubusercontent.com/sec-fx/wordlists/master/commom/basic-tech-paths.txt*

* **JSD_DNS_PERMUTATION** - *Enables or disables DNS wordlist permutation.*

  *Default: false*

*Note: If environments are not defined the above defaults will be automatically defined in the pipeline.*

### Usage examples

To start the pipeline just create a new pipeline build (Default Jenkins) or click "run" in blueocean:

![3](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/157ed651-c8a2-466a-8017-c8c5294281d8)

When triggering the pipeline build two information are requested, the target domain of the pipelines and if it is a rescan by checking the rescan option all previous target information is discarded.

*Complete surface discovery:*

This mode performs an enumeration of subdomains through passive searches in online resources and brute-force, when obtaining these addresses the pipeline performs enumeration of hosts and ports, enumeration of HTTP headers, enumeration of qURLs, fuzzing and vulnerability scans.

*Discovery of the surface of a host:*

This mode does not perform subdomain enumeration, it performs port enumeration, HTTP header enumeration, qURL enumeration, fuzzing and vulnerability scans on the entered host address.

**Adding Jenkins Surface Discovery to a Pipeline**

It is possible to invoke Jenkins Surface Discovery in other existing pipelines, the example below invokes the Jenkins Surface Pipeline in surface discovery mode of a host with the rescan option enabled. In this way, we are adding a pentest stage to the pipeline, that is, incorporating some of the DevSecOps concepts to the pipeline:

```
        stage ('Invoke Jenkins Surface Discovery') {
            steps {
                build job: 'jenkins-surface-discovery-single', parameters: [
                string(name: 'SCAN_DOMAIN', value: "testphp.vulnweb.com"),
                booleanParam(name: 'RESCAN', value: "true")
                ]
            }
        }
```

![4](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/a98db5fe-0520-456a-a995-a5d9f759390b)

*The pipeline above trigger the build to generate the code after which it deploys and finally invokes the tests at each build. The complete pipeline example is available in the repository: [pipeline-example](https://github.com/vagnerd/jenkins-surface-discovery/blob/master/examples/pipelines/deployment-pipeline.groovy).*  

### Reports

![5](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/82ce3019-5fd7-4a4d-9508-82a4def52049)

At the end of the pipeline an HTML report is available as an artifact with a summary of the tests, the execution time can be long and vary depending on the number of hosts and the response time of the hosts.

![6](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/87bdc5af-5d1a-4557-b6ef-715c2f51a039)

Attached to the repository there are two example reports in [reports-example](https://github.com/vagnerd/jenkins-surface-discovery/tree/master/examples/reports) of target *vulnweb.com*:

[report-vulnweb.com.html](https://github.com/vagnerd/jenkins-surface-discovery/tree/master/examples/reports/report-vulnweb.com.html)

[report-testphp.vulnweb.com.html](https://github.com/vagnerd/jenkins-surface-discovery/tree/master/examples/reports/report-testphp.vulnweb.com.html)



### Developed by

Vagnerd Fernandes 
