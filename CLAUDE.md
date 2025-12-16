# Kodflow DevContainer Template

## Stack

- Ubuntu 24.04 LTS
- Zsh + Powerlevel10k
- Docker + DevContainer

## Slash Commands

### /build - Planification

| Commande | Action |
|----------|--------|
| `/build --context` | Génère CLAUDE.md dans tous les dossiers |
| `/build --project <desc>` | Crée projet + tâches auto |
| `/build --for <project> --task <desc>` | Ajoute une tâche |
| `/build --for <project> --task <id>` | Met à jour une tâche |
| `/build --list` | Liste les projets |
| `/build --for <project> --list` | Liste les tâches |

### /run - Exécution

| Commande | Action |
|----------|--------|
| `/run <project>` | Exécute tout le projet |
| `/run --for <project> --task <id>` | Exécute une tâche |

## Contexte (CLAUDE.md)

### Principe : Entonnoir

```
/CLAUDE.md              → Vue d'ensemble (commité)
/src/CLAUDE.md          → Détails src (ignoré)
/src/components/CLAUDE.md → Plus de détails (ignoré)
```

Plus on descend, plus c'est détaillé.

### Règles

- < 60 lignes par fichier
- Concis et universel
- Divulgation progressive
- Sous-dossiers JAMAIS commités

## Taskwarrior

### UDAs (auto-détectés)

| Attribut | Valeurs | Auto-détection |
|----------|---------|----------------|
| `model` | haiku, sonnet, opus | Complexité |
| `parallel` | yes, no | Dépendances |
| `phase` | 1, 2, 3... | Ordre |

### Workflow

```
/build --context              → Génère le contexte
/build --project "Auth OAuth" → Planifie les tâches
/run auth-oauth               → Exécute
```
