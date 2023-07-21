# jenkins-surface-discovery
Jenkins Attack Surface Discovery Pipeline

![1](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/70794e22-2b49-4b90-90e8-7cdfde0ea1ab)

### 

O Jenkins Surface Discovery é uma automação dinâmica DAST (Dynamic application security testing) com o objetivo testes externos (caixa-preta) de segurança para identificar superfícies de ataque e que possibilita integração com processos de entregas contínuas (DevSecOps). O projeto consolida técnicas utilizadas em pentesting para ataques de superfície e diversas ferramentas de código aberto voltadas para a realização de pentests.

O projeto é um conjunto de scripts desenvolvidos em bash scripting com a função de executar containers docker e gerenciar os resultados entre as ferramentas, a motivação para utilizar Docker e Shell Scripting é manter a simplicidade e facilidade no uso da pipeline.

Os shell scripts podem ser utilizados em outros motores de CI/CD baseados em Linux, a motivação do uso do Jenkins é única e exclusiva por ser uma ferramenta gratuita e que permite a validação do conceito.

### Features
* *Enumeração de subdomínios*
* *Enumeração de subdomínios via brute-force*
* *Permutação de wordlists*
* *Enumeração de hosts, ip's e portas*
* *Enumeração de cabeçalhos HTTP*
* *Enumeração de query URLs*
* *Scanner básico de XSS e SQLi*
* *Scanner de vulnerabilidades*
* *Fuzzing de arquivos e diretórios*
* *Relatórios em HTML*
  
### Tools Arsenal
* *subfinder*
* *dnsx*
* *alterx*
* *massscan*
* *httpx*
* *katana*
* *nuclei*
* *ffuf*

### Pré requisitos
Os scripts são executados nos nodes do Jenkins e para o funcionamento correto é necessário a instalação das seguintes ferramentas como pré requisitos:

```bash docker git wget```

*O usuário do Jenkins precisa de acesso ao grupo docker para que o mesmo consiga gerenciar containers no node:*
```
sudo usermod -aG docker jenkins
```
https://stackoverflow.com/questions/44444099/how-to-solve-docker-permission-error-when-trigger-by-jenkins

*Para uma melhor visualização das pipelines recomenda-se a instalação do plugin **blueocean** no Jenkins.*

### Adicionando a pipeline (instalação)
A pipeline pode ser utilizada em diversas formas inclusive em outros motores de CI/CD adaptando o uso dos scripts disponíveis neste projeto, mas o objetivo principal deste projeto é executar os scripts e a pipeline no Jenkins.

Para fazer o setup do jenkins-surface-discovery é preciso instalar os pré requisitos em seu node Jenkins e depois adicionar uma nova pipeline SCM GIT para este repositório:

*New Item > Pipeline > Pipeline script from SCM > SCM GIT > Repository URL = https://github.com/vagnerd/jenkins-surface-discovery.git*

![2](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/8ff8f61d-c6a0-4a46-97c9-546e0851a2bc)

**Script Path**

O projeto contém duas pipelines (modos) diferentes de execução:

* *Jenkinsfile*: Descoberta completa da superfície.
* *Jenkinsfile-singlehost*: Descoberta da superfície de um host.

*Opcional:*

Ao executar a pipeline pela primeira vez sem os seguintes parâmetros um erro ocorre devido o Jenkins somente importar as configurações de parâmetros após o primeiro build:
* *SCAN_DOMAIN* - String Parameter
* *RESCAN* - Boolean Parameter

*Disparar a pipeline pela primeira vez sem os parâmetros causa o erro explicado acima, porém o Jenkins já faz a importação dos parâmetros automaticamente.*

**Environments (Configuração)**

A pipeline precisa de algumas environments para o seu funcionamento, existem diversas formas de se fazer isso o padrão do Jenkins é através da sua configuração global:

*Manage Jenkins > System > Environment variables*

* **JSD_PATH** - *Especifica onde as pipelines vão armazenar os resultados e parte do arsenal.*
  
  *Padrão: /var/lib/jenkins/jenkins-surface-discovery/*
  
* **JSD_WORDLIST_DNS** - *Especifica qual wordlist utilizar para o dns brute-force.*

  *Padrão: https://raw.githubusercontent.com/theMiddleBlue/DNSenum/master/wordlist/subdomains-top1mil-20000.txt*
  
* **JSD_WORDLIST_FUZZ** - *Especifica qual wordlist utilizar para encontrar arquivos no fuzzing.*

  *Padrão: https://raw.githubusercontent.com/sec-fx/wordlists/master/commom/basic-tech-paths.txt*

* **JSD_DNS_PERMUTATION** - *Habilita ou desabilita a permutação da wordlist de DNS.*

  *Padrão: false*

*Observação: Caso não definido as environments os padrões acima serão definidos automaticamente na pipeline.*

### Exemplos de uso

Para iniciar a pipeline basta criar um novo build da pipeline (Default Jenkins) ou clicar em "run" no blueocean:

![3](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/3c6c062b-7cef-4629-b654-19f87f07d663)

Ao disparar o build da pipeline é solicitado duas informações, o domínio alvo das pipelines e se é um rescan, marcando a opção rescan todas as informações anteriores do alvo são descartadas.

*Descoberta completa da superfície:*

Este modo executa uma enumeração dos subdomínios através de buscas passivas em recursos onlines e brute-force, ao obter esses endereços a pipeline executa enumerações de hosts e portas, enumerações dos cabeçalhos HTTP, enumerações de qURLs, fuzzing e varreduras de vulnerabilidades.

*Descoberta da superfície de um host:*

Este modo não executa a enumeração dos subdomínios, é feito enumerações de portas, enumeração dos cabeçalhos HTTP, enumerações de qURLs, fuzzing e varreduras de vulnerabilidades sobre o endereço do host informado.

**Adicionando o Jenkins Surface Discovery em uma pipeline**

É possível invocar o Jenkins Surface Discovery em outras pipelines já existentes, o exemplo abaixo invoca o Jenkins Surface Pipeline no modo de descoberta da superfície de um host com a opção de rescan habilitada. Desta forma estamos adicionando um stage de pentests a pipeline, ou seja incorporando alguns dos conceitos de DevSecOps a pipeline:

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

![4](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/b9030768-955f-420b-9afa-b351823219ab)

*A pipeline acima de forma resumida dispara o build para gerar o código, após isso realiza o deployment e por fim invoca os testes a cada build. O exemplo completo da pipeline está disponível no repositório: [pipeline-example](https://github.com/vagnerd/jenkins-surface-discovery/blob/master/examples/pipelines/deployment-pipeline.groovy).*  

### Relatórios

![5](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/93583403-e86d-4e25-8d83-15c13067b398)

Ao final da pipeline é disponilizado um relatório HTML como artefato com um resumo dos testes, o tempo de execução pode ser longo e variar dependendo da quantidade dos hosts e do tempo de resposta dos hosts.

![6](https://github.com/vagnerd/jenkins-surface-discovery/assets/4332906/68aa2266-b1d9-42fa-a377-3f54f4b23ee0)

Anexo ao repositório existe dois relatórios de exemplo em [reports-example](https://github.com/vagnerd/jenkins-surface-discovery/tree/master/examples/reports) do alvo *vulnweb.com*:

[report-vulnweb.com.html](https://github.com/vagnerd/jenkins-surface-discovery/tree/master/examples/reports/report-vulnweb.com.html)

[report-testphp.vulnweb.com.html](https://github.com/vagnerd/jenkins-surface-discovery/tree/master/examples/reports/report-testphp.vulnweb.com.html)



### Autor

Vagnerd Fernandes
