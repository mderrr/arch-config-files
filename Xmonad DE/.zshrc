# Lines configured by zsh-newuser-install
HISTFILE=~/.config/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/santiago/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Custom aliases
alias vim='nvim'
alias taur='/home/santiago/.scripts/taur.sh'
alias font-install='/home/santiago/.scripts/font-install.sh'
alias gnome-profile='/home/santiago/.scripts/gnome-profile.sh'
alias dentry-gen='/home/santiago/.scripts/dentry-gen.sh'
alias nclear='clear && neofetch'
alias export-scripts='/home/santiago/.scripts/export-scripts.sh'
alias export-configs='/home/santiago/.scripts/export-configs.sh'

# Custom PS1
export PS1="%B%F{red}[%n:%f%F{yellow}@%m%f %F{green}%~%f%F{red}]$ %f"

neofetch