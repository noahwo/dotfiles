#####################
#   SHARED .zshrc   #
#####################

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/dotfiles/scripts:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.config/zsh/.oh-my-zsh"
export ZSHRC="$HOME/dotfiles/.zshrc"
export ZC="$HOME/dotfiles/.zshrc"
export VC="$HOME/dotfiles/nvim/init.lua"
export TC="$HOME/dotfiles/.tmux.conf"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# OS-specific settings: Theme
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS-specific settings
    echo "Running on macOS"

    ZSH_THEME="apple"

elif [[ "$(uname)" == "Linux" ]]; then
    # Linux-specific settings
    echo "Running on Linux"

    ZSH_THEME="robbyrussell"
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

###############
#   ALIASES   #
###############

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias c="clear"
alias v="nvim"

## git aliases
alias add="git add"
alias checkout="git checkout"
alias rebase='git rebase'
alias push="git push"
alias pull="git pull"
alias clone="git clone"
alias merge="git merge"

# Tmux Aliases
alias t='tmux' # Start tmux
alias ta='tmux attach-session' # Attach to a tmux session
alias tat='tmux attach-session -t' # Attach to a tmux session with name
alias tks='tmux kill-session -a' # Kill all tmux sessions
alias tl='tmux list-sessions' # List tmux sessions
alias tn='tmux new-session' # Start a new tmux session
alias tns='tmux new -s' # Start a new tmux session with name
alias ts='tmux new-session -s' # Start a new tmux session

# docker
alias docker-rm="docker ps -aq | xargs docker stop | xargs docker rm"

# OS-specific settings: Aliases
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS-specific settings
  alias in="brew install"
  alias unin="brew uninstall"
  alias upd="brew update && brew upgrade"
  alias upg="brew upgrade"
  alias turso="ssh -YA wuguangh@turso.cs.helsinki.fi"
elif [[ "$(uname)" == "Linux" ]]; then
  # Linux-specific settings
  alias in="sudo apt install"
  alias unin="sudo apt remove"
  alias up="sudo apt update"
  alias upd="sudo apt update && sudo apt upgrade"
  alias upg="sudo apt upgrade"
  alias batch_run='tmux new-session -d -s batch_session "/home/han/anaconda3/envs/llmdev/bin/python /home/han/Projects/tinyml-autopilot/dev/test_in_batch/batch_run.py" \; attach-session -t batch_session'
fi

# FUNCTIONS

commit() {
    git commit -m"$1"
}
# git add + commit
gac() {
    git add . && git commit -m "$1"
}
# add, commit, push
gacp() {
    git add . && git commit -m "$1" && git push
}

# git add + commit + push to origin
dotfiles() {
    git -C $HOME/dotfiles/ add . && git -C $HOME/dotfiles/ commit -m "$1" && git -C $HOME/dotfiles/ push origin
}

############################
#   OS-specific .settings  #
############################
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS-specific settings

    # Theme
    ZSH_THEME="apple"

    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/Users/hann/anaconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/Users/hann/anaconda3/etc/profile.d/conda.sh" ]; then
            . "/Users/hann/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/Users/hann/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    conda activate datasci2

    # for skidl python library
    export KICAD_SYMBOL_DIR="/usr/share/kicad/library"
elif [[ "$(uname)" == "Linux" ]]; then
    # Linux-specific settings

    export PATH=/usr/local/cuda-12/bin:$PATH
    export PATH=/home/han/.local/bin:$PATH
    export GIT_EDITOR=vim

    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/han/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/han/anaconda3/etc/profile.d/conda.sh" ]; then
            # . "/home/han/anaconda3/etc/profile.d/conda.sh"  # commented out by conda initialize
        else
            # export PATH="/home/han/anaconda3/bin:$PATH"  # commented out by conda initialize
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    conda activate llmdev

fi
