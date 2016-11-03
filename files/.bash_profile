SHELL_SESSION_HISTORY=0


#
# Load aliases
#
source "$(dirname "${BASH_SOURCE[0]}")/.aliases"


#
# pyenv config
#
eval "$(pyenv init -)";
eval "$(pyenv virtualenv-init -)";


#
# UTF-8
#
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8