# Sample configuration for TLS/SSL Mutual Auth

This project includes default configuration for ACS Enterprise 6.1, Insight Engine 1.1 and Zeppelin using Mutual TLS communication between Repository and SOLR

Every *truststores*, *keystores* and *certificates* are generated using the `ssl-tool`:

* *keystores* are using PKCS12 format
* *truststores* are using JKS format


## Running Docker Compose

Docker can be started selecting SSL Docker Compose file.

```bash
$ cd ssl
$ docker-compose up --build
```

Alfresco will be available at:

http://localhost:8080/alfresco

https://localhost:8443/alfresco

http://localhost:8080/share

https://localhost:8083/solr

http://localhost:9090/zeppelin

SSL Communication from SOLR and Zeppelin (JDBC Driver) is targeted inside Docker Network to https://alfresco:8443/alfresco


**Warning**

Current configuration is running with a patched `alfresco-core-7.10.jar` and with a patched `Insight Engine` release (!)

* https://github.com/Alfresco/alfresco-core/tree/fix/SEARCH-1657_ACSOverSSL

* https://git.alfresco.com/search_discovery/InsightEngine/tree/fix/SEARCH-1657_ACSOverSSL


## Generation Tool for custom SSL Certificates

A simple Script has been included in `ssl-tool` folder in order to generate custom *truststores*, *keystores* and *certificates*.

## Additional test cases

* Plain HTTP Configuration is available at `http` folder
* Plain HTTP Configuration with Sharding available at `http-sharding` folder
* Default SSL Configuration (using out-of-the-box truststore and keystore) is available at `ssl-default` folder
* Default SSL Configuration with Sharding (using out-of-the-box truststore and keystore) is available at `ssl-sharding` folder
