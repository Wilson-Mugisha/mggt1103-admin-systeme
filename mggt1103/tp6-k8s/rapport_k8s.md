# MGGT1103 — Rapport Séance 6 : Orchestration Kubernetes (K3s via k3d)

## Architecture déployée

- Cluster k3d local (`mggt-cluster`) avec 1 nœud control-plane
- Deployment `serveur-web-app` : 3 réplicas Nginx (`nginx:alpine`)
- Service `service-web-interne` : load-balancing interne (ClusterIP)
- Ingress `ingress-public` (Traefik) : exposition vers l'extérieur

⚠️ Note : le port 8080 étant déjà utilisé par le conteneur `ggt-api` du TP5
(docker-compose toujours actif), le cluster a été créé avec une redirection
sur le port **8888** au lieu de 8080 :
`k3d cluster create mggt-cluster -p "8888:80@loadbalancer"`
L'application est donc accessible via `http://localhost:8888`.

## Résultat de `kubectl get all`

Voir capture d'écran : `capture_get_all_tp6.png`

## Pourquoi utiliser un Service plutôt que l'IP directe d'un Pod ?

Les Pods sont éphémères : leur adresse IP change à chaque fois qu'ils sont
recréés (crash, mise à jour, auto-healing). Un Service fournit une adresse
IP fixe et stable qui reste valide quel que soit le nombre de Pods créés ou
détruits derrière elle. Il assure aussi le load-balancing automatique du
trafic entre tous les Pods correspondant à son sélecteur, évitant de devoir
suivre manuellement quelle IP de Pod est actuellement valide.

## Commande pour passer de 3 à 10 réplicas

\`\`\`bash
kubectl scale deployment serveur-web-app --replicas=10
\`\`\`

## Preuve d'Auto-Healing

Un Pod (`serveur-web-app-58f85f5bf8-4g54j`) a été supprimé manuellement via
`kubectl delete pod`. Kubernetes a immédiatement recréé un nouveau Pod
(`serveur-web-app-58f85f5bf8-gn8sr`) pour maintenir les 3 réplicas exigés
par le Deployment, démontrant la capacité d'auto-guérison du système.
