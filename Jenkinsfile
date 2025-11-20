pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONAR_HOST_URL = "http://54.153.103.78:9000"
        SONAR_TOKEN = "squ_9615680f597c6da567dd69cd90212315f0583955"

        NEXUS_URL = "http://54.153.103.78:8081"
        NEXUS_REPO = "maven-releases"

        TOMCAT_HOST = "http://54.153.103.78:9090"
        TOMCAT_USER = "admin"
        TOMCAT_PASS = "admin"

        DOCKERHUB_USER = "rishi01dadireddy"
        DOCKERHUB_PASS = "dckr_pat_o1ajuSqVuSp-p_qW5xwvF8GDcp0"
        IMAGE_NAME = "tomcat-wwp"
        IMAGE_VERSION = "1.0.1"
    }

    stages {

        /* -----------------------------
         * CHECKOUT
         * ----------------------------- */
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        /* -----------------------------
         * MAVEN BUILD
         * ----------------------------- */
        stage('Build') {
            steps {
                sh "mvn clean package"
            }
        }

        /* -----------------------------
         * SONAR ANALYSIS USING MAVEN
         * ----------------------------- */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar') {
                    sh """
                    mvn sonar:sonar \
                      -Dsonar.projectKey=webapp \
                      -Dsonar.host.url=${SONAR_HOST_URL} \
                      -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        /* -----------------------------
         * UPLOAD WAR TO NEXUS
         * ----------------------------- */
        stage('Upload to Nexus') {
            steps {
                sh """
                mvn deploy:deploy-file \
                  -Durl=${NEXUS_URL}/repository/${NEXUS_REPO}/ \
                  -DrepositoryId=nexus \
                  -DgroupId=${NEXUS_GROUP} \
                  -DartifactId=wwp \
                  -Dversion=1.0.1 \
                  -Dpackaging=war \
                  -Dfile=target/wwp-1.0.1.war
                """
            }
        }

        /* -----------------------------
         * DEPLOY TO TOMCAT
         * ----------------------------- */
        stage('Deploy to Tomcat') {
            steps {
                sh """
                curl -u ${TOMCAT_USER}:${TOMCAT_PASS} \
                  -T target/wwp-1.0.1.war \
                  "${TOMCAT_HOST}/manager/text/deploy?path=/wwp&update=true"
                """
            }
        }

        /* ----------------------------------------------
         * BUILD CUSTOM TOMCAT IMAGE & PUSH TO DOCKER HUB
         * ---------------------------------------------- */
        stage('Build & Push Docker Image') {
            steps {
                script {
                    // Create Dockerfile dynamically
                    writeFile file: 'Dockerfile', text: """
                    FROM tomcat:9-jdk17
                    RUN rm -rf /usr/local/tomcat/webapps/*
                    COPY target/wwp-1.0.1.war /usr/local/tomcat/webapps/wwp.war
                    """

                    // Build Docker image
                    sh "docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_VERSION} ."

                    // Login and push to DockerHub
                    sh """
                    echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                    docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_VERSION}
                    docker logout
                    """
                }
            }
        }
    }

    /* -----------------------------
     * POST ACTIONS
     * ----------------------------- */
    post {
        always {
            echo "Pipeline completed"
        }
        success {
            echo "✔ Deployment Successful!"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
