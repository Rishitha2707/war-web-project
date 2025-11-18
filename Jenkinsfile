pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONAR_HOST_URL = "http://sonar-qube:9000"
        SONAR_TOKEN = "your-sonar-token"
        NEXUS_URL = "http://nexus:8081"
        NEXUS_REPO = "maven-releases"
        NEXUS_GROUP = "com/webapp"
        TOMCAT_HOST = "http://my-tomcat-app:8080"
        TOMCAT_USER = "admin"
        TOMCAT_PASS = "admin"
    }

    stages {

        /* -----------------------------------
         * CHECKOUT FROM YOUR REAL GITHUB REPO
         * ----------------------------------- */
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        /* -----------------------------
         * BUILD WAR USING MAVEN
         * ----------------------------- */
        stage('Build') {
            steps {
                sh "mvn clean package"
            }
        }

        /* -----------------------------
         * SONARQUBE CODE ANALYSIS
         * ----------------------------- */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                    sonar-scanner \
                      -Dsonar.projectKey=webapp \
                      -Dsonar.sources=src \
                      -Dsonar.java.binaries=target \
                      -Dsonar.host.url=${SONAR_HOST_URL} \
                      -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        /* -----------------------------
         * QUALITY GATE CHECK
         * ----------------------------- */
        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* -----------------------------
         * UPLOAD ARTIFACT TO NEXUS
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
         * DEPLOY WAR TO TOMCAT
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
