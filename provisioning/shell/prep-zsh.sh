#!/bin/bash

echo "Installing zsh ..."
apt-get -qq install -y zsh &> /dev/null || yum install -y zsh &> /dev/null || exit 0

if [ -d /media/psf/Home/.oh-my-zsh ]; then
    echo "Installing oh-my-zsh by copying from host OS ..." && \
    cp -r /media/psf/Home/.oh-my-zsh /root
    cp /media/psf/Home/.p10k.zsh /root
else
    export http_proxy=${HOST_PROXY:-"http://10.2.2.2:8118"}; export https_proxy=$http_proxy

    n=0; until [ $n -ge 5 ]; do
        echo "Installing oh-my-zsh ..." && \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \

        echo "Installing zsh-autosuggestiongs & zsh-syntax-highlighting ..." && \
        ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom} && \
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && \
        git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k && \
        break

        echo "Failed installing oh-my-zsh, retry ... $n"
        n=$[$n+1]; sleep 1
    done
    unset http_proxy; unset https_proxy
fi

ZSHRC_CONF=https://gitee.com/get-set/myboxes/raw/master/provisioning/files/.zshrc
cat /etc/os-release | grep -qi "centos linux 7" && ZSHRC_CONF=https://gitee.com/get-set/myboxes/raw/master/provisioning/files/.zshrc.centos7

n=0; until [ $n -ge 5 ]; do
    curl -sSL $ZSHRC_CONF > /root/.zshrc && break
    echo "Failed downloading .zshrc, retry ... $n"
    n=$[$n+1]; sleep 1
done

chsh -s $(which zsh) &> /dev/null
