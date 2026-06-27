#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE SAUVEGARDE AUTOMATISÉE ET DURCIE - PRODUCTION
# Auteur : Master GGT - UE
# ==============================================================================

# 💡 NOTE PÉDAGOGIQUE : Le Mode strict de Bash (Defensive coding)
# -e  : Arrête immédiatement le script si une commande échoue (évite l'effet domino).
# -u  : Arrête le script si vous tentez d'utiliser une variable vide ou non définie.
# -o pipefail : Assure que les erreurs survenues dans un pipeline (|) soient détectées.
set -euo pipefail

# Définition des variables de configuration (ReadOnly = Constantes)
readonly BACKUP_DIR="/var/backups/system_configs"
readonly LOG_TAG="BACKUP_ENGINE"
readonly DATE_STR=$(date +'%Y-%m-%d_%H-%M-%S')
readonly OUTPUT_FILE="${BACKUP_DIR}/etc_backup_${DATE_STR}.tar.gz"
readonly IP_INFO_FILE="${BACKUP_DIR}/network_ip_config_${DATE_STR}.txt"

# Fonction d'affichage et de journalisation des informations standard
log_info() {
    # Envoie le message directement dans les logs système (journalctl)
    logger -t "${LOG_TAG}" "[INFO] $1"
    # Affiche le message en vert dans votre console
    echo -e "\e[32m[INFO]\e[0m $1"
}

# Fonction d'affichage et de journalisation des erreurs critiques
log_error() {
    logger -t "${LOG_TAG}" -p user.err "[ERROR] $1"
    # Affiche le message en rouge dans la console d'erreur
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# 💡 NOTE PÉDAGOGIQUE : La gestion des signaux (Le Trap)
# La fonction "cleanup_on_failure" s'exécutera automatiquement si le script s'arrête
# brutalement suite à une erreur. C'est votre ceinture de sécurité !
cleanup_on_failure() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Le script a échoué prématurément à l'étape précédente avec le code d'erreur $exit_code. Nettoyage..."
        # Suppression des fichiers incomplets ou corrompus
        rm -f "${OUTPUT_FILE}" "${IP_INFO_FILE}"
    fi
}
trap cleanup_on_failure EXIT

# --- DÉBUT DES OPÉRATIONS ---
log_info "Démarrage de la sauvegarde de l'infrastructure..."

# 1. Vérification des droits d'exécution (Le script doit être lancé en ROOT)
if [ "${EUID}" -ne 0 ]; then
    log_error "Ce script de sauvegarde doit impérativement être exécuté en tant que ROOT (Sudo)."
    exit 1
fi

# 2. Création sécurisée du dossier de sauvegarde s'il n'existe pas
if [ ! -d "${BACKUP_DIR}" ]; then
    log_info "Création du répertoire de sauvegarde ${BACKUP_DIR}..."
    mkdir -p "${BACKUP_DIR}"
    # Sécurisation du dossier : Seul root peut lire et écrire à l'intérieur (chmod 700)
    chmod 700 "${BACKUP_DIR}"
fi

# 3. Sauvegarde de l'état réseau (Spécifique GGT)
log_info "Sauvegarde de la configuration IP et de la table de routage..."
{
    echo "=== ADRESSAGE IP ET INTERFACES ==="
    ip -br addr show
    echo -e "\n=== TABLE DE ROUTAGE IPV4 ==="
    ip route show
    echo -e "\n=== TABLE DE ROUTAGE IPV6 ==="
    ip -6 route show
} > "${IP_INFO_FILE}"
# Seul root a le droit d'accéder à ce fichier d'informations
chmod 600 "${IP_INFO_FILE}"

# 4. Compression des configurations système (/etc)
log_info "Compression des fichiers de configuration réseau et système (/etc)..."
# tar -czf crée un fichier archive compressé au format .tar.gz
tar -czf "${OUTPUT_FILE}" /etc 2>/dev/null

log_info "Sauvegarde réussie avec succès !"
log_info "Archive générée : ${OUTPUT_FILE}"
log_info "Fichier d'état IP généré : ${IP_INFO_FILE}"
# --- FIN DES OPÉRATIONS ---
