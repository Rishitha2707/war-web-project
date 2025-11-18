pipeline {

    agent { label 'sonar' }

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
                        "\${NEXUS_URL}/repository/\${NEXUS_REPO}/\${NEXUS_GROUP}/\${NEXUS_ARTIFACT}/\${VERSION}/\${NEXUS_ARTIFACT}-\${VERSION}.war"

                        echo "✅ Artifact uploaded to Nexus successfully!"
                    """
                }
            }
        }

        stage('Deploy to Tomcat') {
            agent { label 'tomcat' }
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USR', passwordVariable: 'NEXUS_PSW'),
                    usernamePassword(credentialsId: 'tomcat', usernameVariable: 'TOMCAT_USR', passwordVariable: 'TOMCAT_PSW')
                ]) {

                    sh """
                        cd /tmp
                        rm -f *.war

                        echo "🔍 Fetching latest WAR from Nexus..."

                        DOWNLOAD_URL=\$(curl -s -u \${NEXUS_USR}:\${NEXUS_PSW} \
                            "\${NEXUS_URL}/service/rest/v1/search?repository=\${NEXUS_REPO}&group=${NEXUS_GROUP}&name=${NEXUS_ARTIFACT}" \
                            | grep -oP '"downloadUrl":\\s*"\\K[^"]+\\.war' | tail -1)

                        if [[ -z "\$DOWNLOAD_URL" ]]; then
                            echo "❌ No WAR found in Nexus!"
                            exit 1
                        fi

                        echo "⬇️ Downloading WAR: \$DOWNLOAD_URL"
                        curl -u \${NEXUS_USR}:\${NEXUS_PSW} -O "\$DOWNLOAD_URL"

                        WAR_FILE=\$(basename "\$DOWNLOAD_URL")
                        APP_NAME=\$(echo "\$WAR_FILE" | sed 's/-[0-9].*//')

                        echo "🧹 Removing old deployment from Tomcat..."
                        curl -u \${TOMCAT_USR}:\${TOMCAT_PSW} "\${TOMCAT_URL}/undeploy?path=/\${APP_NAME}" || true

                        echo "🚀 Deploying new WAR to Tomcat..."
                        curl -u \${TOMCAT_USR}:\${TOMCAT_PSW} --upload-file "\$WAR_FILE" \
                            "\${TOMCAT_URL}/deploy?path=/\${APP_NAME}&update=true"

                        echo "✅ Deployment successful!"
                    """
                }
            }
        }
    }

    post {
        success { echo '🎉 Pipeline completed successfully — Application live on Tomcat!' }
        failure { echo '❌ Pipeline failed — Check Jenkins logs.' }
    }
}
