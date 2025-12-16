# Kodflow DevContainer Template

## Projet

Template DevContainer avec Claude Code, outils DevOps et gestion de tâches Taskwarrior.

## Stack

- Base: Ubuntu 24.04 LTS
- Shell: Zsh + Powerlevel10k
- Container: Docker + DevContainer

## Commandes

```bash
# Build
docker compose -f .devcontainer/docker-compose.yml build

# Claude avec MCP
super-claude
```

## Slash Commands

| Commande | Description |
|----------|-------------|
| `/task <description>` | Analyse et planifie des tâches avec Taskwarrior |
| `/tasks [filtre]` | Affiche l'état des tâches du projet |
| `/run [id\|--all]` | Exécute les tâches prêtes |
| `/init-tasks` | Initialise Taskwarrior avec les UDAs Claude |

## Taskwarrior UDAs

| Attribut | Type | Valeurs | Description |
|----------|------|---------|-------------|
| `model` | string | opus, sonnet, haiku | Modèle Claude |
| `agent` | string | - | Agent/subagent |
| `parallel` | string | yes, no | Parallélisable |
| `phase` | numeric | 1, 2, 3... | Ordre d'exécution |
| `estimate` | numeric | - | Estimation (minutes) |

## Workflow tâches

```
/task "description"  →  Analyse + Questions  →  Plan  →  task add
/tasks               →  Vue des tâches prêtes
/run                 →  Exécution séquentielle/parallèle
```

## Conventions

- Tags: `+claude` pour toutes les tâches gérées par Claude
- Projet: Nom du dossier courant
- Dépendances: `depends:ID` pour le séquencement
- Phases: Groupement pour parallélisation

## Ne pas faire

- Ne pas modifier `.devcontainer/images/Dockerfile` sans rebuild CI
- Ne pas commit de tokens/secrets (`.mcp.json` est ignoré)
