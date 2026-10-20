#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
OLLAMA_MODELS_JSON="$DOTFILES_DIR/files/ollama-cloud-models.json"

echo
print_step 'Ollama cloud models'

if ! command_exists ollama; then
    print_info "ollama not installed; skipping model pulls"
    return 0 2>/dev/null || exit 0
fi

if ! command_exists jq; then
    print_info "jq not installed; cannot read model list"
    return 0 2>/dev/null || exit 0
fi

if [ ! -f "$OLLAMA_MODELS_JSON" ]; then
    print_info "Model list not found: $OLLAMA_MODELS_JSON"
    return 0 2>/dev/null || exit 0
fi

# Validate the model list before doing (or undoing) anything. A bad file must
# never trigger an empty pull set or a wipe of installed models.
if ! jq -e 'type == "object" and length > 0 and all(.[]; type == "string")' "$OLLAMA_MODELS_JSON" >/dev/null 2>&1; then
    print_error "Invalid or empty ollama cloud model config: $OLLAMA_MODELS_JSON"
    return 1 2>/dev/null || exit 1
fi

print_info "Pulling configured ollama cloud models..."
while IFS= read -r model
do
    [ -z "$model" ] && continue
    print_info "Pulling ollama model \"$model\"..."
    run_indent ollama pull "$model"
    print_result $? "Pull ollama model \"$model\""
done < <(jq -r 'keys[]' "$OLLAMA_MODELS_JSON")

# Optional cleanup: only on `dot update`, when explicitly requested.
if [ "${OLLAMA_CLEAN_MISSING:-0}" = "1" ]; then
    print_info "Removing obsolete ollama cloud models (if any)..."
    if ! installed_list=$(ollama list 2>&1); then
        print_error "Could not list installed ollama models"
        return 1 2>/dev/null || exit 1
    fi
    while IFS= read -r installed
    do
        [ -z "$installed" ] && continue
        case "$installed" in
            *:cloud) ;;
            *) continue ;;
        esac
        if jq -e --arg m "$installed" 'has($m)' "$OLLAMA_MODELS_JSON" >/dev/null 2>&1; then
            continue
        fi
        print_info "Removing ollama model \"$installed\"..."
        run_indent ollama rm "$installed"
        print_result $? "Remove ollama model \"$installed\""
    done < <(printf '%s\n' "$installed_list" | awk 'NR>1 {print $1}' | grep ':cloud$' || true)
fi