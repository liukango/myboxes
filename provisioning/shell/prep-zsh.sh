#!/bin/bash


# Change password for root and permit root login
sudo -s << EOF

echo "Installing zsh ..."
which yum &> /dev/null && \
    yum install -y zsh > /dev/null
which apt &> /dev/null && \
    apt-get install -y zsh > /dev/null

echo "Installing oh-my-zsh ..."
sh -c "$(curl -fsSL https://gitee.com/get-set/ohmyzsh/raw/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)

echo "Installing zsh-autosuggestiongs & zsh-syntax-highlighting ..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
sed -i '/^plugins=/c plugins=(git z vi-mode zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc

EOF
