def k8slabel = "jenkins-pipeline-${UUID.randomUUID().toString()}"

def slavePodTemplate = """
      metadata:
        labels:
          k8s-label: ${k8slabel}
        annotations:
          jenkinsjoblabel: ${env.JOB_NAME}-${env.BUILD_NUMBER}
      spec:
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: component
                  operator: In
                  values:
                  - jenkins-jenkins-master
              topologyKey: "kubernetes.io/hostname"
        containers:
        - name: buildtools                        
          image: fuchicorp/buildtools
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        - name: docker
          image: docker:latest
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        serviceAccountName: default
        securityContext:
          runAsUser: 0
          fsGroup: 0
        volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
    """

    properties([
        parameters([             //hepsini alt alta yazip codu generate yapinca boyle combine oluyor 
            booleanParam(defaultValue: false, description: 'Please select to apply the changes ', name: 'terraformApply'),             // says apply is as defaul not sellected
            booleanParam(defaultValue: false, description: 'Please select to destroy all ', name: 'terraformDestroy'),                 // says destroy is as a defaul not sellected
            choice(choices: ['us-west-2', 'us-west-1', 'us-east-2', 'us-east-1', 'eu-west-1'], description: 'Please select the region', name: 'aws_region')
        ])
    ])

  


    podTemplate(name: k8slabel, label: k8slabel, yaml: slavePodTemplate, showRawYaml: false) {
      node(k8slabel) {
          
        stage("Pull SCM") {
            //git 'https://github.com/sevilbeyza/jenkins-instance.git'
            git credentialsId: 'githubaccess', url: 'https://github.com/sevilbeyza/jenkins-instance.git'
        }

        stage("Generate Variables") {
            println("Generate Variables")
        }

        container("buildtools") {               //we add the container in this line before dir 
            dir('deployments/terraform') {      //after adding container we need to add credentials to run the terraform code 
                withCredentials([usernamePassword(credentialsId: 'packer-build-aws-creds', //put credentials inside dir and take stages in it 
                passwordVariable: 'AWS_ACCESS_KEY_ID', usernameVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                  
                    
                     stage("Terraform Apply/plan") {
                        if (!params.terraformDestroy) {      //DESTROY SECILI DEGILSE VE APPLY SECILDIYSE ONLY APPLY                       =======> Preventing running together   
                            if (params.terraformApply) {        //If it is not work puts prams.  //IF USER CLICK THE APPLY DO
                                println("Applying the changes")
                                sh """
                                #!/bin/bash
                                export AWS_DEFAULT_REGION=${aws_region}    //define default region 
                                source ./setenv.sh dev.tfvars
                                terraform apply -auto-approve 
                                """
                            } else {
                                println("Planing the changes")
                                sh """
                                #!/bin/bash
                                set +ex
                                ls -l
                                export AWS_DEFAULT_REGION=${aws_region}
                                source ./setenv.sh dev.tfvars
                                terraform plan
                                """
                            }
                        }
                    }

                     stage("Terraform Destroy") {                                     //IF USER CLICK THE DESTROY DO 
                        if (params.terraformDestroy) {
                            println("Destroying the all")
                            sh """
                            #!/bin/bash
                            export AWS_DEFAULT_REGION=${params.aws_region}
                            source ./setenv.sh dev.tfvars                               //setenv.sh will take care of terraform init and run the code 
                            terraform destroy -auto-approve 
                            """
                        } else {
                            println("Skiping the destroy")
                        }
                    }
                }

            }
         }
      }
    }
