# Generation Tool for custom SSL Certificates

This `run.sh` script generates certificates for Repository and SOLR SSL Communication:

* CA Entity to issue all required certificates (alias alfresco.ca)
* Server Certificate for Alfresco (alias ssl.repo)
* Server Certificate for SOLR (alias ssl.repo.client)

Sample `openssl.cnf` file is provided for CA Configuration.

## Execution

```bash
$ cd ssl-tool
$ ./run.sh
```

## Deployment

Once this script has been executed successfully, following resources are generated in ${KEYSTORES_DIR} folder:

```
keystores
├── alfresco
│   ├── repository.p12
│   ├── ssl-keystore-passwords.properties
│   ├── ssl-truststore-passwords.properties
│   └── ssl.truststore
├── solr
│   ├── solr.p12
│   ├── ssl-keystore-passwords.properties
│   ├── ssl-truststore-passwords.properties
│   └── ssl.repo.client.truststore
└── zeppelin
    ├── solr.p12
    └── ssl.repo.client.truststore
```

* `alfresco` files must be copied to "alfresco/keystore" folder in Docker Compose template project (any existing file must be overwritten)
* `solr` files must be copied to "solr6/keystore" folder in Docker Compose template project (any existing file must be overwritten)
* `zeppelin` files must be copied to "zeppelin/keystore" folder in Docker Compose template project (any existing file must be overwritten)

## Dependencies

* **openssl** version (LibreSSL 2.6.5)
* **keytool** from openjdk version "11.0.2"
