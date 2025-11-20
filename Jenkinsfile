pipeline {
    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    environment {

        SONAR_HOST_URL = "http://54.153.103.78:9000"
        SONAR_TOKEN = "squ_9615680f597c6da567dd69cd90212315f0583955"

        NEXUS_URL = "http://54.153.103.78:8081"
        NEXUS_REPO = "maven-releases"
        NEXUS_GROUP = "com.webapp"

        TOMCAT_HOST = "http://54.153.103.78:9090"
        TOMCAT_USER = "admin"
        TOMCAT_PASS = "admin"

        DOCKERHUB_USER = "rishi01dadireddy"
        DOCKERHUB_PASS = "dckr_pat_o1ajuSqVuSp-p_qW5xwvF8GDcp0"
        IMAGE_NAME = "tomcat-wwp"
        IMAGE_VERSION = "1.0.1"

        MVN_SETTINGS = "/etc/maven/settings.xml"
    }

    stages {

        /* -----------------------------
         * SETUP MAVEN SETTINGS.XML
         * ----------------------------- */
        stage("Setup Maven Settings") {
            steps {
                sh """
                mkdir -p /etc/maven

                cat > /etc/maven/settings.xml <<EOF
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>admin</password>
    </server>
  </servers>
</settings>
EOF
                """
            }
        }

        /* -----------------------------
         * CHECKOUT CODE
         * ----------------------------- */
        stage('Checkout') {
            steps {
                git branch: 'master',
