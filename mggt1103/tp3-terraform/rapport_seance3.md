# Rapport du TP n-3

# 1. La différence entre l'approche déclarative et l'approche impérative de l'IaC

L'approche impérative consiste à décrire étape par étape les actions que l'ordinateur doit exécuter pour créer une infrastructure. À l'inverse, l'approche déclarative consiste à décrire uniquement l'état final souhaité de l'infrastructure, sans préciser les étapes nécessaires pour y parvenir. L'outil d'IaC, comme Terraform, se charge ensuite de déterminer automatiquement les opérations à effectuer pour atteindre cet état. Cette approche est généralement plus simple, plus fiable et plus facile à maintenir.

# 2. Capture d'ecran du terminal

![Résultat de terraform apply](capture_apply.png)

# 3. Pourquoi est-il extrêmement dangereux d'envoyer le fichier terraform.tfstate sur un dépôt public ?

Le fichier terraform.tfstate contient l'état complet de l'infrastructure gérée par Terraform. Il peut renfermer des informations très sensibles telles que les adresses IP des serveurs, les identifiants des ressources cloud, les noms des bases de données, ainsi que des secrets ou des clés d'accès si ceux-ci ne sont pas correctement protégés. Si ce fichier est publié sur un dépôt GitHub public, une personne malveillante pourrait récupérer ces informations pour accéder à l'infrastructure, compromettre des services ou lancer des attaques. C'est pourquoi il est recommandé de ne jamais versionner ce fichier dans un dépôt public et de l'ajouter au fichier .gitignore afin d'empêcher son envoi accidentel.

## TP 3.3 : Orchestration de l'Hyperviseur VirtualBox avec Terraform

### Problème rencontré

Lors de la première tentative de déploiement avec le provider officiel `shekeriev/virtualbox`
(v0.0.4), Terraform échouait systématiquement après environ 1m30 avec l'erreur suivante :

**Diagnostic effectué :**
- Vérification via `VBoxManage list vms` : la VM n'apparaissait dans aucune liste de
  machines enregistrées.
- Vérification du registre XML de VirtualBox (`VirtualBox.xml`) : aucune entrée
  résiduelle correspondant à la VM.
- Activation des logs détaillés (`TF_LOG=DEBUG`) : le provider tentait de créer la
  machine une seconde fois avant que la première tentative n'ait terminé son
  initialisation, provoquant un conflit interne suivi d'un rollback (suppression
  automatique de la VM par Terraform après l'échec).

**Cause identifiée :** le provider `shekeriev/virtualbox` n'est plus maintenu depuis
2018-2019 et présente un bug de synchronisation connu avec les versions récentes de
VirtualBox (6.1.x), notamment autour de la gestion des délais (`delay`/`mintimeout`)
lors de l'appel à l'API SOAP de `vboxwebsrv`.

### Solution retenue : contournement via `local-exec`

Plutôt que de dépendre d'un provider tiers fragile, l'infrastructure a été redéfinie
en confiant l'orchestration à Terraform via un `null_resource` couplé à des
provisioners `local-exec`, qui pilotent directement l'outil natif `VBoxManage`
(l'interface en ligne de commande officielle d'Oracle VirtualBox).

Cette approche reste pleinement conforme aux principes de l'Infrastructure-as-Code :
- **Déclarativité côté Terraform** : la ressource, ses dépendances et son cycle de
  vie (création/destruction) restent définis et gérés par Terraform.
- **Idempotence contrôlée** via les `triggers`.
- **Automatisation complète** : clonage d'une VM Ubuntu existante, configuration des
  ressources (CPU, RAM), configuration réseau en mode Host-Only, puis démarrage en
  mode headless — le tout sans aucune intervention manuelle.
- **Nettoyage automatique** au `terraform destroy` (extinction puis suppression de
  la VM), via un provisioner `when = destroy`.

### Résultat

La machine virtuelle **Serveur-Automatique-GGT** a été créée, configurée et démarrée
automatiquement, confirmant l'atteinte de l'objectif pédagogique du TP malgré la
défaillance du provider tiers d'origine.


