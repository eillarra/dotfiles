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
export PATH="/usr/local/sbin:$PATH"
ln -s /opt/homebrew/lib ~/lib


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
# postgresql@14
#
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"


#
# openjdk
#
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"


#
# curl-openssl
#
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig"


#
# ruby
#
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/usr/local/lib/ruby/gems/3.1.0/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


#
# docker
#
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"


#
# node
#
export PATH="/opt/homebrew/opt/node/bin:$PATH"


#
# dotnet
#
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"


#
# pyenv
#
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
