# Kodflow DevContainer Template

## Stack

- Ubuntu 24.04 LTS
- Zsh + Powerlevel10k
- Docker + DevContainer

## Commandes

```bash
super-claude              # Claude avec MCP
```

## Slash Commands

| Commande | Description |
|----------|-------------|
| `/build` | Planifie les tâches (Taskwarrior) |
| `/build --list` | Liste les tâches du projet |
| `/run` | Exécute toutes les tâches |
| `/run --list` | Liste les tâches |
| `/run <ID>` | Exécute une tâche spécifique |

## Taskwarrior

### UDAs

| Attribut | Valeurs |
|----------|---------|
| `model` | opus, sonnet, haiku |
| `parallel` | yes, no |
| `phase` | 1, 2, 3... |

### Workflow

```
/build "description"  →  Questions + Analyse + Plan
/run                  →  Exécution phase par phase
```

### Tags

- `+claude` : Tâches gérées par Claude
- `+BLOCKED` : En attente de dépendances
- `+ACTIVE` : En cours d'exécution

## Ne pas faire

- Ne pas modifier `.devcontainer/images/Dockerfile` sans rebuild CI
- Ne pas commit de tokens (`.mcp.json` ignoré)
