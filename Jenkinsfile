pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {
        SONARQUBE_SERVER = 'sonar'
        SONAR_URL = 'http://sonar-qube:9000'
        MVN_SETTINGS = '/etc/maven/settings.xml'
        NEXUS_URL = 'http://nexus:8081'
        NEXUS_REPO = 'maven-releases'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/your/repo.git'
            }
        }

        stage('Build') {
            steps {
                sh "mvn -s ${MVN_SETTINGS} clean install"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "mvn sonar:sonar -Dsonar.projectKey=myproject -Dsonar.host.url=${SONAR_URL}"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false
            }
        }

        stage('Upload to Nexus') {
            steps {
                sh """
                    mvn -s ${MVN_SETTINGS} deploy \
                    -DaltDeploymentRepository=${NEXUS_REPO}::default::${NEXUS_URL}/repository/${NEXUS_REPO}/
                """
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh "curl -u admin:admin -T target/*.war http://my-tomcat-app:8080/manager/text/deploy?path=/myapp"
            }
        }
    }
}
