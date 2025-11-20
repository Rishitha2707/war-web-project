pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        TOMCAT_CONTAINER = "tomcat9-server"
        TOMCAT_PORT = "9090"
        WAR_NAME = "wwp-1.0.1.war"
    }

    stages {

        stage('Build WAR') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Start Tomcat Container') {
            steps {
                script {
                    // Stop old container
                    sh """
                        if [ \$(docker ps -aq -f name=$TOMCAT_CONTAINER) ]; then
                            docker rm -f $TOMCAT_CONTAINER || true
                        fi
                    """

                    // Start new Tomcat
                    sh """
                        docker run -d \
                            --name $TOMCAT_CONTAINER \
