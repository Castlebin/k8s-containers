# 解决 云主机上 docker 启动后，ssh登录不上云主机的问题
# 修改 /etc/docker/daemon.json 中的 bip 为合适的网段，不要和机器冲突，比如："bip": "172.255.0.1/24",
# 下面命令中的网段一样 
# docker0 、 br-0baaa52538aa、br-d57c26cdaedb、br-54b657eb626c 都是 docker 的网卡地址，根据自己的实际情况，统统处理


# 执行以上命令，停止 docker，删除网络。确实能登录上机器了，但是！一启动 docker，就断了！
# 下面的4行也可以
sudo ip link del docker0
sudo ip link del br-0baaa52538aa
sudo ip link del br-d57c26cdaedb
sudo ip link del br-54b657eb626c


# 主要靠 下面的操作！
sudo docker network rm xxxxx        # 删除所有创建的网络 或者
sudo docker network prune           # 删除所有不用的网络

# 创建 docker 网络，指定网段，不要冲突，自动创建的可能会冲突，或者还是沿用之前的老旧设置
# 创建一个桥接网络，并且指定网段！！！
sudo docker network create -d bridge --subnet 172.250.0.0/16 my-dev-net

# 好像就可以了，yeah！

