#!/bin/bash
# bash-validate.sh - PreToolUse hook pour Bash
# Vérifie que les commandes bash respectent les règles du mode courant
# Exit 0 = autorisé, Exit 2 = bloqué
#
# RÈGLE CRITIQUE: En state=planning, TOUTES les écritures sont bloquées

set -euo pipefail

# Lire l'input JSON de Claude
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Ne traiter que les commandes Bash
if [[ "$TOOL" != "Bash" ]]; then
    exit 0
fi

# === Trouver la session active (déterministe) ===
SESSION_FILE=""

# Priorité 1: Pointeur explicite
if [[ -f "/workspace/.claude/active-session" ]]; then
    SESSION_FILE=$(cat /workspace/.claude/active-session 2>/dev/null || true)
fi

# Priorité 2: Symlink state.json
if [[ -z "$SESSION_FILE" || ! -f "$SESSION_FILE" ]]; then
    if [[ -f "/workspace/.claude/state.json" ]]; then
        SESSION_FILE=$(readlink -f /workspace/.claude/state.json 2>/dev/null || echo "/workspace/.claude/state.json")
    fi
fi

# Priorité 3: Dernière session (fallback, non recommandé)
if [[ -z "$SESSION_FILE" || ! -f "$SESSION_FILE" ]]; then
    SESSION_DIR="$HOME/.claude/sessions"
    SESSION_FILE=$(ls -t "$SESSION_DIR"/*.json 2>/dev/null | head -1 || true)
fi

# Si pas de session, autoriser (mode dégradé)
if [[ ! -f "$SESSION_FILE" ]]; then
    exit 0
fi

# === Lire l'état depuis .state (pas .mode !) ===
STATE=$(jq -r '.state // "unknown"' "$SESSION_FILE")

# États autorisés pour modifications
# - applying: exécution des tasks
# - applied: terminé
# En planning/planned: lecture seule
if [[ "$STATE" == "applying" || "$STATE" == "applied" ]]; then
    exit 0
fi

# === STATE = planning ou planned : MODE LECTURE SEULE ===

# Commandes en lecture seule (allowlist stricte)
READONLY_ALLOWED=(
    "git status"
    "git log"
    "git diff"
    "git show"
    "git branch"
    "git rev-parse"
    "git ls-files"
    "git remote"
    "ls"
    "cat"
    "head"
    "tail"
    "grep"
    "find"
    "tree"
    "wc"
    "file"
    "stat"
    "which"
    "pwd"
    "echo"
    "printf"
    "date"
    "jq"
    "yq"
    "task "
    "task-"
    "go test"
    "cargo test"
    "npm test"
    "pytest"
    "make test"
)

# Vérifier si la commande est dans l'allowlist
COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')
IS_READONLY=false

for allowed in "${READONLY_ALLOWED[@]}"; do
    if [[ "$COMMAND_LOWER" == "$allowed"* ]] || [[ "$COMMAND_LOWER" == *" $allowed"* ]]; then
        IS_READONLY=true
        break
    fi
done

# === Patterns d'écriture TOUJOURS bloqués en planning ===
WRITE_PATTERNS=(
    # Redirections
    " > "
    " >"
    ">"
    ">>"
    # Heredocs
    "<<EOF"
    "<<'EOF'"
    "<<-EOF"
    "<< EOF"
    "<<HEREDOC"
    "<<END"
    # Pipes d'écriture
    "| tee"
    "|tee"
    # Modifications in-place
    "sed -i"
    "sed -i'"
    "perl -i"
    "perl -pi"
    # Modifications fichiers
    "touch "
    "mkdir "
    "rm "
    "mv "
    "cp "
    "chmod "
    "chown "
    # Git modifications
    "git add"
    "git commit"
    "git push"
    "git merge"
    "git rebase"
    "git cherry-pick"
    "git reset"
    "git checkout --"
    "git restore --staged"
    "git stash"
    # Package managers
    "npm install"
    "npm i "
    "yarn install"
    "yarn add"
    "pnpm install"
    "pnpm add"
    "pip install"
    "go mod tidy"
    "cargo install"
    # Formatters/Linters auto-fix
    "prettier --write"
    "prettier -w"
    "eslint --fix"
    "go fmt"
    "gofmt -w"
    "rustfmt"
    "black "
    "autopep8"
)

# Exceptions (ces patterns ne déclenchent pas le blocage)
EXCEPTIONS=(
    "> /dev/null"
    ">/dev/null"
    "2> /dev/null"
    "2>/dev/null"
    "2>&1"
    "&> /dev/null"
    "&>/dev/null"
    "| head"
    "| tail"
    "| grep"
    "| jq"
    "| wc"
    "| sort"
    "| uniq"
)

# Fonction pour vérifier si une exception s'applique
has_exception() {
    local cmd="$1"
    for exc in "${EXCEPTIONS[@]}"; do
        if [[ "$cmd" == *"$exc"* ]]; then
            return 0
        fi
    done
    return 1
}

# Vérifier les patterns d'écriture
for pattern in "${WRITE_PATTERNS[@]}"; do
    if [[ "$COMMAND" == *"$pattern"* ]]; then
        # Vérifier les exceptions
        if has_exception "$COMMAND"; then
            continue
        fi
        
        echo "═══════════════════════════════════════════════"
        echo "  🚫 BLOQUÉ: Écriture interdite en PLAN MODE"
        echo "═══════════════════════════════════════════════"
        echo ""
        echo "  État actuel : $STATE (lecture seule)"
        echo "  Pattern détecté : $pattern"
        echo ""
        echo "  Commande :"
        echo "    ${COMMAND:0:200}"
        echo ""
        echo "  En PLAN MODE, seules les commandes de lecture"
        echo "  sont autorisées. Aucune modification de fichier,"
        echo "  git, ou installation de packages n'est permise."
        echo ""
        echo "  Pour modifier des fichiers :"
        echo "    1. Terminez le planning (/plan → validation)"
        echo "    2. Passez en /apply"
        echo "    3. Démarrez une task avec task-start.sh"
        echo ""
        echo "═══════════════════════════════════════════════"
        exit 2
    fi
done

# Si pas dans l'allowlist et contient des caractères suspects, bloquer
if [[ "$IS_READONLY" == "false" ]]; then
    # Vérifier les caractères de redirection bruts
    if [[ "$COMMAND" =~ \>[^/\&] ]] || [[ "$COMMAND" =~ \>\> ]] || [[ "$COMMAND" =~ \<\< ]]; then
        if ! has_exception "$COMMAND"; then
            echo "═══════════════════════════════════════════════"
            echo "  🚫 BLOQUÉ: Redirection détectée en PLAN MODE"
            echo "═══════════════════════════════════════════════"
            echo ""
            echo "  État actuel : $STATE (lecture seule)"
            echo "  Commande non reconnue comme lecture seule."
            echo ""
            echo "  Commande :"
            echo "    ${COMMAND:0:200}"
            echo ""
            echo "═══════════════════════════════════════════════"
            exit 2
        fi
    fi
fi

# Commande autorisée
exit 0
