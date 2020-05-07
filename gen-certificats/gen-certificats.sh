#!/bin/bash

#Password configuration
#Different store and key passwords not supported for PKCS12 KeyStores, therefore, all passwords need to be the same
PASSWORD=soleil1234
KEYPASSWORD=$PASSWORD
TRUSTSTOREPASSWORD=$PASSWORD
BROKER1KEYSTOREPASSWORD=$PASSWORD
PRODUCERKEYSTOREPASSWORD=$PASSWORD
CONSUMERKEYSTOREPASSWORD=$PASSWORD

# Subject certificate definition "/CN=commonName/OU=organizationalUnit/O=organizationName/L=localityName/C=country"
BROKERCN=CoEInt.kafka-ia-broker
BROKER1CN=CoEInt.kafka-ia-broker1
PRODUCERCN=CoEInt.kafka-ia-producer
CONSUMERCN=CoEInt.kafka-ia-consumer
SUBJOU=CoEInt.kafka-ia-TEST
SUBJO=IA
SUBJL=Quebec
SUBJC=CA
NBOFDAYS=9999

# CA (self signed request for all Brokers, Producer, Consumer certificates)
openssl req -new -x509 -keyout kafka-ia-ca.key -out kafka-ia-ca.crt -days $NBOFDAYS -subj "/CN=$BROKERCN/OU=$SUBJOU/O=$SUBJO/L=$SUBJL/C=$SUBJC" -passin pass:$TRUSTSTOREPASSWORD -passout pass:$KEYPASSWORD

# truststore
keytool -keystore kafka-ia.truststore.jks -alias CARoot -import -file kafka-ia-ca.crt -storepass $TRUSTSTOREPASSWORD -keypass $KEYPASSWORD -trustcacerts -noprompt

# broker certificate and keystore
keytool -genkey -noprompt \
   -alias $BROKER1CN \
   -dname "CN=$BROKER1CN, OU=$SUBJOU, O=$SUBJO, L=$SUBJL, C=$SUBJC" \
   -keystore kafka-ia-broker1.keystore.jks \
   -keyalg RSA \
   -storepass $TRUSTSTOREPASSWORD \
   -keypass $BROKER1KEYSTOREPASSWORD \
   -deststoretype pkcs12

# keytool -importkeystore -srckeystore kafka-ia-broker1.keystore.jks -destkeystore kafka-ia-broker1.keystore.jks -deststoretype pkcs12

keytool -keystore kafka-ia-broker1.keystore.jks -alias $BROKER1CN -certreq -file kafka-ia-broker1.csr -storepass $TRUSTSTOREPASSWORD -keypass $KEYPASSWORD
openssl x509 -req -CA kafka-ia-ca.crt -CAkey kafka-ia-ca.key -in kafka-ia-broker1.csr -out kafka-ia-broker1-signed.crt -days $NBOFDAYS -CAcreateserial -passin pass:$KEYPASSWORD
keytool -keystore kafka-ia-broker1.keystore.jks -alias CARoot -import -file kafka-ia-ca.crt -storepass $TRUSTSTOREPASSWORD -keypass $KEYPASSWORD -trustcacerts -noprompt
keytool -keystore kafka-ia-broker1.keystore.jks -alias $BROKER1CN -import -file kafka-ia-broker1-signed.crt -storepass $TRUSTSTOREPASSWORD -keypass $KEYPASSWORD -trustcacerts -noprompt

#producer certificate and keystore
keytool -genkey -noprompt \
   -alias $PRODUCERCN \
   -dname "CN=$PRODUCERCN, OU=$SUBJOU, O=$SUBJO, L=$SUBJL, C=$SUBJC" \
   -keystore kafka-ia-producer.keystore.jks \
   -keyalg RSA \
   -storepass $TRUSTSTOREPASSWORD \
   -keypass $PRODUCERKEYSTOREPASSWORD \
   -deststoretype pkcs12

