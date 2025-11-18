pipeline {
    agent any

    environment {
        MAVEN_HOME = "/opt/maven"
        JAVA_HOME = "/opt/java/openjdk"
        PATH = "$MAVEN_HOME/bin:$JAVA_HOME/bin:/opt/sonar-scanner/bin:$PATH"

        SONARQUBE_URL = "http://13.201.65.221:9000"
        SONARQUBE_TOKEN = "your-sonar-token"

        NEXUS_URL = "http://54.219.194.156:8081"
        NEXUS_REPO = "maven-releases"
        NEXUS_GROUP = "com/webapp"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/Rishitha2707/war-web-project.git'
            }
        }

        stage('Build Artifact') {
            steps {
                sh """
                    echo '👉 Using Maven from: $MAVEN_HOME'
                    mvn -v
                    mvn clean package -DskipTests=false
                """
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh """
                    sonar-scanner \
                        -Dsonar.projectKey=webapp \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target \
                        -Dsonar.host.url=$SONARQUBE_URL \
                        -Dsonar.login=$SONARQUBE_TOKEN
                """
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                sh """
                    mvn deploy:deploy-file \
                        -Durl=$NEXUS_URL/repository/$NEXUS_REPO/ \
                        -DrepositoryId=nexus \
                        -DgroupId=$NEXUS_GROUP \
                        -DartifactId=mywebapp \
                        -Dversion=1.0 \
                        -Dpackaging=war \
                        -Dfile=target/*.war
                """
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh """
                    curl -u admin:admin \
                    -T target/*.war \
                    'http://13.201.65.221:8080/manager/text/deploy?path=/mywebapp&update=true'
                """
            }
        }
    }

    post {
        success { echo "✅ Pipeline completed successfully!" }
        failure { echo "❌ Pipeline failed" }
    }
}
