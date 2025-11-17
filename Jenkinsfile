pipeline {
    agent any

    environment {
        SONARQUBE = "sonar"              // SonarQube Server Name in Jenkins
        NEXUS_REPO = "maven-releases"    // Your Nexus repo
        NEXUS_URL = "http://3.101.111.226:8081"
        NEXUS_GROUP = "com/web"          // Your groupId
        NEXUS_CRED = "nexus-user"        // Jenkins Credentials ID
        IMAGE_NAME = "my-tomcat-app"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
                        sh """
                        docker run --rm \
                          -e SONAR_HOST_URL="http://<3.101.111.226>:9000" \
                          -e SONAR_LOGIN="${squ_7a590a551faef596626d67a010a71076d78e5429}" \
                          -v ${WORKSPACE}:/usr/src \
                          sonarsource/sonar-scanner-cli
                        """
                    }
                }
            }
        }

        stage('Build WAR with Maven') {
            steps {
                sh """
                docker run --rm \
                  -v ${WORKSPACE}:/usr/src/mymaven \
                  -w /usr/src/mymaven \
                  maven:3.5.2-jdk-8 mvn clean package
                """
            }
        }

        stage('Upload WAR to Nexus') {
            steps {
                sh """
                curl -v -u ${NEXUS_USER}:${NEXUS_PASS} \
                --upload-file target/*.war \
                ${http://3.101.111.226:8081}/repository/${NEXUS_REPO}/${NEXUS_GROUP}/app/1.0/app-1.0.war
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Run Tomcat Container') {
            steps {
                sh """
                docker rm -f tomcat-app || true
                docker run -d --name tomcat-app -p 8080:8080 ${IMAGE_NAME}:latest
                """
            }
        }
    }
}
