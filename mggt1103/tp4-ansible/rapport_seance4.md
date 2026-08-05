# MGGT1103 — Rapport Séance 4 : Gestion de Configuration et Sécurisation avec Ansible

## Architecture retenue

- **Machine de contrôle** : WSL2 (Ubuntu), Ansible 2.10.8
- **Machine cible** : conteneur Docker Ubuntu 22.04 avec serveur SSH
  (adresse IP du réseau bridge Docker : 172.17.0.2)

## Problème rencontré : incompatibilité VirtualBox / Hyper-V (WSL2)

La machine cible initialement prévue était une VM VirtualBox (`VM-Ubuntu-Mggt1103`,
gérée via Vagrant), conformément à l'architecture suggérée par le guide de TP.

Cette VM refusait de démarrer, avec plusieurs symptômes successifs :
- Erreur `VERR_SSM_UNSUPPORTED_DATA_UNIT_VERSION` au premier démarrage
- Connexions SSH interrompues brutalement (`Connection reset`)
- Timeout de démarrage (`Timed out while waiting for the machine to boot`)

**Diagnostic effectué :**
1. Inspection des logs VirtualBox (`VBox.log`) : la ligne
   `HMR3Init: Attempting fall back to NEM: VT-x is not available` a révélé que
   VirtualBox ne pouvait pas accéder directement au processeur (VT-x), cet accès
   étant réservé à Hyper-V (utilisé par WSL2).
2. Activation de la fonctionnalité Windows "Windows Hypervisor Platform"
   (`Get-WindowsOptionalFeature` la montrait désactivée), qui permet à VirtualBox
   de fonctionner en mode d'émulation logicielle (NEM) aux côtés de Hyper-V.
3. Après redémarrage et réactivation, une nouvelle erreur est apparue au boot :
   `MsrExit/0: RDMSR c0011029 -> 00000000 / VERR_CPUM_RAISE_GP_0`.
4. Une recherche a confirmé qu'il s'agit d'un **bug connu et documenté** du
   couple VirtualBox + Hyper-V/WSL2 (ticket officiel VirtualBox #20254 et
   plusieurs fils de discussion communautaires), sans correctif fiable qui
   préserve à la fois VirtualBox et WSL2 sur certains processeurs Intel.

## Solution retenue : conteneur Docker comme machine cible

Plutôt que de désactiver WSL2 (nécessaire pour le reste du cours) ou de
poursuivre une réparation incertaine, la machine cible a été remplacée par un
**conteneur Docker** exécutant Ubuntu 22.04 avec un serveur SSH configuré :

- Image construite via un `Dockerfile` dédié (installation d'OpenSSH,
  configuration de l'authentification par clé publique).
- Le conteneur obtient sa propre adresse IP sur le réseau bridge Docker
  (172.17.0.2), permettant de respecter l'esprit du TP (cible réseau distincte,
  testable via `curl http://IP`).
- Docker s'appuie sur les espaces de noms du noyau Linux (namespaces) plutôt
  que sur la virtualisation matérielle complète, ce qui l'affranchit totalement
  du conflit VT-x/Hyper-V rencontré avec VirtualBox.

## Adaptation du Playbook

La tâche de pare-feu (`ufw`) a été retirée du playbook `deploy_web.yml` : les
conteneurs Docker standards n'ont pas accès en écriture aux tables `iptables`
du noyau hôte (erreur `Permission denied` même en tant que root dans le
conteneur), ce qui est une restriction de sécurité normale de l'isolation
Docker plutôt qu'un défaut de configuration Ansible.

## Résultats obtenus

- `ansible serveurs_web -i hosts -m ping` → `"ping": "pong"`
- `ansible-playbook -i hosts deploy_web.yml` → `failed=0`, Nginx déployé et démarré
- Idempotence vérifiée : second run → `changed=0`
- `curl http://172.17.0.2` → affiche la page personnalisée du Master GGT
- `secrets.yml` chiffré avec succès via `ansible-vault create` (format AES256)
- `test_vault.yml --ask-vault-pass` → déchiffrement et utilisation réussis du
  secret dans un fichier de configuration protégé sur la cible
