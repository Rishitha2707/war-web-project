pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONARQUBE_ENV = 'sonar'   // Your sonar server name in Jenkins → manage → configure system
        SCANNER_HOME = tool 'ManualScanner'
        MVN_SETTINGS = '/etc/maven/settings.xml'
        NEXUS_URL = 'http://54.219.194.156:8081'
        NEXUS_REPO = 'maven-releases'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=warweb \
                        -Dsonar.projectName=warweb \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Build Artifact') {
            steps {
                sh "mvn clean package -s ${MVN_SETTINGS}"
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                sh """
                    mvn deploy -s ${MVN_SETTINGS} \
                    -DskipTests=true
                """
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
        success { echo "✔️ Pipeline succeeded" }
        failure { echo "❌ Pipeline failed" }
    }
}
