#!/bin/sh

# Install Oh My Zsh
sudo apt-get update
sudo apt-get install -y zsh git curl 
0>/dev/null sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Install zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> $HOME/.zshrc
echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-completions/zsh-completions.plugin.zsh" >> $HOME/.zshrc
echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc

# Customize PROMPT 
append_to_zshrc="$(cat <<'EOF'

# Git branch in prompt.
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}
setopt PROMPT_SUBST
NEWLINE=$'\n'
export PROMPT='%F{green}%n%B@%F{red}%m%b%f [%D{%a, %b %d}] %F{blue}%~%f %F{magenta}$(parse_git_branch)%f ${NEWLINE}%F{yellow}%D{[%X %Z]} %# '

EOF
)"

printf "%s\n" "$append_to_zshrc" "$NEWLINE">> ~/.zshrc

# Setting timezene to PDT
sudo cp /usr/share/zoneinfo/US/Pacific /etc/localtime

rm setup_zsh.sh

0>/dev/null zsh
