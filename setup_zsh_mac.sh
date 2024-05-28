#!/bin/sh

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Oh My Zsh
brew install zsh git
0>/dev/null sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Install zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting, powerlevel10k theme
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

curl https://raw.githubusercontent.com/wpwebs/dev_container_docker_compose/main/.dot_files/.p10k.zsh > p10k.zsh ; mv p10k.zsh ~/.p10k.zsh

# Install iTerm2
brew install --cask iterm2

# Enable Shell Integration
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh

# Download and install fonts
cd ~/Library/Fonts && { 
    wget https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Regular.ttf 
    wget https://github.com/romkatv/dotfiles-public/blob/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Bold%20Italic.ttf 
    wget https://github.com/romkatv/dotfiles-public/blob/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Bold.ttf 
    wget https://github.com/romkatv/dotfiles-public/blob/master/.local/share/fonts/NerdFonts/MesloLGS%20NF%20Italic.ttf 
    cd -; }

open /Applications/iTerm.app/
sleep 1
killall iTerm2

# Customize iTerm2: Fonts, Window size and Background Transparency
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Normal Font\" \"MesloLGS-NF-Regular 12\""  ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Non Ascii Font\" \"MesloLGS-NF-Regular 12\""  ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Columns\" 141"  ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Rows\" 33"  ~/Library/Preferences/com.googlecode.iterm2.plist
/usr/libexec/PlistBuddy -c "Set :\"New Bookmarks\":0:\"Transparency\" 0.18"  ~/Library/Preferences/com.googlecode.iterm2.plist

exit
# Customize PROMPT 
append_to_zshrc="$(cat <<'EOF'

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.iterm2_shell_integration.zsh

source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-completions/zsh-completions.plugin.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

EOF
)"
printf "%s\n" "$append_to_zshrc" >> ~/.zshrc

rm setup_zsh_mac.sh

0>/dev/null zsh
