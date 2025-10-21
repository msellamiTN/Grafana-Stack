# 🔧 Fix: Git Pull Error - Untracked Files Conflict

## ❌ Erreur
```bash
error: The following untracked working tree files would be overwritten by merge:
    observability-stack/grafana/provisioning/datasources/datasources.yaml
Please move or remove them before you merge.
```

## 🔍 Cause
Le fichier `datasources.yaml` existe localement sur le serveur mais n'est pas tracké par git. 
Git refuse de le remplacer pour éviter de perdre vos modifications.

## ✅ Solution

### Option 1 : Sauvegarder puis pull (Recommandé)

```bash
# 1. Sauvegarder le fichier local
sudo cp observability-stack/grafana/provisioning/datasources/datasources.yaml \
        observability-stack/grafana/provisioning/datasources/datasources.yaml.backup

# 2. Supprimer le fichier non tracké
sudo rm observability-stack/grafana/provisioning/datasources/datasources.yaml

# 3. Pull les changements
sudo git pull origin main

# 4. Comparer les fichiers si nécessaire
diff observability-stack/grafana/provisioning/datasources/datasources.yaml \
     observability-stack/grafana/provisioning/datasources/datasources.yaml.backup
```

### Option 2 : Force overwrite (Attention : perte de modifications locales)

```bash
# Forcer git à écraser les fichiers locaux
sudo git fetch origin main
sudo git reset --hard origin/main
```

### Option 3 : Stash puis pull

```bash
# 1. Ajouter le fichier au staging
sudo git add observability-stack/grafana/provisioning/datasources/datasources.yaml

# 2. Stash les changements
sudo git stash

# 3. Pull
sudo git pull origin main

# 4. Appliquer le stash (si vous voulez garder vos modifications)
sudo git stash pop
```

## 🎯 Commandes à exécuter (Option 1 - Recommandée)

```bash
cd ~/Grafana-Stack

# Sauvegarder
sudo cp observability-stack/grafana/provisioning/datasources/datasources.yaml \
        observability-stack/grafana/provisioning/datasources/datasources.yaml.backup

# Supprimer
sudo rm observability-stack/grafana/provisioning/datasources/datasources.yaml

# Pull
sudo git pull origin main

# Vérifier
ls -la observability-stack/grafana/provisioning/datasources/
```

## 📝 Après le pull

1. **Vérifier le contenu du nouveau fichier** :
   ```bash
   cat observability-stack/grafana/provisioning/datasources/datasources.yaml
   ```

2. **Comparer avec votre backup** :
   ```bash
   diff observability-stack/grafana/provisioning/datasources/datasources.yaml \
        observability-stack/grafana/provisioning/datasources/datasources.yaml.backup
   ```

3. **Si besoin, fusionner manuellement** les configurations importantes de votre backup

4. **Redémarrer Grafana** :
   ```bash
   cd ~/Grafana-Stack/observability-stack
   sudo docker-compose restart grafana
   ```

## ⚠️ Important

Après le pull, vous devrez peut-être :
- Supprimer les anciens fichiers `prometheus-datasource.yaml` et `mssql.yml` si ils reviennent
- Vérifier que `datasources.yaml` contient bien les 2 datasources (Prometheus + MSSQL)
- Configurer les variables d'environnement si nécessaire

## 🔍 Vérification finale

```bash
# Vérifier qu'il n'y a qu'un seul fichier de datasources
ls -la observability-stack/grafana/provisioning/datasources/

# Devrait montrer uniquement :
# - datasources.yaml
# - datasources.yaml.backup (votre sauvegarde)
# - README-FIX.md (documentation)
```
