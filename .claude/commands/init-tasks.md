# Initialize Taskwarrior for Claude Code

Configure Taskwarrior avec les UDAs nécessaires pour la gestion des tâches Claude Code.

---

## Instructions

### 1. Vérifier l'installation

```bash
which task && task --version
```

Si Taskwarrior n'est pas installé, informer l'utilisateur de rebuild le container.

### 2. Configurer les UDAs

Exécute ces commandes pour créer les attributs personnalisés :

```bash
# Modèle Claude à utiliser
task config uda.model.type string
task config uda.model.label Model
task config uda.model.values opus,sonnet,haiku
task config uda.model.default sonnet

# Agent/Subagent à utiliser
task config uda.agent.type string
task config uda.agent.label Agent

# Parallélisable
task config uda.parallel.type string
task config uda.parallel.label Parallel
task config uda.parallel.values yes,no
task config uda.parallel.default no

# Phase d'exécution (ordre)
task config uda.phase.type numeric
task config uda.phase.label Phase
task config uda.phase.default 1

# Contexte/fichiers concernés
task config uda.context.type string
task config uda.context.label Context

# Estimation en minutes
task config uda.estimate.type numeric
task config uda.estimate.label Est(min)
```

### 3. Configurer les rapports personnalisés

```bash
# Rapport claude : tâches Claude Code
task config report.claude.columns id,phase,description,model,parallel,depends,tags
task config report.claude.labels ID,Phase,Description,Model,Parallel,Depends,Tags
task config report.claude.filter +claude
task config report.claude.sort phase+,id+

# Rapport ready-claude : tâches prêtes
task config report.ready-claude.columns id,phase,description,model,parallel,estimate
task config report.ready-claude.labels ID,Phase,Description,Model,Parallel,Est
task config report.ready-claude.filter +claude +UNBLOCKED +PENDING
task config report.ready-claude.sort phase+,id+
```

### 4. Configurer l'urgence

```bash
# Boost pour les tâches bloquantes
task config urgency.blocking.coefficient 8.0

# Réduction pour les tâches bloquées
task config urgency.blocked.coefficient -5.0

# Bonus par phase (phase 1 = plus urgent)
task config urgency.uda.phase.coefficient -1.0
```

### 5. Vérification

```bash
task udas
task reports
```

---

## Output attendu

```
## Taskwarrior initialisé pour Claude Code

### UDAs configurés
- model: opus | sonnet | haiku
- agent: <nom_agent>
- parallel: yes | no
- phase: <numero>
- context: <fichiers>
- estimate: <minutes>

### Rapports disponibles
- `task claude` : Toutes les tâches Claude
- `task ready-claude` : Tâches prêtes à exécuter

### Prêt à utiliser
Utilisez `/task <description>` pour créer un plan de tâches.
```
