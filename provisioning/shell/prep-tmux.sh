#!/bin/bash

# Change password for root and permit root login
sudo -s << EOF

which yum &> /dev/null && \
    echo "Installing packages: git & tmux2 ..." && \
    yum install -y git xsel xclip tmux2 &> /dev/null

which apt &> /dev/null && \
    echo "Installing packages: git & tmux ..." && \
    apt-get -qq install -y git xsel xclip tmux &> /dev/null

echo "Installing oh-my-tmux ..."
git clone -q https://gitee.com/get-set/tmuxrc.git /root/.tmux > /dev/null
ln -s -f /root/.tmux/.tmux.conf /root/.tmux.conf
ln -s -f /root/.tmux/.tmux.conf.local /root/.tmux.conf.local
ln -s -f /root/.tmux/mytmux /usr/local/bin/t
chmod +x /usr/local/bin/t

[ -f /root/.bashrc ] && \
    echo '[ -n "\$SSH_CONNECTION" ] && [ -z "\$TMUX" ] && t' >> /root/.bashrc
[ -f /root/.zshrc ] && \
    echo '[ -n "\$SSH_CONNECTION" ] && [ -z "\$TMUX" ] && t' >> /root/.zshrc && \
    sed -i 's/^plugins=(/plugins=(tmux /' ~/.zshrc

EOF
