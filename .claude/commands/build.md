# Build - Task Planning Agent

$ARGUMENTS

---

## Mode

**Si `--list`** : Affiche les tâches existantes du projet
```bash
task project:$(basename $PWD) +claude list
task project:$(basename $PWD) +claude +BLOCKED blocked
task project:$(basename $PWD) summary
```

**Sinon** : Planifie les tâches selon la description fournie (ou analyse globale si vide)

---

## Instructions de planification

### 1. Clarification

Si la demande est ambiguë ou incomplète, utilise `AskUserQuestion` pour :
- Clarifier le scope
- Valider les choix techniques
- Confirmer les priorités

### 2. Exploration

1. **Analyse le projet** :
   - Structure (`Glob`)
   - Code existant (`Read`, `Grep`)
   - Documentation (`README.md`, `CLAUDE.md`)

2. **Recherche web** si nécessaire :
   - Documentation officielle
   - Best practices

### 3. Initialisation Taskwarrior (si première utilisation)

```bash
# UDAs Claude Code
task config uda.model.type string
task config uda.model.values opus,sonnet,haiku
task config uda.model.default sonnet
task config uda.parallel.type string
task config uda.parallel.values yes,no
task config uda.parallel.default no
task config uda.phase.type numeric
task config uda.phase.default 1
```

### 4. Création des tâches

Pour chaque tâche :
```bash
task add "<description>" project:$(basename $PWD) +claude model:<haiku|sonnet|opus> parallel:<yes|no> phase:<N> [depends:<IDs>]
task <ID> annotate "Action: <détails>"
task <ID> annotate "Fichiers: <paths>"
```

### 5. Choix du modèle

| Modèle | Quand |
|--------|-------|
| `haiku` | Simple, répétitif, formatting |
| `sonnet` | Standard, refactoring, tests |
| `opus` | Complexe, architecture, debug |

### 6. Dépendances et parallélisation

- `depends:X,Y` = Bloqué par X et Y
- `parallel:yes` + même `phase:N` = Parallélisables ensemble
- Phase 1 → Phase 2 → Phase 3 (séquentiel entre phases)

---

## Output

```
## Plan : <titre>

| # | Phase | Tâche | Modèle | // | Dépend |
|---|-------|-------|--------|----|--------|
| 1 | 1     | ...   | haiku  | no | -      |
| 2 | 1     | ...   | sonnet | yes| -      |
| 3 | 2     | ...   | opus   | no | 1,2    |

### Commandes exécutées
<task add ...>
```
