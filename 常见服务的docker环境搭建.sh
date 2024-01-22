# docker 免 sudo 命令
sudo groupadd docker     # 添加docker用户组
sudo gpasswd -a $USER docker     # 将登陆用户加入到docker用户组中
newgrp docker     # 更新用户组
docker ps    # 测试docker命令是否可以使用sudo正常使用



# 其实官方文档中，很多都提供了 docker-compose.yml 文件，可以直接使用来搭建测试用的集群，更加方便
# 或者直接在 docker 仓库里面搜索，看简绍

FLINK_PROPERTIES="jobmanager.rpc.address: jobmanager"

# 注意，docker 命令可能都需要用 sudo 来执行
# 如果运行 docker 命令报错，可以先用 sudo 运行试试，看看是否是有同样的错误
# 比如：docker: Cannot connect to the Docker daemon at unix:///run/user/1102/docker.sock. Is the docker daemon running?.  这种，有可能就是当前用户不行，需要用 sudo

# 创建一个桥接网络，并且指定网段！！！
sudo docker network create -d bridge --subnet 172.250.0.0/16 my-dev-net

# 如果需要重用容器，只有第一次才需要用 docker run 命令，之后，都可以使用 docker start 来启动已经建好的容器
# docker stop 停止已经启动的容器

# 启动一个 flink jobmanager , 官方命令中都带了 --rm 选项，stop 后会销毁容器，容器一次性使用
sudo docker run \
    -itd \
    --name jobmanager \
    --network my-dev-net \
    --publish 8081:8081 \
    --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
    flink jobmanager
    
# 启动多个 flink taskmanager
sudo docker run \
    -itd \
    --name taskmanager-1 \
    --network my-dev-net \
    --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
    flink taskmanager

sudo docker run \
    -itd \
    --name taskmanager-2 \
    --network my-dev-net \
    --env FLINK_PROPERTIES="${FLINK_PROPERTIES}" \
    flink taskmanager


# 之后，这些容器都可以用 docker start 来启动，重用容器





# 创建 kafka 服务   docker镜像的tag可以不带，默认就是 latest，也可以自己选择喜欢的tag（代表版本）（其实latest也是一个普通的版本号而已，和其他的版本号没区别，镜像id都可以是一个）
# 1. 建一个网络，名字  my-dev-net
#sudo docker network create my-dev-net --driver bridge
# 2. 启动 zookeeper
sudo docker run -itd --name zookeeper-server \
    --network my-dev-net \
    -p 2181:2181 \
    -e ALLOW_ANONYMOUS_LOGIN=yes \
    bitnami/zookeeper:latest

# 3. 启动 kafka 实例
sudo docker run -itd --name kafka-server \
    --network my-dev-net \
    -p 9092:9092 \
    -e ALLOW_PLAINTEXT_LISTENER=yes \
    -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper-server:2181 \
    bitnami/kafka:latest

# 在本地连接远程 docker 上的 kafka 时，可能会报错，host unknown，在 hosts 文件中添加一条对应的记录即可





# 其他的服务
#sudo docker run -itd --name es --net somenetwork -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node"  elasticsearch:tag
# es 去看官方文档！ 


sudo docker run -itd --name es --net my-dev-net -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.17.0

sudo docker run -itd --name sentinel-dashboard -p 8858:8858 bladex/sentinel-dashboard

sudo docker run -itd --name nacos-server -e MODE=standalone -p 8848:8848 nacos/nacos-server

sudo docker run -itd --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 8000:9000 sonarqube:lts

sudo docker run -itd --name redis -p 6379:6379 redis
sudo docker run -d --name myredis -p 6379:6379 redis --requirepass "mypassword"

sudo docker run -itd --name grafana -p 3000:3000 grafana/grafana

# podman 安装不同版本的 redis，指定不同的端口号（可以不指定密码）
# redis 5, 6379 端口号对外暴漏为 6375
podman run -d --name redis-5 -p 6375:6379 redis:5.0.14 --requirepass "123456"
# redis 6, 6379 端口号对外暴漏为 6376
podman run -d --name redis-6 -p 6376:6379 redis:6.2.11 --requirepass "123456"
# redis 7, 6379 端口号对外暴漏为 6377
podman run -d --name redis-7 -p 6377:6379 redis:7.0.10 --requirepass "123456"

# podman 安装 percona 5.7， 指定密码和端口号 3305
podman run -itd --name percona-5.7 -p 3305:3306 -e MYSQL_ROOT_PASSWORD=123456 percona:5.7
# podman 安装 mysql 8， 指定密码和端口号 3308
# 下面这个命令 podman 在 linux 普通用户下运行 mysql 8 好像有权限问题，用 root 用户运行就没问题了 （麻蛋，浪费时间！！）
podman run -itd --name MySQL-8 -p 3308:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:latest



# MongoDB
sudo docker run -itd --name mongo -p 27017:27017 mongo --auth
# sudo docker exec -it mongo mongo admin
# 添加用户
# db.createUser({ user:'admin',pwd:'123456',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]});
# 尝试使用上面创建的用户信息进行连接。
# db.auth('admin', '123456')


sudo docker run -itd --name PostgreSQL -p 5432:5432 -e POSTGRES_PASSWORD=123456 postgres:latest

sudo docker run -itd --name hadoop -p 8042:8042 -p 8088:8088 -p 19888:19888 -p 50070:50070 -p 50075:50075 -p 9000:9000 harisekhon/hadoop

# 需要的话，在本地磁盘上建个数据目录，挂载到容器上
mkdir $HOME/data/clickhouse_data
sudo docker run -itd --name clickhouse-server --ulimit nofile=262144:262144 --volume=$HOME/data/clickhouse_data:/var/lib/clickhouse -p 8123:8123 -p 9100:9000 yandex/clickhouse-server 


## 以下是一些常用的命令
# 查看容器日志
sudo docker logs {{容器ID 或者 容器名}}

# 进入容器的命令行
sudo docker exec -it {{容器ID 或者 容器名}} bash


# 重启容器
sudo docker restart {{容器ID 或者 容器名}}
# 停止容器
sudo docker stop {{容器ID 或者 容器名}}
# 启动容器
sudo docker start {{容器ID 或者 容器名}}



# 重启 docker 服务
sudo systemctl daemon-reload && sudo systemctl restart docker



/etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://ustc-edu-cn.mirror.aliyuncs.com",
    "https://mirror.ccs.tencentyun.com",
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://dockerhub.azk8s.cn",
    "https://registry.docker-cn.com"
  ],
  "live-restore": true,
  "group": "docker"
}


# Linux 打开/关闭 端口命令
# 一、查看哪些端口被打开
netstat -anp

# 二、关闭端口号:
iptables -A OUTPUT -p tcp --dport 端口号 -j DROP

# 三、打开端口号：
iptables -A INPUT -ptcp --dport  端口号 -j ACCEPT

# 四、保存设置
service iptables save

# 五、以下是linux打开端口命令的使用方法。
　　nc -lp 23 &    # (打开23端口，即telnet)
　　netstat -an | grep 23 # (查看是否打开23端口)
# 六、linux 打开端口命令每一个打开的端口，都需要有相应的监听程序才可以

