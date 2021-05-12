#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

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
export PS1="\[\e[1;31m\][\[\e[1;31m\]\u\[\e[1;33m\]@\[\e[1;33m\]\h\[\e[1;33m\]: \[\e[1;32m\]\W\[\e[1;31m\]]\[\e[1;31m\]$ \[\e[0m\]"

neofetch
