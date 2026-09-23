#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"

ask_for_sudo

echo
print_step 'Software update'

#
# macOS Software Update (security & minor updates, no major upgrades)
#
print_info "Scanning for macOS updates..."
UPDATE_LIST=$(softwareupdate -l 2>&1)
CURRENT_MAJOR=$(sw_vers -productVersion | cut -d. -f1)
# Handles both output formats: title after a tab on the same line (older macOS),
# or on its own "\tTitle: ..." line (Tahoe and later). Major upgrades are
# filtered by comparing the update's major version against the running OS:
# newer releases no longer contain the word "Upgrade" in their title.
UPDATE_ITEMS=$(
  printf '%s\n' "$UPDATE_LIST" \
    | awk -v cur="$CURRENT_MAJOR" '
        function emit() {
          if (label == "") { title = ""; return }
          text = label " " title
          if (text ~ /[Uu]pgrade/) { label = ""; title = ""; return }
          if (label ~ /^macOS/ && match(title, /Version: [0-9]+(\.[0-9]+)*/)) {
            split(substr(title, RSTART + 9, RLENGTH - 9), part, ".")
            if (part[1] + 0 > cur + 0) { label = ""; title = ""; return }
          }
          print label "\t" title
          label = ""; title = ""
        }
        /^\* Label: / {
          emit()
          line = $0
          sub(/^\* Label: /, "", line)
          if (idx = index(line, "\t")) {
            title = substr(line, idx + 1)
            label = substr(line, 1, idx - 1)
            emit()
          } else {
            label = line
            title = ""
          }
          next
        }
        /^[ \t]*Title: / {
          title = $0
          sub(/^[ \t]+/, "", title)
          emit()
          next
        }
        END { emit() }
      '
)

if [ -z "$UPDATE_ITEMS" ]; then
  print_info "No security or minor updates available."
elif [ ! -t 0 ]; then
  print_info "Updates available, but no interactive terminal. Skipping:"
  printf '%s\n' "$UPDATE_ITEMS" | cut -f1,2 | sed -e 's/Title: //' -e 's/^/    /'
else
  SELECTED=()
  while IFS=$'\t' read -r -u 3 label title; do
    print_info "Update available:"
    printf '%s\n' "${title#Title: }" | sed 's/^/    /'
    read -p "Install '$label'? (y/n) " choice
    if [ "$choice" = "y" ]; then
      SELECTED+=("$label")
    fi
  done 3<<EOF
$(printf '%s\n' "$UPDATE_ITEMS")
EOF
  if [ ${#SELECTED[@]} -eq 0 ]; then
    print_info "No updates selected. Skipping."
  else
    print_info "Downloading and installing updates..."
    run_indent sudo softwareupdate -i "${SELECTED[@]}"
    print_success "macOS updates installed"
  fi
fi

#
# Homebrew
#
print_info "Updating Homebrew..."
brew update &> /dev/null
print_info "Upgrading formulas and cask apps..."
run_indent brew upgrade --greedy-auto-updates
print_info "Cleaning up installation files..."
brew cleanup --prune=all &> /dev/null
print_success "Homebrew updated"

#
# Python
#
if command_exists uv; then
  print_info "Upgrading Python..."
  run_indent uv python upgrade
  print_success "Python upgraded"
fi

#
# uv tools
#
if command_exists uv; then
  print_info "Upgrading uv tools..."
  run_indent uv tool upgrade --all
  print_success "uv tools updated"
fi

echo
