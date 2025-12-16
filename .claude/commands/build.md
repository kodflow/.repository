# Build - Project & Task Planner

$ARGUMENTS

---

## Parsing des arguments

| Pattern | Action |
|---------|--------|
| `--context` | Génère CLAUDE.md dans tous les dossiers |
| `--project <desc>` | Crée un nouveau projet |
| `--for <project> --task <desc>` | Crée une tâche dans le projet |
| `--for <project> --task <id>` | Met à jour une tâche existante |
| `--list` | Liste tous les projets |
| `--for <project> --list` | Liste les tâches du projet |

---

## Actions

### `--context` : Générer le contexte projet

Analyse TOUT le projet et crée un `CLAUDE.md` dans CHAQUE dossier (sauf racine).

**Principe : Entonnoir de détails**
- Plus on descend dans l'arborescence, plus le contenu est détaillé
- Chaque niveau hérite du contexte parent mais ajoute des spécificités

#### 0. Mise à jour des versions (OBLIGATOIRE)

**Avant toute génération**, récupérer les dernières versions officielles :

| Langage | Source officielle | Release Notes |
|---------|-------------------|---------------|
| Go | go.dev | https://go.dev/doc/devel/release |
| Python | python.org | https://docs.python.org/3/whatsnew/ |
| Node.js | nodejs.org | https://nodejs.org/en/blog/release |
| Rust | rust-lang.org | https://releases.rs/ |
| Java | adoptium.net | https://adoptium.net/temurin/release-notes/ |
| C++ | isocpp.org | https://en.cppreference.com/w/cpp/compiler_support |
| PHP | php.net | https://www.php.net/releases/ |
| Ruby | ruby-lang.org | https://www.ruby-lang.org/en/news/ |
| Dart | dart.dev | https://dart.dev/get-dart |
| Flutter | flutter.dev | https://docs.flutter.dev/release/release-notes |
| Elixir | elixir-lang.org | https://github.com/elixir-lang/elixir/releases |
| Scala | scala-lang.org | https://github.com/scala/scala3/releases |
| Carbon | carbon-lang | https://github.com/carbon-language/carbon-lang/releases |

**Mettre à jour RULES.md** :
1. Modifier la première ligne avec la nouvelle version
2. Ajouter/mettre à jour le lien vers les release notes (ligne 2)

```bash
# Exemple pour Go
VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1 | sed 's/go//')
sed -i "1s/.*/# Go >= $VERSION/" .devcontainer/features/languages/go/RULES.md
# Le lien release est déjà en ligne 2 du fichier
```

**IMPORTANT** : Ne JAMAIS downgrader une version. Si la version actuelle est supérieure, conserver l'actuelle.

#### Règles de génération

| Niveau | Lignes max | Contenu |
|--------|------------|---------|
| Profondeur 1 (`/src/`) | ~30 | Vue d'ensemble du dossier |
| Profondeur 2 (`/src/components/`) | ~50 | Détails des sous-modules |
| Profondeur 3+ (`/src/components/Button/`) | ~60 | Spécificités techniques |

#### Structure de chaque CLAUDE.md

```markdown
# <Nom du dossier>

## Rôle
<1-2 phrases décrivant le but de ce dossier>

## Contenu
<Liste des fichiers/dossiers importants avec description courte>

## Conventions
<Règles spécifiques à ce dossier si applicable>

## Voir aussi
<Références vers CLAUDE.md parents ou liés>
```

#### Processus

1. **Lister tous les dossiers** (récursif, ignorer node_modules, .git, etc.)
   ```bash
   find . -type d -not -path '*/\.*' -not -path '*/node_modules/*' -not -path '*/vendor/*'
   ```

2. **Pour chaque dossier** (du plus profond au moins profond) :
   - Lire les fichiers présents
   - Analyser le code/contenu
   - Déterminer le rôle du dossier
   - Générer le CLAUDE.md adapté au niveau

3. **Respecter les règles** :
   - < 60 lignes idéalement
   - Concis et universel
   - Divulgation progressive (où trouver l'info, pas toute l'info)
   - NE JAMAIS commit ces fichiers (gitignore)

#### Exemple d'entonnoir

