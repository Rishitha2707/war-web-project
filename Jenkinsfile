pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONARQUBE_ENV = 'sonar'
        SCANNER_HOME = '/opt/sonar-scanner'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        stage('Build Artifact') {
            steps {
                script {
                    def MAVEN_HOME = tool 'Maven3'
                    sh "${MAVEN_HOME}/bin/mvn clean package -DskipTests=false"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=warweb \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.token=$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                script {
                    def MAVEN_HOME = tool 'Maven3'
                    sh "${MAVEN_HOME}/bin/mvn deploy -DskipTests=true"
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh """
                    curl -u admin:admin \
                    -T target/*.war \
                    'http://54.219.194.156:8080/manager/text/deploy?path=/myapp&update=true'
                """
            }
        }
    }

    post {
        success { echo "✔ Pipeline succeeded" }
        failure { echo "❌ Pipeline failed" }
    }
}
