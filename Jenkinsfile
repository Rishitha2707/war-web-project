pipeline {
  agent any

  options {
    skipDefaultCheckout(true)
    ansiColor('xterm')
    timestamps()
  }

  tools {
    jdk 'JDK17'
    maven 'Maven3'
  }

  environment {
    SONAR_HOST_URL = "http://54.153.103.78:9000"

    NEXUS_URL   = "http://54.153.103.78:8081"
    NEXUS_REPO  = "maven-releases"
    NEXUS_GROUP = "com.webapp"

    TOMCAT_HOST = "http://54.153.103.78:9090"

    IMAGE_NAME  = "tomcat-wwp"

    WORKSPACE_M2 = "${WORKSPACE}/.m2"
    MVN_SETTINGS = "${WORKSPACE}/.m2/settings.xml"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'master',
            url: 'https://github.com/Rishitha2707/war-web-project.git'
      }
    }

    stage('Read version from POM') {
      steps {
        script {
          def pom = readMavenPom file: 'pom.xml'
          env.PROJECT_VERSION = pom.version
          echo "Detected version: ${env.PROJECT_VERSION}"
        }
      }
    }

    stage('Setup Maven settings') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USR', passwordVariable: 'NEXUS_PSW')]) {
          script {
            sh """
              mkdir -p ${WORKSPACE_M2}
              echo '<settings>
                      <servers>
                        <server>
                          <id>nexus</id>
                          <username>${NEXUS_USR}</username>
                          <password>${NEXUS_PSW}</password>
                        </server>
                      </servers>
                    </settings>' > ${MVN_SETTINGS}
            """
          }
        }
      }
    }

    stage('Build') {
      steps {
        sh "mvn clean package -DskipTests"
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
          withSonarQubeEnv('Sonar') {
            sh """
              mvn sonar:sonar \
                -Dsonar.projectKey=webapp \
                -Dsonar.host.url=${SONAR_HOST_URL} \
                -Dsonar.token=${SONAR_TOKEN}
            """
          }
        }
      }
    }

    stage('Upload to Nexus') {
      steps {
        script {
          def warFile = "target/wwp-${PROJECT_VERSION}.war"

          sh """
            if [ ! -f "${warFile}" ]; then
              echo "WAR file missing: ${warFile}"
              exit 1
            fi

            mvn -s ${MVN_SETTINGS} deploy:deploy-file \
              -Durl=${NEXUS_URL}/repository/${NEXUS_REPO}/ \
              -DrepositoryId=nexus \
              -DgroupId=${NEXUS_GROUP} \
              -DartifactId=wwp \
              -Dversion=${PROJECT_VERSION} \
              -Dpackaging=war \
              -Dfile=${warFile}
          """
        }
      }
    }

    stage('Deploy to Tomcat') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'tomcat-creds', usernameVariable: 'TOMCAT_USR', passwordVariable: 'TOMCAT_PSW')]) {
          script {
            def warFile = "target/wwp-${PROJECT_VERSION}.war"

            sh """
              curl -v --fail --show-error \
                --upload-file ${warFile} \
                "http://${TOMCAT_USR}:${TOMCAT_PSW}@${TOMCAT_HOST.replace('http://','')}/manager/text/deploy?path=/wwp&update=true"
            """
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      agent { label 'docker' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            def tag = "${DOCKER_USER}/${IMAGE_NAME}:${PROJECT_VERSION}"

            writeFile file: 'Dockerfile', text: """
FROM tomcat:9-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/wwp-${PROJECT_VERSION}.war /usr/local/tomcat/webapps/wwp.war
"""

            sh "docker build -t ${tag} ."

            sh """
              echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
              docker push ${tag}
              docker logout
            """
          }
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline completed"
    }
    success {
      echo "✔ SUCCESS"
    }
    failure {
      echo "❌ FAILURE"
    }
  }
}
