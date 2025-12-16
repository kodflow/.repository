# Run - Task Executor

$ARGUMENTS

---

## Mode

**Si `--list`** : Affiche les tâches du projet
```bash
task project:$(basename $PWD) +claude list
task project:$(basename $PWD) +claude +UNBLOCKED +PENDING ready
task project:$(basename $PWD) +claude +BLOCKED blocked
```

**Si ID fourni** : Exécute uniquement cette tâche

**Sinon** : Exécute toutes les tâches prêtes, phase par phase

---

## Instructions d'exécution

### 1. Reprise après crash

Vérifie d'abord les tâches interrompues :
```bash
task +ACTIVE list
```
Si trouvées, reprendre ou terminer avant de continuer.

### 2. Récupérer les tâches prêtes

```bash
task project:$(basename $PWD) +claude +UNBLOCKED +PENDING export
```

### 3. Grouper par phase

Trier les tâches par `phase` croissant.

### 4. Pour chaque phase

#### Si tâches `parallel:yes` dans la phase :
- Lancer en parallèle via `Task` tool avec le modèle approprié
- Attendre complétion de toutes

#### Si tâches `parallel:no` :
- Exécuter séquentiellement

### 5. Pour chaque tâche

1. **Lire les détails** :
   ```bash
   task <ID> info
   ```

2. **Extraire** : model, annotations (actions, fichiers)

3. **Démarrer** :
   ```bash
   task <ID> start
   ```

4. **Exécuter** selon les annotations

5. **Terminer** :
   ```bash
   task <ID> done
   ```

   Ou si erreur :
   ```bash
   task <ID> annotate "ERREUR: <message>"
   task <ID> stop
   ```

### 6. Passer à la phase suivante

Une fois toutes les tâches de la phase terminées, les tâches de la phase suivante deviennent `+UNBLOCKED`.

---

## Flow

```
Phase 1: [T1, T2 (//), T3 (//)]  →  Exécuter T1, puis T2+T3 en parallèle
          ↓
Phase 2: [T4, T5]                →  Exécuter T4, puis T5
          ↓
Phase 3: [T6]                    →  Exécuter T6
```

---

## Output

```
## Exécution

### Phase 1
- [x] T1: ... (haiku) - OK
- [x] T2: ... (sonnet) - OK
- [x] T3: ... (sonnet) - OK

### Phase 2
- [x] T4: ... (opus) - OK
- [ ] T5: ... - EN COURS

### Résumé
Complétées: 4/6
```
