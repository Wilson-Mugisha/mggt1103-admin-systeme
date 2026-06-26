# Rapport de Hardening et Sécurisation du Système Linux

## 1. Introduction

Dans ce travail pratique, nous avons effectué une analyse de sécurité du système à l’aide de l’outil Lynis, 
puis appliqué plusieurs mesures de durcissement (hardening) afin d’améliorer la sécurité globale du système Linux.
## 2. Le score initial obtenu avec Lynis
![Hardening Index Lynis](capture_lynis.png)
## 3. 3 recommandations corrigees
 
### 1. Durcissement de la configuration SSH
J'ai modifié le fichier /etc/ssh/sshd_config afin de renforcer la sécurité du serveur SSH, en configurant ces paramètres :
PermitRootLogin no : qui interdit la connexion directe de l'utilisateur root
PasswordAuthentication no : qui désactive l'authentification par mot de passe afin de privilégier l'authentification par clé 
X11Forwarding no : qui désactive le transfert X11 pour réduire la surface d'attaque. 
MaxAuthTries 3 : qui limite le nombre de tentatives d'authentification à trois pour réduire les risques d'attaque par force brute. 
Après modification, la configuration a été validée avec sudo sshd -t puis appliquée en redémarrant le service SSH.
### commandes utilisees
sudo nano /etc/ssh/sshd_config : pour modifier ces parametres un à un
sudo sshd -t: Pour valider la configuration
sudo systemctl restart ssh: Pour redemarrer les services

### 2. Installation de Fail2Ban :
J'ai installé l'outil Fail2Ban afin de renforcer la sécurité du serveur. Ce logiciel nous aide à surveille les journaux d'authentification et bloque automatiquement les adresses IP qui effectuent plusieurs tentatives de connexion échouées. Il protège ainsi le serveur contre les attaques par force brute, notamment sur le service SSH.
### les commandes utilisees
sudo apt update : actualise les mise à jour disponibles
sudo apt install -y fail2ban : pour installer fail2ban
sudo systemctl enable --now fail2ban : pour demarrer les services
sudo systemctl status fail2ban : Pour verifier qu’il fonctionne bien

### 3. Activation du service sysstat
Le service Sysstat collecte régulièrement les statistiques de performance du système (CPU, mémoire, disque et réseau). Il permet d'analyser l'évolution des performances et d'identifier plus facilement les problèmes.
### commande utilisee
sudo systemctl enable --now sysstat : pour l’activer

## 4. Différence entre SIGTERM et SIGKILL

Différence entre SIGTERM (15) et SIGKILL (9)

Les signaux SIGTERM (15) et SIGKILL (9) servent tous les deux à arrêter un processus, mais ils ne fonctionnent pas de la même manière.

Le signal **SIGTERM (15)** demande au processus de s'arrêter proprement. Le programme reçoit le signal, peut fermer ses fichiers, enregistrer ses données et effectuer les opérations de nettoyage nécessaires avant de se terminer. Ce signal peut être intercepté ou ignoré par le processus.

Le signal **SIGKILL (9)** force l'arrêt immédiat du processus. Le système met fin au processus sans lui laisser le temps d'effectuer un nettoyage ou de sauvegarder son travail. Contrairement à SIGTERM, ce signal ne peut ni être intercepté ni ignoré.

## 5. Limitation ajoutée dans le fichier limits.conf

Le fichier `/etc/security/limits.conf` permet de définir des limites sur les ressources que les utilisateurs peuvent consommer. Cette limitation améliore la stabilité et la sécurité du serveur en réduisant les risques de surcharge ou d'abus.
