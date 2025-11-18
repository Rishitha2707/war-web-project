pipeline {

    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONAR_SCANNER_HOME = tool 'SonarScanner'
    }

    stages {

        stage('Verify SonarScanner') {
            steps {
                sh """
                    echo \"Scanner Path: ${SONAR_SCANNER_HOME}\"
                    ${SONAR_SCANNER_HOME}/bin/sonar-scanner --version
                """
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                            -Dsonar.projectKey=webapp \
                            -Dsonar.sources=src \
                            -Dsonar.java.binaries=target
                    """
                }
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

    }

    post {
        failure { echo "❌ Pipeline failed" }
        success { echo "✅ Success" }
    }
}
