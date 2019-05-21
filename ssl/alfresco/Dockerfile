ARG ALFRESCO_TAG
FROM alfresco/alfresco-content-repository:${ALFRESCO_TAG}

USER root

ARG TOMCAT_DIR=/usr/local/tomcat
ARG ALF_DATA_DIR=${TOMCAT_DIR}/alf_data

# Copy generated keystore to Image
COPY keystore ${ALF_DATA_DIR}/keystore

# Add here configurations for alfresco-global.properties
RUN echo -e '\n\
encryption.ssl.keystore.location=/usr/local/tomcat/alf_data/keystore/repository.p12\n\
encryption.ssl.keystore.keyMetaData.location=/usr/local/tomcat/alf_data/keystore/ssl-keystore-passwords.properties\n\
encryption.ssl.keystore.type=PKCS12\n\
encryption.ssl.truststore.location=/usr/local/tomcat/alf_data/keystore/ssl.truststore\n\
encryption.ssl.truststore.keyMetaData.location=/usr/local/tomcat/alf_data/keystore/ssl-truststore-passwords.properties\n\
encryption.ssl.truststore.type=JKS\n\
' >> ${TOMCAT_DIR}/shared/classes/alfresco-global.properties

### Enable SSL by adding the proper Connector to server.xml
RUN sed -i "s/\
    <\/Engine>/\n\
    <\/Engine>\n\
    <Connector port=\"8443\" protocol=\"org.apache.coyote.http11.Http11Protocol\"\n\
          SSLEnabled=\"true\" maxThreads=\"150\" scheme=\"https\"\n\
          keystoreFile=\"\/usr\/local\/tomcat\/alf_data\/keystore\/repository.p12\"\n\
          keystorePass=\"kT9X6oe68t\" keystoreType=\"PKCS12\" secure=\"true\" connectionTimeout=\"240000\"\n\
          truststoreFile=\"\/usr\/local\/tomcat\/alf_data\/keystore\/ssl.truststore\"\n\
          truststorePass=\"kT9X6oe68t\" truststoreType=\"JKS\" clientAuth=\"want\" sslProtocol=\"TLS\">\n\
      <\/Connector>/g" ${TOMCAT_DIR}/conf/server.xml

RUN rm /usr/local/tomcat/webapps/alfresco/WEB-INF/lib/alfresco-core-*.jar
COPY alfresco-core-*.jar /usr/local/tomcat/webapps/alfresco/WEB-INF/lib/
