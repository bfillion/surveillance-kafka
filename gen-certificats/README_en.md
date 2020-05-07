# How to update the self-signed certificates with the desired values
## Create the SSL Docker-Composer
- Create the SSL Docker-Composes SSL by executing the following command located under the SSL directory:
```bash
		./build-Docker-Compose.sh
```

## Configuring Settings to create certificates
- From Windows Explorer, 
  - Delete the contents of the "certificates" directory
  - Copy the file gen-certificates.sh, which is located under the gen-certificates directory, into the "certificates" directory.
  - Open the file gen-certificates.sh with Notepad++, and modify, if necessary, the values of the following parameters:

### Password configuration
- Enter the desired password:
```bash
		PASSWORD=Fournir le mot de passe
```

### Certificat definition: "/CN=commonName/OU=organizationalUnit/O=organizationName/L=localityName/C=country"
- Provide the desired definition of the certificate 
```bash
		BROKERCN=CoEInt.kafka-ia-broker
		BROKER1CN=CoEInt.kafka-ia-broker1
		PRODUCERCN=CoEInt.kafka-ia-producer
		CONSUMERCN=CoEInt.kafka-ia-consumer
		SUBJOU=CoEInt.kafka-ia-TEST
		SUBJO=IA
		SUBJL=Quebec
		SUBJC=CA
		NBOFDAYS=9999
```

## Certificates creation
- From the Docker Desktop Dashboard, open the Kafka server Cli command window: CoEInt.kafka-ia-broker1
- Change the directory by executing the following command:
```bash
		cd /etc/kafka/secrets
```

- Execute this command to remove CR (carriages returns) (ref: https://askubuntu.com/questions/304999/not-able-to-execute-a-sh-file-bin-bashm-bad-interpreter)
```bash
		sed -i -e 's/\r$//' gen-certificats.sh
```

- Run the gen-certificates.sh command to generate the certificates:
```bash
/bin/bash ./gen-certificats.sh
```
- Confirm the creation of the self-created certificate by executing the following command:
```bash
		openssl x509 -in kafka-ia-ca.crt -noout -text

```

## Recreate the SSL Docker-Composite with the new certificates
- From the Dashbord Docker Station or from Visual Code, delete the Docker-Compose SSL
- Recreate the Docker-Composes by executing the following command located under the SSL directory: 
```bash
		./build-Docker-Compose.sh
```
