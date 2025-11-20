pipeline {
  agent any

  options {
    skipDefaultCheckout(true)          // we control checkout explicitly
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

    // local workspace settings path (we create this dynamically)
    WORKSPACE_M2 = "${env.WORKSPACE}/.m2"
    MVN_SETTINGS = "${env.WORKSPACE}/.m2/settings.xml"
  }

  stages {

    stage('Checkout') {
      steps {
        // explicit checkout only once (avoid double SCM checkout)
        checkout([$class: 'GitSCM',
                  branches: [[name: 'refs/heads/master']],
                  userRemoteConfigs: [[url: 'https://github.com/Rishitha2707/war-web-project.git']]])
      }
    }

    stage('Read version from POM') {
      steps {
        script {
          // requires pipeline-utility-steps / readMavenPom available in your Jenkins
          def pom = readMavenPom file: 'pom.xml'
          env.PROJECT_VERSION = pom.version
          echo "Project version detected: ${env.PROJECT_VERSION}"
        }
      }
    }

    stage('Setup Maven settings (workspace)') {
      steps {
        // Create workspace .m2 and write settings.xml using credentials from Jenkins
        withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USR', passwordVariable: 'NEXUS_PSW')]) {
          sh '''
            mkdir -p "$WORKSPACE_M2"
            cat > "$MVN_SETTINGS" <<EOF
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>${NEXUS_USR}</username>
      <password>${NEXUS_PSW}</password>
    </server>
  </servers>
</settings>
EOF
            echo "Created settings.xml at $MVN_SETTINGS"
          '''
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
        // use Sonar token from Jenkins secret text credential
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
          // using the workspace settings.xml (created earlier) so server id 'nexus' is resolved
          def warFile = "target/wwp-${PROJECT_VERSION}.war"
          sh """
            if [ ! -f "${warFile}" ]; then
              echo "ERROR: ${warFile} not found"
              exit 1
            fi

            mvn -s "${MVN_SETTINGS}" deploy:deploy-file \
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
            // use --upload-file and add update=true so it updates if exists
            sh """
              if [ ! -f "${warFile}" ]; then
                echo "ERROR: ${warFile} not found"
                exit 1
              fi

              curl -v --fail --show-error \
                --upload-file "${warFile}" \
                "http://${TOMCAT_USR}:${TOMCAT_PSW}@${TOMCAT_HOST.replace('http://','')}/manager/text/deploy?path=/wwp&update=true"
            """
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      agent { label 'docker' }   // this stage must run on a node with Docker installed
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            def tag = "${DOCKER_USER}/${IMAGE_NAME}:${PROJECT_VERSION}"
            // Create a minimal Dockerfile pointing to the correct WAR filename
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

  } // stages

  post {
    always {
      echo "Pipeline finished at: ${new Date()}"
      archiveArtifacts artifacts: "target/wwp-${PROJECT_VERSION}.war", onlyIfSuccessful: false, allowEmptyArchive: true
    }
    success {
      echo "✔ Pipeline succeeded: version ${env.PROJECT_VERSION}"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
