SHELL_SESSION_HISTORY=0


#
# Load aliases
#
source "$(dirname "${BASH_SOURCE[0]}")/.aliases"


#
# UTF-8
#
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


#
# Homebrew tweaks
#
export HOMEBREW_NO_ANALYTICS=1
export PYENV_ROOT="$HOME/.pyenv"


#
# PATH updates
#
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"
