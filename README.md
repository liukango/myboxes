# 简介

自己平常用来测试的环境，通过vagrant管理。  

没有用自己的box，还是使用官网的ubuntu。使用官网ubuntu的好处是不用自己打box，方便保持box更新。

其中.vagrant.d目录下的内容放到宿主机的~/.vagrant.d/下（用.vagrant.d/enable.sh建立软连接实现），用于进行公共的基础配置。所有用vagrant起的虚拟机都会首先合并~/.vagrant.d/Vagrantfile，这个Vagrantfile会利用shell的provision（.vagrant.d/scripts/bootstrap-ubuntu.sh）在官网box基础上进行基本配置：  
* 设置apt源和pypi源为国内镜像
* 解除远程ssh登录root限制，设置宿主机免密码登录

# 虚拟机列表：

| name | OS | hostname | IP | vCPUs | Memory | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| devstack-mitaka | ubuntu/trusty64 | devstack-mitaka | 10.1.1.101 | 4 | 8192 | Deprecated |
| devstack-newton | ubuntu/xenial64 | devstack-newton | 10.1.1.102 | 4 | 8192 | |
| devstack-ocata | ubuntu/xenial64 | devstack-ocata | 10.1.1.103 | 4 | 8192 | |
