# 简介

自己平常用来测试的环境，通过vagrant管理。  

没有用自己的box，还是使用官网的ubuntu。使用官网ubuntu的好处是不用自己打box，方便保持box更新。


# 虚拟机列表：

name | OS | hostname | IP | vCPUs | Memory | Directory | Notes
--- | --- | --- | --- | --- | --- | ---
node[0-n] | ubuntu/xenial64 or centos/7 | node[0-n]| 10.1.0.10[0-n] | 2 | 1536 | template | 模板，可复制来创建其他环境
docker-node[0-n] | ubuntu/xenial64 | docker-node[0-n]| 10.1.0.11[0-n] | 2 | 1536 | dockertest | Docker测试环境
devstack-mitaka | ubuntu/trusty64 | devstack-mitaka | 10.1.1.101 | 4 | 8192 | devstacks | Deprecated
devstack-newton | ubuntu/xenial64 | devstack-newton | 10.1.1.102 | 4 | 8192 | devstacks |
devstack-ocata | ubuntu/xenial64 | devstack-ocata | 10.1.1.103 | 4 | 8192 | devstacks |
