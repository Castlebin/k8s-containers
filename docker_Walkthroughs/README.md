# Docker 快速上手

## 运行 容器 ( container )
```shell
docker run -itd -p 8088:80 --name welcome-to-docker docker/welcome-to-docker:lastest
```
运行 docker 容器的命令是 `docker run`
    
    `-itd` 参数表示 交互式运行、分配一个伪终端、后台运行。  这是 i、t、d 三个参数的缩写。
    `-p` 参数表示端口映射，将容器内部的 80 端口映射到宿主机的 8088 端口。  
    `--name` 参数表示容器的名字，这里我们将容器命名为 welcome-to-docker 。
    `docker/welcome-to-docker:lastest` 表示镜像的名字和版本，前面是名字，`:` 后面是版本

其他常见的选项还有：
    
    `-e` 表示设置一个环境变量。在容器中使用 `echo $<env_name>` 可以查看环境变量的值。
    `-v` 表示挂载一个卷，将宿主机的目录挂载到容器中，容器中的文件会保存在宿主机的目录中。
    `-w` 表示设置容器的工作目录，容器中的命令会在这个目录下执行。
    `-u` 表示设置容器的用户，容器中的命令会以这个用户的身份执行。
    `-m` 表示设置容器的内存限制，单位是字节。
    `--cpus` 表示设置容器的 CPU 限制，单位是个数。
    `--network` 表示设置容器的网络模式，有 bridge、host、none 等模式。
    `--restart` 表示设置容器的重启策略，有 no、always、on-failure 等策略。
    `--privileged` 表示设置容器的特权模式，容器中的命令会以 root 用户的身份执行。
    `--rm` 表示容器退出时自动删除容器。
    `--link` 表示容器间的连接，可以让容器之间互相访问。
    `--add-host` 表示添加一个 host 到容器中，可以让容器访问这个 host 。
    `--dns` 表示设置容器的 DNS 服务器。
    `--dns-search` 表示设置容器的 DNS 搜索域名。
    `--dns-opt` 表示设置容器的 DNS 选项。
    `--entrypoint` 表示设置容器的入口点，可以覆盖镜像中的入口点。
    `--expose` 表示设置容器的端口，可以让容器监听这个端口。
    `--env-file` 表示设置容器的环境变量文件，可以从文件中读取环境变量。
    `--label` 表示设置容

## 构建 镜像 ( image )
构建镜像 ( image ) 的命令是 `docker build` ，需要你在工程目录下，有一个名为 `Dockerfile` 的文件，这个文件是构建镜像的配置文件。  
构建命令如下：
```shell
docker build -t <image_name> .
```
其中，`-t` 参数表示 tag ，是给镜像起一个名字 ，`.` 表示当前目录，也就是 `Dockerfile` 所在的目录。  

也可以再加上一个 `-f` 参数，指定 `Dockerfile` 的路径，如：
```shell
docker build -t <image_name> -f <Dockerfile_path> .
```

现在我们构建为 welcome-to-docker 工程建立同名镜像。进入项目目录下，执行 ：
```shell
docker build -t welcome-to-docker .
```



