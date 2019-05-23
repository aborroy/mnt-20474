#! /bin/sh

# This script generates certificates for Repository and SOLR SSL Communication:
#
# * CA Entity to issue all required certificates (alias alfresco.ca)
# * Server Certificate for Alfresco (alias ssl.repo)
# * Server Certificate for SOLR (alias ssl.repo.client)
#
# Sample "openssl.cnf" file is provided for CA Configuration.
#
# Once this script has been executed successfully, following resources are generated in ${KEYSTORES_DIR} folder.
#
#
# "alfresco" files must be copied to "alfresco/keystore" folder
# "solr" files must be copied to solr6 "keystore" and zeppelin "keystore"

# Dependencies:
# * openssl version (LibreSSL 2.6.5)
# * keytool from openjdk version "11.0.2"

# PARAMETERS

# Distinguished name of the CA
CA_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Alfresco CA"
# Distinguished name of the Server Certificate for Alfresco
REPO_CERT_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Alfresco Repository"
# Distinguished name of the Server Certificate for SOLR
SOLR_CLIENT_CERT_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Alfresco Repository Client"

# RSA key length
KEY_SIZE=1024

# Default password for every store and key
PASS=kT9X6oe68t

# Folder where keystores, truststores and cerfiticates are generated
KEYSTORES_DIR=keystores
ALFRESCO_KEYSTORES_DIR=keystores/alfresco
SOLR_KEYSTORES_DIR=keystores/solr
ZEPPELIN_KEYSTORES_DIR=keystores/zeppelin

# SCRIPT

# Remove previous working directories and certificates
rm -rf ca
rm -rf ${KEYSTORES_DIR}
rm repository.*
rm solr.*
rm ssl.*

# Create folders for truststores, keystores and certificates
mkdir ${KEYSTORES_DIR}
mkdir ${ALFRESCO_KEYSTORES_DIR}
mkdir ${SOLR_KEYSTORES_DIR}
mkdir ${ZEPPELIN_KEYSTORES_DIR}

# Generate a new CA Entity
mkdir ca

mkdir ca/certs ca/crl ca/newcerts ca/private
chmod 700 ca/private
touch ca/index.txt
echo 1000 > ca/serial

openssl genrsa -aes256 -passout pass:$PASS -out ca/private/ca.key.pem $KEY_SIZE
chmod 400 ca/private/ca.key.pem

openssl req -config openssl.cnf \
      -key ca/private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out ca/certs/ca.cert.pem \
      -subj "$CA_DNAME" \
      -passin pass:$PASS
chmod 444 ca/certs/ca.cert.pem

# Generate Server Certificate for Alfresco (issued by just generated CA)
openssl req -newkey rsa:$KEY_SIZE -nodes -out repository.csr -keyout repository.key -subj "$REPO_CERT_DNAME"
openssl ca -config openssl.cnf -extensions server_cert -passin pass:$PASS -batch -notext -in repository.csr -out repository.cer
openssl pkcs12 -export -out repository.p12 -inkey repository.key -in repository.cer -password pass:$PASS -certfile ca/certs/ca.cert.pem

# Server Certificate for SOLR (issued by just generated CA)
openssl req -newkey rsa:$KEY_SIZE -nodes -out solr.csr -keyout solr.key -subj "$SOLR_CLIENT_CERT_DNAME"
openssl ca -config openssl.cnf -extensions server_cert -passin pass:$PASS -batch -notext -in solr.csr -out solr.cer
openssl pkcs12 -export -out solr.p12 -inkey solr.key -in solr.cer -certfile ca.cer -password pass:$PASS -certfile ca/certs/ca.cert.pem

#
# ALFRESCO
#

# Include CA and SOLR certificates in Alfresco Truststore
keytool -import -trustcacerts -noprompt -alias alfresco.ca -file ca/certs/ca.cert.pem \
-keystore ${ALFRESCO_KEYSTORES_DIR}/ssl.truststore -storetype JKS -storepass $PASS

keytool -importcert -noprompt -alias ssl.repo.client -file solr.cer \
-keystore ${ALFRESCO_KEYSTORES_DIR}/ssl.truststore -storetype JKS -storepass $PASS

# Include Alfresco Certificate in Alfresco Keystore
cp repository.p12 ${ALFRESCO_KEYSTORES_DIR}

# Create Alfresco stores password files
ECHO "aliases=alfresco.ca,ssl.repo.client
keystore.password=$PASS
ssl.repo.client.password=$PASS
alfresco.ca.password=$PASS" > ${ALFRESCO_KEYSTORES_DIR}/ssl-truststore-passwords.properties

ECHO "aliases=1
keystore.password=$PASS
1.password=$PASS" > ${ALFRESCO_KEYSTORES_DIR}/ssl-keystore-passwords.properties

#
# SOLR
#

# Include CA and Alfresco certificates in SOLR Truststore
keytool -import -trustcacerts -noprompt -alias ssl.alfresco.ca -file ca/certs/ca.cert.pem \
-keystore ${SOLR_KEYSTORES_DIR}/ssl.repo.client.truststore -storetype JKS -storepass $PASS

keytool -importcert -noprompt -alias ssl.repo -file repository.cer \
-keystore ${SOLR_KEYSTORES_DIR}/ssl.repo.client.truststore -storetype JKS -storepass $PASS

keytool -importcert -noprompt -alias ssl.repo.client -file solr.cer \
-keystore ${SOLR_KEYSTORES_DIR}/ssl.repo.client.truststore -storetype JKS -storepass $PASS

# Include SOLR Certificate in SOLR Keystore
cp solr.p12 ${SOLR_KEYSTORES_DIR}

# Create SOLR stores password files
ECHO "aliases=alfresco.ca,ssl.repo,ssl.repo.client
keystore.password=$PASS
alfresco.ca.password=$PASS
ssl.repo.password=$PASS
ssl.repo.client.password=$PASS" > ${SOLR_KEYSTORES_DIR}/ssl-truststore-passwords.properties

ECHO "aliases=1
keystore.password=$PASS
1.password=$PASS" > ${SOLR_KEYSTORES_DIR}/ssl-keystore-passwords.properties

#
# Zeppelin
#
cp solr.p12 ${ZEPPELIN_KEYSTORES_DIR}
cp ${SOLR_KEYSTORES_DIR}/ssl.repo.client.truststore ${ZEPPELIN_KEYSTORES_DIR}/ssl.repo.client.truststore
