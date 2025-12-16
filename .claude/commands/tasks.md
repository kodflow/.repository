# Tasks Status

Affiche l'état des tâches du projet courant.

## Instructions

1. **Vérifie** que Taskwarrior est installé : `which task`

2. **Détermine le projet** à partir du dossier courant ou utilise l'argument fourni

3. **Affiche les vues suivantes** :

### Vue principale
```bash
task project:$PROJECT +claude list
```

### Tâches prêtes (non bloquées)
```bash
task project:$PROJECT +claude +UNBLOCKED +PENDING list
```

### Tâches bloquées
```bash
task project:$PROJECT +claude +BLOCKED list
```

### Tâches bloquantes
```bash
task project:$PROJECT +claude +BLOCKING list
```

### Par phase
```bash
task project:$PROJECT +claude group:phase list
```

### Progression
```bash
task project:$PROJECT summary
```

## Argument optionnel

$ARGUMENTS

Si un argument est fourni, utilise-le comme filtre (ex: `+PENDING`, `phase:1`, etc.)

## Format de sortie

```
## Tâches : <projet>

### Prêtes à exécuter
| ID | Phase | Tâche | Modèle | Parallel |
|----|-------|-------|--------|----------|

### En attente (bloquées)
| ID | Phase | Tâche | Bloquée par |
|----|-------|-------|-------------|

### Progression
- Total: X tâches
- Complétées: Y (Z%)
- En cours: W
```