```
/CLAUDE.md (racine - commité)
├── Vue d'ensemble projet
├── Stack technique
└── Commandes principales

/src/CLAUDE.md (ignoré)
├── Rôle: Code source principal
├── Structure: components/, services/, utils/
└── Conventions: ES modules, TypeScript

/src/components/CLAUDE.md (ignoré)
├── Rôle: Composants React réutilisables
├── Pattern: Atomic Design
├── Conventions: PascalCase, .tsx
└── Tests: *.test.tsx côté fichier

/src/components/Button/CLAUDE.md (ignoré)
├── Rôle: Composant bouton avec variantes
├── Props: variant, size, disabled, onClick
├── Fichiers: Button.tsx, Button.test.tsx, Button.stories.tsx
├── Dépendances: classnames, ./styles.css
└── Usage: <Button variant="primary">Click</Button>
```

#### Output

```
## Contexte généré

Dossiers analysés : 24
CLAUDE.md créés : 23 (racine existant)

| Dossier | Lignes | Rôle |
|---------|--------|------|
| /src | 28 | Code source |
| /src/components | 45 | Composants UI |
| /src/services | 32 | Services API |
...

Prêt pour : `/build --project` ou `/build --for <project> --task`
```

---

### `--project <description>` : Créer un projet

1. **Analyse la description** pour comprendre le scope
2. **Pose des questions** si infos manquantes (`AskUserQuestion`)
3. **Explore le codebase** si pertinent
4. **Recherche web** pour best practices si nécessaire
5. **Crée le projet** et génère automatiquement les tâches :

```bash
# Créer les tâches avec métadonnées
task add "<tache>" project:<nom_projet> +claude \
  model:<haiku|sonnet|opus> \
  parallel:<yes|no> \
  phase:<N> \
  [depends:<IDs>]

# Ajouter les détails
task <ID> annotate "Action: <détails>"
task <ID> annotate "Fichiers: <paths>"
task <ID> annotate "Critères: <done_when>"
```

### `--for <project> --task <description>` : Créer une tâche

1. **Analyse la description**
2. **Détermine automatiquement** :
   - `model` : haiku (simple), sonnet (standard), opus (complexe)
   - `parallel` : yes si indépendant, no si séquentiel
   - `phase` : selon les dépendances
   - `depends` : IDs des tâches prérequises

```bash
task add "<description>" project:<project> +claude \
  model:<auto> parallel:<auto> phase:<auto> [depends:<auto>]
```

### `--for <project> --task <id>` : Mettre à jour

```bash
task <id> modify <champs_modifies>
task <id> annotate "<nouvelle_info>"
```

### `--list` : Lister les projets

```bash
task projects
```

### `--for <project> --list` : Lister les tâches

```bash
task project:<project> +claude list
task project:<project> +claude +BLOCKED blocked
task project:<project> summary
```

---

## Auto-détection du modèle

| Critères | Modèle |
|----------|--------|
| Formatting, linting, renommage simple | `haiku` |
| CRUD, refactoring, tests unitaires | `sonnet` |
| Architecture, debugging complexe, sécurité | `opus` |

## Auto-détection parallélisation

| Critères | Parallel |
|----------|----------|
| Fichiers différents, pas de dépendance | `yes` |
| Même fichier, dépendance logique | `no` |

## Auto-détection phase

- Phase 1 : Tâches sans prérequis
- Phase N : Tâches dépendant de tâches phase N-1
- Même phase si parallélisables ensemble

---

## Initialisation UDA (auto si première utilisation)

```bash
task config uda.model.type string
task config uda.model.values opus,sonnet,haiku
task config uda.model.default sonnet
task config uda.parallel.type string
task config uda.parallel.values yes,no
task config uda.parallel.default no
task config uda.phase.type numeric
task config uda.phase.default 1
```

---

## Output

### Création projet
```
## Projet créé : <nom>

| # | Phase | Tâche | Modèle | // | Dépend |
|---|-------|-------|--------|----|--------|
| 1 | 1 | ... | haiku | yes | - |
| 2 | 1 | ... | sonnet | yes | - |
| 3 | 2 | ... | opus | no | 1,2 |

Exécuter : `/run <nom>`
```

### Création tâche
```
## Tâche ajoutée : #<ID>

- Projet : <nom>
- Modèle : <model>
- Phase : <N>
- Parallel : <yes|no>
- Dépend de : <IDs>
```

### Liste projets
```
## Projets

| Projet | Tâches | Complétées | % |
|--------|--------|------------|---|
```

### Liste tâches
```
## Tâches : <projet>

### Prêtes
| ID | Phase | Tâche | Modèle | // |

### Bloquées
| ID | Tâche | Bloquée par |

### Complétées
| ID | Tâche |
```
