# 简介

自己平常用来测试的环境，通过vagrant管理。  

没有用自己的box，还是使用官网的ubuntu。使用官网ubuntu的好处是不用自己打box，方便保持box更新。  

template目录下为模板，创建其他环境时可以通过该模板复制来配置，包括：  
1. 定义虚拟机配置，主要参数为box、cpu个数、内存大小、private网络地址；  
2. 定义组名、root密码、预安装软件包等；  
3. 定时是否打开相应的provison：  
  * os_basic_setup：设置为true时，会根据不同的发行版，配置root密码、apt/yum源、pypi源、预安装等；  
  * root_sshpasswordless：设置为true时，会配置当前host到vm的ssh免密码登录；  
  * docker_provision：设置为true时，会安装docker并配置加速器；  
  * nodes_provision：设置为true时，会执行当前目录下的nodes-provision.sh，用于配置各节点独有的provisoning。  


# 虚拟机列表：

name & hostname | OS | IP | vCPUs | Memory | Directory | Notes
--- | --- | --- | --- | --- | ---
node[0-n] | ubuntu/xenial64 or centos/7 | 10.1.1.10[0-n] | 2 | 1536 | template | 模板，可复制来创建其他环境
dockernode[0-n] | ubuntu/xenial64 | 10.1.1.11[0-n] | 2 | 1536 | dockertest | Docker测试环境
devstack-mitaka | ubuntu/trusty64 | 10.1.1.101 | 4 | 8192 | devstacks | Deprecated
devstack-newton | ubuntu/xenial64 | 10.1.1.102 | 4 | 8192 | devstacks |
devstack-ocata | ubuntu/xenial64 | 10.1.1.103 | 4 | 8192 | devstacks |
rancherserver | ubuntu/xenial64 | 10.1.2.100 | 2 | 2048 | rancher | Rancher Server
ranchernode[1-n] | ubuntu/xenial64 | 10.1.2.10[1-n] | 2 | 1536 | rancher | Rancher节点测试环境
