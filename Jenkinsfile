def k8slabel = "jenkins-pipeline-${UUID.randomUUID().toString()}"
//line 20 //we have container to run terraform in it
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
            choice(choices: ['us-west-2', 'us-west-1', 'us-east-2', 'us-east-1', 'eu-west-1'], description: 'Please select the region', name: 'aws_region'),
            choice(choices: ['TRACE', ' DEBUG', ' INFO', ' WARN', ' ERROR'], description: 'Please select a log', name: 'terraform_logs'), //+ hw2
            choice(choices: ['dev', 'QA ', 'stage', 'prod'], description: 'Please select an environment ', name: 'Environments'),
            input message: '', parameters: [string(defaultValue: '', description: 'Please provide an image ID', name: 'AWS_image_id', trim: false)]
        ])
    ])

    podTemplate(name: k8slabel, label: k8slabel, yaml: slavePodTemplate, showRawYaml: false) {    //we have schedule the container on top of nodes
      node(k8slabel) {
          
        stage("Pull SCM") {      //we have statge to pull sorce code 
            //git 'https://github.com/sevilbeyza/jenkins-instance.git'
            git credentialsId: 'githubaccess', url: 'https://github.com/sevilbeyza/jenkins-instance.git'
        }

        
        stage("Generate Variables") {                   //it is generate the veriables 
          dir('deployments/terraform') {
          println("Generate Variables")
            def deployment_configuration_tfvars = """   //created veriable definition. it shoud be very clearly show what for to anther coworker    
            environment = "${Environment}"           //for "writeFile" we took this file path "deployment_configuration_tfvars"
            """.stripIndent()                        // .stripIndent() it is remove the empty space 
            writeFile file: 'deployment_configuration.tfvars', text: "${deployment_configuration_tfvars}"  //here we create the file, tf vars file will give envronment
            sh 'cat deployment_configuration.tfvars >> dev.tfvars'           //run cat command and make sure that file is created 
                                            //here what we do we appand the 2 file each other with  >>
          }   
        }
        
        
        
        container("buildtools") {               //we add the container in this line before dir 
            dir('deployments/terraform') {      //after adding container we need to add credentials to run the terraform code //this is spesific folder to run terraform 
               withCredentials([usernamePassword(credentialsId: "aws-access-${Environments}",  //we have access key and secret key to access the environmet 
                passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {   //put credentials inside dir and take stages in it 
                    //print the environment what we chosed dynamicly
                    println("Selected cred is: aws-access-${Environments}")
                    println("Selected ami_id is: ${AWS_image_id}") 
                     
                     stage("Terraform Apply/plan") {
                        if (!params.terraformDestroy) {      //DESTROY SECILI DEGILSE VE APPLY SECILDIYSE ONLY APPLY                       =======> Preventing running together   
                            if (params.terraformApply) {        //If it is not work puts prams.  //IF USER CLICK THE APPLY DO
                                println("Applying the changes")
                                sh """
                                #!/bin/bash
                                export AWS_DEFAULT_REGION=${params.aws_region}    
                                source ./setenv.sh dev.tfvars   //creating backend.tf based on your configuration
                                TF_LOG=${params.terraform_logs} terraform apply -auto-approve -var-file \$DATAFILE
                                """                          // \ mean hey jenkins consider datafile in script 
                            } else {
                                println("Planing the changes")
                                sh """
                                #!/bin/bash
                                set +ex     // means whatever command you are running show me in console 
                                ls -l
                                export AWS_DEFAULT_REGION=${aws_region}
                                source ./setenv.sh dev.tfvars
                                TF_LOG=${params.terraform_logs} terraform plan -var-file \$DATAFILE
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
                            source ./setenv.sh dev.tfvars                               
                            TF_LOG=${params.terraform_logs} terraform destroy -auto-approve -var-file \$DATAFILE  //TF_LOG added here 
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
//setenv.sh will take care of terraform init and run the code 108
//define default region 84