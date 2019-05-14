ARG ZEPPELIN_TAG
FROM quay.io/alfresco/insight-zeppelin:${ZEPPELIN_TAG}

RUN mkdir ${ZEPPELIN_HOME}/keystore \
 && chown -R zeppelin:zeppelin ${ZEPPELIN_HOME}/keystore
