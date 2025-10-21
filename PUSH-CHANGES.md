# 🚀 Instructions pour pousser les changements

## ✅ Changements effectués

1. **Suppression du champ `recipient`** dans `contactpoints.yaml`
   - Slack utilise maintenant les webhooks (pas l'API)
   - Le canal est configuré dans l'URL du webhook

2. **Configuration unifiée des datasources** dans `datasources.yaml`

## 📝 Commandes Git à exécuter

### Sur Windows (Git Bash ou PowerShell avec git.exe)

```bash
cd "d:\Data2AI Academy\Grafana"

# Vérifier les changements
git status

# Ajouter tous les fichiers modifiés
git add .

# Commiter (utilisez Git Bash ou l'interface graphique)
git commit -m "Fix Slack webhooks configuration"

# Pousser vers GitHub
git push origin main
```

### Alternative : Utiliser l'interface Git de VS Code

1. **Ouvrir le panneau Source Control** (Ctrl+Shift+G)
2. **Voir les fichiers modifiés** :
   - `contactpoints.yaml`
   - `datasources.yaml`
   - `grafana.ini`
   - `GIT-SYNC-FIX.md`
3. **Écrire un message de commit** : "Fix Slack webhooks and datasources config"
4. **Cliquer sur Commit**
5. **Cliquer sur Push**

## 🔄 Sur le serveur Ubuntu

Après avoir poussé les changements :

```bash
cd ~/Grafana-Stack

# Sauvegarder le fichier local si nécessaire
sudo cp observability-stack/grafana/provisioning/datasources/datasources.yaml \
        observability-stack/grafana/provisioning/datasources/datasources.yaml.backup 2>/dev/null || true

# Supprimer le fichier non tracké
sudo rm -f observability-stack/grafana/provisioning/datasources/datasources.yaml

# Pull les changements
sudo git pull origin main

# Supprimer les anciens fichiers de datasources
sudo rm -f observability-stack/grafana/provisioning/datasources/prometheus-datasource.yaml
sudo rm -f observability-stack/grafana/provisioning/datasources/mssql.yml

# Redémarrer Grafana
cd observability-stack
sudo docker-compose restart grafana

# Vérifier les logs
sudo docker logs grafana 2>&1 | tail -50
```

## ✅ Vérification

Après redémarrage, vous devriez voir :

```
✅ Provisioned datasource: Prometheus
✅ Provisioned datasource: MS SQL Server - E-Banking
✅ Contact point provisioned: slack-notifications
✅ Contact point provisioned: email-notifications
✅ Contact point provisioned: critical-alerts
```

Sans erreurs !

## 🔧 Si vous avez encore des erreurs

### Erreur : "token must be specified"
➡️ Le champ `recipient` est encore présent. Vérifiez que le pull a bien mis à jour le fichier.

### Erreur : "datasource already exists"
➡️ Supprimez les anciens fichiers `prometheus-datasource.yaml` et `mssql.yml`

### Erreur : "database is locked"
➡️ Attendez quelques secondes et redémarrez Grafana
