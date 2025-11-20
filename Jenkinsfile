pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONARQUBE_SERVER = 'sonar'
        MVN_SETTINGS = '/etc/maven/settings.xml'
        NEXUS_URL = "http://54.153.103.63:8081"
        NEXUS_REPO = "maven-releases"
        NEXUS_GROUP = "com.webapp"
        DOCKERHUB_CREDENTIALS = 'dockerhub-cred'
        IMAGE_NAME = "war-web-app"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh "mvn clean package -s ${MVN_SETTINGS}"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(SONARQUBE_SERVER) {
                    sh "mvn sonar:sonar"
                }
            }
        }

        stage('Nexus Upload') {
            steps {
                sh """
                    mvn deploy -DaltDeploymentRepository=${NEXUS_REPO}::default::${NEXUS_URL}/repository/${NEXUS_REPO} \
                    -s ${MVN_SETTINGS}
                """
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS,
                                         usernameVariable: 'USER',
                                         passwordVariable: 'PASS')
                    ]) {
                        sh """
                            echo $PASS | docker login -u $USER --password-stdin
                            docker tag ${IMAGE_NAME}:latest $USER/${IMAGE_NAME}:latest
                            docker push $USER/${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }
    }
}
