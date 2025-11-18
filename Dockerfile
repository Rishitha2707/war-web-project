# -------- Stage 1: Downloader --------
FROM eclipse-temurin:17-jre AS downloader
 
ARG NEXUS_URL
ARG GROUP_ID_PATH
ARG APP_NAME
ARG VERSION
ARG NEXUS_USER
ARG NEXUS_PASS
 
# Construct URL correctly using ARG (NOT ENV)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
 
# Build the Nexus path only during RUN (correct ARG expansion)
RUN ARTIFACT_URL="${NEXUS_URL}${GROUP_ID_PATH}/${APP_NAME}/${VERSION}/${APP_NAME}-${VERSION}.war" && \
    echo "Downloading WAR from: ${ARTIFACT_URL}" && \
    curl -u "${NEXUS_USER}:${NEXUS_PASS}" -L "${ARTIFACT_URL}" -o /tmp/app.war
 
