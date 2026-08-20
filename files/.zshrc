SHELL_SESSION_HISTORY=0

#
# Load aliases
#
source "$HOME/.aliases"

#
# UTF-8
#
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#
# Homebrew tweaks
#
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

export PATH="/usr/local/sbin:$PATH"

#
# curl-openssl
#
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/curl/lib ${LDFLAGS:-}"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include ${CPPFLAGS:-}"
export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

#
# sqlite
#
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"

#
# mysql@8.0
#
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/mysql@8.0/lib ${LDFLAGS:-}"
export CPPFLAGS="-I/opt/homebrew/opt/mysql@8.0/include ${CPPFLAGS:-}"
export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql@8.0/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

#
# postgresql@18
#
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@18/lib ${LDFLAGS:-}"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@18/include ${CPPFLAGS:-}"

#
# node@24
#
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@24/lib ${LDFLAGS:-}"
export CPPFLAGS="-I/opt/homebrew/opt/node@24/include ${CPPFLAGS:-}"

#
# pyenv
#
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

#
# nltk
#
export NLTK_DATA="$HOME/.cache/nltk_data"
mkdir -p "$NLTK_DATA"

#
# Local bin
#
export PATH="$HOME/.local/bin:$PATH"
