# Vagrant虚拟机模板

> 以前本来以前是用来放各种虚拟机配置的，现在改成纯Vagrant模板了。

自己平常用来测试的环境，通过vagrant管理：

-  支持virtualbox和parallels
  - 如果使用parallels desktop的话，请安装插件：`vagrant plugin install vagrant-parallels`。
  - 如果使用virtualbox的话，请安装插件：`vagrant plugin install vagrant-hostmanager`。
- 自动创建非root用户，并配置免密登录。
- 可在`Vagrantfile`中配置IP，或通过DHCP分配IP
  - 如果通过DHCP分配IP，也可以将分配的IP固化到客户机的网络配置中（适用于不想操心IP池的管理，同时虚拟机中的服务需要固定IP地址的情况），支持CentOS7-8、CentOS Stream、Debian8-11、Ubuntu18-20
  - `vagrant-hostmanager`可以获取到IP地址并自动配置`hosts`文件，从而可以用主机名直接访问，互相免密。
- 可自定义是否启动嵌套虚拟化、是否应用链接克隆等。

**使用步骤：**

> 以virtualbox的使用为例。

1. 下载或复制`virtualbox`下的`Vagrant`模板文件

```bash
# github
curl -O https://raw.githubusercontent.com/get-set/myboxes/master/virtualbox/Vagrantfile

# gitee
curl -O https://gitee.com/get-set/myboxes/raw/master/virtualbox/Vagrantfile
```

2. 根据需要调整虚拟机配置和provisioning；
3. `vagrant up`。

**配置说明：**

没有用自己的box，还是使用官网的box，好处是不用自己打box，方便保持box更新。  

`virtualbox`和`parallels`目录下为模板，配置项包括： 

1. 定义虚拟机配置，主要参数为box、cpu个数、内存大小、private网络地址； 
2. 定义系统内的新创建的非root用户、预安装软件包等；  
3. 是否启动嵌套虚拟化、是否应用链接克隆、是否自动将DHCP变为STATIC。

