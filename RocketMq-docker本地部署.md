# Apache RocketMQ

## 简介

Apache RocketMQ 是一个具有低延迟、高性能和高可靠性、万亿级容量和灵活的分布式消息和流平台。
本镜像基于`alpine:3.19`采用Apache RocketMQ官方已发布版本进行构建。

## 快速部署

本段指示如何快速的部署RocketMQ最新版容器。

### 拉取镜像

```shell
docker pull ochh/rocketmq:latest
```

### Docker命令部署

> <span style="color: red;">注意：需要替换命令中环境变量 `HOST_IP` 为自己本机IP，这个环境变量必须配置，否则应用程序连接不到broker</span>

```shell
# 创建卷
docker volume create rocketmq_data

# Linux 或 Mac
docker run -itd \
 --name=rocketmq \
 --restart=always \
 --hostname=alpine \
 -p 8080:8080 \
 -p 9876:9876 \
 -p 10909-10912:10909-10912 \
 -v rocketmq_data:/home/app/data \
 -v /etc/localtime:/etc/localtime \
 -e HOST_IP=本机IP \
 ochh/rocketmq:latest
 
 # Windows
 docker run -itd `
 --name=rocketmq `
 --restart=always `
 --hostname=alpine `
 -p 8080:8080 `
 -p 9876:9876 `
 -p 10909-10912:10909-10912 `
 -v rocketmq_data:/home/app/data `
 -v /etc/localtime:/etc/localtime `
 -e HOST_IP=本机IP `
 ochh/rocketmq:latest
```

### Docker Compose部署

```shell
version: "3"
services:
  rocketmq:
    image: ochh/rocketmq-test
    container_name: "rocketmq"
    restart: always
    hostname: alpine
    ports:
      - 8080:8080
      - 9876:9876
      - 10909-10912:10909-10912
    volumes:
      - "rocketmq_data:/home/app/data"
      - "/etc/localtime:/etc/localtime:ro"
    environment:
      HOST_IP: 本机IP

volumes:
  rocketmq_data:
    name: rocketmq_data
```

### 控制台

```text
管理员
帐号：admin
密码：admin

普通用户
帐号：normal
密码：normal
```