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


#
# sqlite
#
export PATH="/usr/local/opt/sqlite/bin:$PATH"


#
# mysql
#
export PATH="/usr/local/opt/mysql/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/mysql/lib"
export CPPFLAGS="-I/usr/local/opt/mysql/include"
export PKG_CONFIG_PATH="/usr/local/opt/mysql/lib/pkgconfig"


#
# postgresql
#
export PATH="/usr/local/opt/postgresql/bin:$PATH"


#
# openjdk
#
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/usr/local/opt/openjdk/include"


#
# curl-openssl
#
export PATH="/usr/local/opt/curl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"
export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig"


#
# ruby
#
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="/usr/local/lib/ruby/gems/3.1.0/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


#
# docker
#
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
export PATH="/usr/local/opt/node@18/bin:$PATH"


#
# pyenv
#
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


#
# dotnet
#
export DOTNET_ROOT="/usr/local/opt/dotnet/libexec"
