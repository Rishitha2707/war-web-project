pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        NEXUS_URL = 'http://54.219.194.156:8081'
        NEXUS_REPO = 'maven-releases'
        NEXUS_GROUP = 'com/webapp'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "📦 Cloning source from GitHub..."
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "🔍 Running SonarQube static analysis..."
                withSonarQubeEnv('sonar') {
                    script {
                        def scannerHome = tool 'Sonar-Scanner'
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

        stage('Build Artifact') {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                sh """
                    mvn deploy -DskipTests \
                    -Dnexus.url=${NEXUS_URL} \
                    -Dnexus.repo=${NEXUS_REPO}
                """
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh """
                    curl -u admin:admin \
                    -T target/*.war \
                    http://54.219.194.156:8080/manager/text/deploy?path=/myapp&update=true
                """
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed — Check Jenkins logs."
        }
        success {
            echo "✅ Pipeline success!"
        }
    }
}
