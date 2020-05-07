# Comment mettre à jour les certificats auto-signés avec les valeurs désirées
## Créer le Docker-Compose SSL
- Créer le Docker-Compose SSL en exécutant la commande suivante qui se trouve sous le réppertoire SSL:
```bash
		./build-Docker-Compose.sh
```

## Configuration des paramêtres pour créer les certificats
- À partir de de Windows Explorer, 
  - Suprimer le contenu du répertoire "certificats"
  - Copier le fichier gen-certificats.sh, qui se trouve sous le répertoire gen-certificats, dans le répretoire "certificats
  - Ouvrir le fichier gen-certificats.sh avec Notepad++, et modifier, s'il y a lieu, les valeurs des paramêtres suivants:

### Configuration du mot de passe
- Indiquez le mot de passe souhaité :
```bash
		PASSWORD=Fournir le mot de passe
```

### Définition du certificat: "/CN=commonName/OU=organizationalUnit/O=organizationName/L=localityName/C=country"
- Fournir la définition souhaitée du certificat 
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

## Création des certificats
- À partir du Dashboard de Docker Desktop, ouvrir la fenêtre de commande Cli du serveur Kafka: CoEInt.kafka-ia-broker1
- Changer de répertoire en exécutant la commande suivante:
```bash
		cd /etc/kafka/secrets
```

- Exécuter cette commande pour enlever les CR (carriages returns) (ref: https://askubuntu.com/questions/304999/not-able-to-execute-a-sh-file-bin-bashm-bad-interpreter)
```bash
		sed -i -e 's/\r$//' gen-certificats.sh
```

- Executer la commande gen-certificats.sh pour générer les certificats:
```bash
/bin/bash ./gen-certificats.sh
```
- Valider la création du certificat auto-créé en exécutant le commande suivante:
```bash
		openssl x509 -in kafka-ia-ca.crt -noout -text

```

## Recréer le Docker-Compose SSL avec les nouveaux certificats
- À partir du Dashbord Docker Station ou à partir de Visual Code, supprimer le docker-Compose SSL
- Recréer le Docker-Compose en exécutant la commande suivante qui se trouve sous le réppertoire SSL: 
```bash
		./build-Docker-Compose.sh
```