keytool -keystore kafka-ia-producer.keystore.jks -alias $PRODUCERCN  -certreq -file kafka-ia-producer.csr -storepass $TRUSTSTOREPASSWORD -keypass $PRODUCERKEYSTOREPASSWORD
openssl x509 -req -CA kafka-ia-ca.crt -CAkey kafka-ia-ca.key -in kafka-ia-producer.csr -out kafka-ia-producer-signed.crt -days $NBOFDAYS -CAserial kafka-ia-ca.srl -passin pass:$KEYPASSWORD
keytool -keystore kafka-ia-producer.keystore.jks -alias CARoot -import -file kafka-ia-ca.crt -storepass $TRUSTSTOREPASSWORD -keypass $PRODUCERKEYSTOREPASSWORD -trustcacerts -noprompt
keytool -keystore kafka-ia-producer.keystore.jks -alias $PRODUCERCN -import -file kafka-ia-producer-signed.crt -storepass $TRUSTSTOREPASSWORD -keypass $PRODUCERKEYSTOREPASSWORD -trustcacerts -noprompt

#consumer certificate and keystore
keytool -genkey -noprompt \
   -alias $CONSUMERCN \
   -dname "CN=$CONSUMERCN, OU=$SUBJOU, O=$SUBJO, L=$SUBJL, C=$SUBJC" \
   -keystore kafka-ia-consumer.keystore.jks \
   -keyalg RSA \
   -storepass $TRUSTSTOREPASSWORD \
   -keypass $CONSUMERKEYSTOREPASSWORD \
   -deststoretype pkcs12
   
keytool -keystore kafka-ia-consumer.keystore.jks -alias $CONSUMERCN  -certreq -file kafka-ia-consumer.csr -storepass $TRUSTSTOREPASSWORD -keypass $CONSUMERKEYSTOREPASSWORD
openssl x509 -req -CA kafka-ia-ca.crt -CAkey kafka-ia-ca.key -in kafka-ia-consumer.csr -out kafka-ia-consumer-signed.crt -days $NBOFDAYS -CAserial kafka-ia-ca.srl -passin pass:$KEYPASSWORD
keytool -keystore kafka-ia-consumer.keystore.jks -alias CARoot -import -file kafka-ia-ca.crt -storepass $TRUSTSTOREPASSWORD -keypass $CONSUMERKEYSTOREPASSWORD -trustcacerts -noprompt
keytool -keystore kafka-ia-consumer.keystore.jks -alias $CONSUMERCN -import -file kafka-ia-consumer-signed.crt -storepass $TRUSTSTOREPASSWORD -keypass $CONSUMERKEYSTOREPASSWORD -trustcacerts -noprompt

echo $TRUSTSTOREPASSWORD > kafka-ia.truststore.cred
echo $KEYPASSWORD > kafka-ia.key.cred
echo $BROKER1KEYSTOREPASSWORD > kafka-ia-broker1.keystore.cred
echo $PRODUCERKEYSTOREPASSWORD > kafka-ia-producer.keystore.cred
echo $CONSUMERKEYSTOREPASSWORD > kafka-ia-consumer.keystore.cred
echo $BROKER1CN> kafka-ia-broker.cn
echo $PRODUCERCN> kafka-ia-producer.cn
echo $CONSUMERCN> kafka-ia-consumer.cn

#Create kafka-ia.properties for Kafdrop
echo security.protocol=SSL > kafka-ia.properties
echo ssl.endpoint.identification.algorithm= >> kafka-ia.properties
echo ssl.protocol=TLS >> kafka-ia.properties
echo ssl.key.password=$KEYPASSWORD >> kafka-ia.properties
echo ssl.keystore.location=/etc/kafka/secrets/kafka-ia-broker1.keystore.jks >> kafka-ia.properties
echo ssl.keystore.password=$BROKER1KEYSTOREPASSWORD >> kafka-ia.properties
echo ssl.keystore.type=PKCS12 >> kafka-ia.properties
echo ssl.truststore.location=/etc/kafka/secrets/kafka-ia.truststore.jks >> kafka-ia.properties
echo ssl.truststore.password=$TRUSTSTOREPASSWORD >> kafka-ia.properties
echo ssl.truststore.type=JKS >> kafka-ia.properties