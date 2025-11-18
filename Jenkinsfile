pipeline {

    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
        // SonarScanner is not declared here (we install manually below)
    }

    environment {
        SONARQUBE_SERVER = 'sonar'
        NEXUS_URL = 'http://54.219.194.156:8081'
        NEXUS_REPO = 'maven-releases'
        TOMCAT_USER = 'admin'
        TOMCAT_PASS = 'admin'
        TOMCAT_URL = 'http://54.219.194.156:8080'
    }

    stages {

        /* -------------------------------------------------------------
           FORCE INSTALLATION OF SONAR-SCANNER TOOL
        --------------------------------------------------------------*/
        stage('Install SonarScanner Tool') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    echo "SonarScanner installed at: ${scannerHome}"
                    sh "${scannerHome}/bin/sonar-scanner --version"
                }
            }
        }

        /* -------------------------------------------------------------
           CHECKOUT CODE
        --------------------------------------------------------------*/
        stage('Checkout Code') {
            steps {
                echo "📦 Cloning source from GitHub..."
                checkout scm
            }
        }

        /* -------------------------------------------------------------
           RUN SONARQUBE ANALYSIS
        --------------------------------------------------------------*/
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    echo "🔍 Running SonarQube analysis..."

                    withSonarQubeEnv('sonar') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=webapp \
                                -Dsonar.sources=src \
                                -Dsonar.java.binaries=target
                        """
                    }
                }
            }
        }

        /* -------------------------------------------------------------
           BUILD ARTIFACT
        --------------------------------------------------------------*/
        stage('Build Artifact') {
            steps {
                echo "🏗️ Building WAR file..."
                sh "mvn clean package -DskipTests"
            }
        }

        /* -------------------------------------------------------------
           UPLOAD ARTIFACT TO NEXUS
        --------------------------------------------------------------*/
        stage('Upload Artifact to Nexus') {
            steps {
                echo "📤 Uploading WAR to Nexus..."
                sh """
                    mvn deploy \
                        -DskipTests \
                        -Dnexus.url=${NEXUS_URL} \
                        -Dnexus.repo=${NEXUS_REPO}
                """
            }
        }

        /* -------------------------------------------------------------
           DEPLOY TO TOMCAT
        --------------------------------------------------------------*/
        stage('Deploy to Tomcat') {
            steps {
                echo "🚀 Deploying WAR to Tomcat..."

                sh """
                    curl -u ${TOMCAT_USER}:${TOMCAT_PASS} \
                        -T target/*.war \
                        '${TOMCAT_URL}/manager/text/deploy?path=/webapp&update=true'
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed — check logs."
        }
    }
}
