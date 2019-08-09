# 我的Vagrant虚拟机

自己平常用来测试的环境，通过vagrant管理。  

没有用自己的box，还是使用官网的box，好处是不用自己打box，方便保持box更新。  

template目录下为模板，创建其他环境时可以通过该模板复制来配置，包括： 

1. 定义虚拟机配置，主要参数为box、cpu个数、内存大小、private网络地址； 
2. 定义系统内的root密码、SSH免密登录、预安装软件包等；  

template使用方式：

1. 下载或复制`template`下的`Vagrant`模板文件

    curl -O https://raw.githubusercontent.com/get-set/myboxes/master/template/Vagrantfile

2. 根据需要调整虚拟机配置和provisioning
3. `vagrant up`
