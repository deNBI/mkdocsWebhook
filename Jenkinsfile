node {
    def image
    stage('Clone repository') {
        checkout scm
    }

    stage('build image'){
    
                    sh 'docker rmi denbicloud/mkdocswebhook'
                    image = docker.build("denbicloud/mkdocswebhook")
        }              
    stage('push image'){
    image.push("dev")
   }              
 }
