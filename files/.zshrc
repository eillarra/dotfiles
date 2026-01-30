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
export PATH="/usr/local/sbin:$PATH"
ln -s /opt/homebrew/lib ~/lib


#
# curl-openssl
#
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig"


#
# sqlite
#
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"


#
# mysql@8.0
#
export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/mysql@8.0/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql@8.0/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql@8.0/lib/pkgconfig"


#
# postgresql@18
#
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@18/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@18/include"


#
# node@24
#
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/node@24/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@24/include"

#
# pyenv
#
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
