ARG SEARCH_TAG
# FROM quay.io/alfresco/insight-engine:${SEARCH_TAG}
FROM insightengine:develop

# Configure SOLR cores to run in HTTPs mode from template
RUN sed -i '/^bash.*/i sed -i "'"s/alfresco.secureComms=none/alfresco.secureComms=https/g"'" ${DIST_DIR}/solrhome/templates/rerank/conf/solrcore.properties\n' \
    ${DIST_DIR}/solr/bin/search_config_setup.sh

RUN mkdir ${DIST_DIR}/keystore \
 && chown -R solr:solr ${DIST_DIR}/keystore

VOLUME ["${DIST_DIR}/keystore"]
