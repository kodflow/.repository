# Task Runner

Exécute les tâches du projet de manière séquentielle ou parallèle.

## Argument

$ARGUMENTS

- Sans argument : exécute la prochaine tâche prête
- Avec ID : exécute la tâche spécifique
- `--all` : exécute toutes les tâches prêtes de la phase courante
- `--phase N` : exécute toutes les tâches de la phase N

---

## Instructions

### 1. Identifier les tâches à exécuter

```bash
# Tâches prêtes (non bloquées, pending)
task project:$PROJECT +claude +UNBLOCKED +PENDING list
```

### 2. Pour chaque tâche

1. **Lire les détails** :
   ```bash
   task <ID> info
   ```

2. **Extraire les métadonnées** :
   - `model:` → Modèle à utiliser
   - `agent:` → Agent spécifique (si défini)
   - `parallel:` → Peut être parallélisé
   - Annotations → Actions détaillées

3. **Marquer comme en cours** :
   ```bash
   task <ID> start
   ```

4. **Exécuter la tâche** selon les instructions dans les annotations

5. **Marquer comme terminée** :
   ```bash
   task <ID> done
   ```

   Ou en cas d'échec, annoter l'erreur :
   ```bash
   task <ID> annotate "ERREUR: <description>"
   task <ID> stop
   ```

### 3. Gestion de la parallélisation

Si plusieurs tâches ont `parallel:yes` et la même `phase:N` :
- Utilise le **Task tool** pour lancer des agents en parallèle
- Chaque agent traite une tâche
- Attend la complétion de tous avant de passer à la phase suivante

### 4. Reprise après crash

En cas de reprise :
1. Chercher les tâches `+ACTIVE` (en cours) :
   ```bash
   task +ACTIVE list
   ```
2. Analyser où on en était
3. Reprendre ou recommencer la tâche

---

## Flow d'exécution

```
┌─────────────────────────────────────┐
│  Lister tâches +UNBLOCKED +PENDING  │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  Grouper par phase                  │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  Phase N : parallel:yes ?           │
│  ├─ Oui → Lancer agents parallèles  │
│  └─ Non → Exécuter séquentiellement │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  Attendre complétion phase N        │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│  Passer à phase N+1                 │
└─────────────────────────────────────┘
```

---

## Rapport de fin

```
## Exécution terminée

### Résumé
- Tâches exécutées : X
- Succès : Y
- Échecs : Z
- Temps total : T

### Détails
| ID | Tâche | Status | Durée |
|----|-------|--------|-------|
```
