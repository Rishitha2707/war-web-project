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
                    // Stop old container if exists
                    sh """
                        if [ \$(docker ps -aq -f name=$TOMCAT_CONTAINER) ]; then
                            docker rm -f $TOMCAT_CONTAINER || true
                        fi
                    """

                    // Start new Tomcat with manager enabled
                    sh """
                        docker run -d \
                            --name $TOMCAT_CONTAINER \
                            -p $TOMCAT_PORT:8080 \
                            -e TZ=Asia/Kolkata \
                            -e CATALINA_OPTS="-Djava.security.egd=file:/dev/./urandom" \
                            tomcat:9-jdk17
                    """

                    // Create manager account inside container
                    sh """
                        docker exec $TOMCAT_CONTAINER bash -c '
                        printf "<tomcat-users>\\n" > /usr/local/tomcat/conf/tomcat-users.xml
                        printf "<role rolename=\\"manager-script\\"/>\\n" >> /usr/local/tomcat/conf/tomcat-users.xml
                        printf "<user username=\\"admin\\" password=\\"admin\\" roles=\\"manager-script\\"/>\\n" >> /usr/local/tomcat/conf/tomcat-users.xml
                        printf "</tomcat-users>\\n" >> /usr/local/tomcat/conf/tomcat-users.xml
                        '
                    """

                    // Restart container to apply changes
                    sh "docker restart $TOMCAT_CONTAINER"

                    // Wait for Tomcat to fully start
                    sh "sleep 15"
                }
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh """
                    curl -u admin:admin -T target/$WAR_NAME \
                    http://localhost:$TOMCAT_PORT/manager/text/deploy?path=/wwp&update=true
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "curl -I http://localhost:$TOMCAT_PORT/wwp/"
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
        }
        fail
