pipeline {

    agent any   // <<< NO MORE LABEL CHECKING

    environment {
        SONARQUBE_SERVER = 'any agent'
        MVN_SETTINGS = '/etc/maven/settings.xml'

        NEXUS_URL = 'http://18.144.48.161:8081'
        NEXUS_REPO = 'maven-releases'
        NEXUS_GROUP = 'com/web/cal'
        NEXUS_ARTIFACT = 'webapp-add'

        TOMCAT_URL = 'http://18.144.48.161:8080/manager/text'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo '📦 Cloning source from GitHub...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[url: 'https://github.com/Rishitha2707/war-web-project.git']]
                ])
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Running SonarQube static analysis...'
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh """
                        mvn clean verify sonar:sonar -DskipTests --settings ${MVN_SETTINGS}
                    """
                }
            }
        }

        stage('Build Artifact') {
            steps {
                echo '⚙️ Building WAR...'
                sh """
                    mvn clean package -DskipTests --settings ${MVN_SETTINGS}
                    ls -lh target/*.war || true
                """
            }
        }

        stage('Upload Artifact to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USR', passwordVariable: 'NEXUS_PSW')]) {
                    sh """
                        WAR_FILE=\$(ls target/*.war | head -1)
                        VERSION="0.0.\${BUILD_NUMBER}"

                        echo "📤 Uploading WAR: \$WAR_FILE"
                        echo "📦 Version: \$VERSION"

                        curl -v -u \${NEXUS_USR}:\${NEXUS_PSW} --upload-file "\$WAR_FILE" \
                        "\${NEXUS_URL}/repository/\${NEXUS_REPO}/\${NEXUS_GROUP}/\${NEXUS_ARTIFACT}/\${VERSION}/\${NEXUS_ARTIFACT}-_
