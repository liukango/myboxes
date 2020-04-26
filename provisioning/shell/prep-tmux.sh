#!/bin/bash

# Change password for root and permit root login
sudo -s << EOF

# If CentOS
cat /etc/os-release | grep -qi "centos" && \
    rm -f /etc/yum.repos.d/epel* && \
    wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    rm -f /etc/yum.repos.d/ius* && \
    wget -qO /etc/yum.repos.d/ius.repo http://mirrors.aliyun.com/ius/ius-7.repo && \
    yum makecache && \

    echo "Installing packages: git & tmux2 ..." && \
    yum install -y git tmux2 > /dev/null

# If Ubuntu
cat /etc/os-release | grep -qi "ubuntu" && \
    echo "Installing packages: git & tmux ..." && \
    apt-get install -y git tmux > /dev/null

git clone https://gitee.com/get-set/tmuxrc.git /root/.tmux
ln -s -f /root/.tmux/.tmux.conf /root/.tmux.conf
ln -s -f /root/.tmux/.tmux.conf.local /root/.tmux.conf.local
ln -s -f /root/.tmux/mytmux /usr/local/bin/t
chmod +x /usr/local/bin/t

echo '[ -n "\$SSH_CONNECTION" ] && [ -z "\$TMUX" ] && t' >> /root/.bashrc

EOF
