pipeline {
    agent any

    environment {
        SONAR_HOST_URL = "http://18.144.48.161:9000"        // SonarQube URL
        SONAR_TOKEN = "squ_7a590a551faef596626d67a010a71076d78e5429" // Sonar token
        NEXUS_REPO = "maven-releases"                      // Nexus repository name
        NEXUS_URL = "http://18.144.48.161:8081"           // Nexus base URL
        NEXUS_GROUP = "com/web"                            // Maven groupId
        NEXUS_CRED = "nexus-user"                          // Jenkins credentials ID for Nexus
        IMAGE_NAME = "my-tomcat-app"                       // Docker image name
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh """
                docker run --rm \
                  -e SONAR_HOST_URL="${SONAR_HOST_URL}" \
                  -e SONAR_LOGIN="${SONAR_TOKEN}" \
                  -v ${WORKSPACE}:/usr/src \
                  sonarsource/sonar-scanner-cli
                """
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
                withCredentials([usernamePassword(credentialsId: "${NEXUS_CRED}", usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh """
                    curl -v -u ${NEXUS_USER}:${NEXUS_PASS} \
                    --upload-file target/*.war \
                    ${NEXUS_URL}/repository/${NEXUS_REPO}/${NEXUS_GROUP}/app/1.0/app-1.0.war
                    """
                }
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

    post {
        always {
            echo "Pipeline finished."
        }
        failure {
            echo "Pipeline failed!"
        }
        success {
            echo "Pipeline succeeded!"
        }
    }
}
