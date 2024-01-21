# Docker 快速上手

## 常用命令

```shell
docker run -itd -p 8088:80 --name welcome-to-docker docker/welcome-to-docker:lastest        # 运行容器
```

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

### Dockerfile 内容
Dockfile 是用来构建镜像的配置文件，我们用它来定制镜像，内容格式样例如下：
```dockerfile
# Start your image with a node base image
FROM node:18-alpine

# The /app directory should act as the main application directory
WORKDIR /app

# Copy the app package and package-lock.json file
COPY package*.json ./

# Copy local directories to the current local directory of our docker image (/app)
COPY ./src ./src
COPY ./public ./public

# Install node packages, install serve, build the app, and remove dependencies at the end
RUN npm install \
    && npm install -g serve \
    && npm run build \
    && rm -fr node_modules

EXPOSE 3000

# Start the app using serve command
CMD [ "serve", "-s", "build" ]
```

#### 镜像构建上下文 ( build context )
我们看一个镜像构建命令：
```shell
docker build -t welcome-to-docker .
```
这里的 `.` 表示当前目录，也就是 `Dockerfile` 所在的目录。这个目录就是镜像构建的上下文，比如，Dockerfile 中的 COPY 命令，会从这个目录开始查找文件。
Dockerfile 就在当前目录，因此不少初学者以为这个路径是在指定 Dockerfile 所在路径，这么理解其实是不准确的。如果对应上面的命令格式，你可能会发现，这是在指定 上下文路径。怎么理解上下文呢？
首先我们要理解 docker build 的工作原理。Docker 在运行时分为 Docker 引擎（也就是服务端守护进程）和客户端工具。Docker 的引擎提供了一组 REST API，被称为 Docker Remote API，而如 docker 命令这样的客户端工具，则是通过这组 API 与 Docker 引擎交互，从而完成各种功能。因此，虽然表面上我们好像是在本机执行各种 docker 功能，但实际上，一切都是使用的远程调用形式在服务端（Docker 引擎）完成。也因为这种 C/S 设计，让我们操作远程服务器的 Docker 引擎变得轻而易举。
当我们进行镜像构建的时候，并非所有定制都会通过 RUN 指令完成，经常会需要将一些本地文件复制进镜像，比如通过 COPY 指令、ADD 指令等。而 docker build 命令构建镜像，其实并非在本地构建，而是在服务端，也就是 Docker 引擎中构建的。那么在这种客户端/服务端的架构中，如何才能让服务端获得本地文件呢？
这就引入了上下文的概念。当构建的时候，用户会指定构建镜像上下文的路径，docker build 命令得知这个路径后，会将路径下的所有内容打包，然后上传给 Docker 引擎。这样 Docker 
引擎收到这个上下文包后，展开就会获得构建镜像所需的一切文件。（如果目录下有些东西确实不希望构建时传给 Docker 引擎，那么可以用 .gitignore 一样的语法写一个 .dockerignore，该文件是用于剔除不需要作为上下文传递给 Docker 引擎的。）

如果在 Dockerfile 中这么写：
```dockerfile
COPY ./package.json /app/
```
这并不是要复制执行 docker build 命令所在的目录下的 package.json，也不是复制 Dockerfile 所在目录下的 package.json，而是复制 上下文（context） 目录下的 package.json。
因此，COPY 这类指令中的源文件的路径都是相对路径。这也是初学者经常会问的为什么 COPY ../package.json /app 或者 COPY /opt/xxxx /app 无法工作的原因，因为这些路径已经超出了上下文的范围，Docker 引擎无法获得这些位置的文件。如果真的需要那些文件，应该将它们复制到上下文目录中去。


### Dockerfile 命令详解
https://yeasy.gitbook.io/docker_practice/image/dockerfile
#### FROM 
`FROM` 命令用来指定基础镜像，这里我们使用的是 node:18-alpine 镜像，<名字>:<版本号> 的格式
除了这些常规镜像之外，有个叫 scratch 名字的镜像，这是一个空镜像，没有任何文件。如果你以 scratch 为基础镜像的话，意味着你不以任何镜像为基础，接下来所写的指令将作为镜像第一层开始存在。对于 Linux 
下静态编译的程序来说，并不需要有操作系统提供运行时支持，所需的一切库都已经在可执行文件里了，因此直接 FROM scratch 会让镜像体积更加小巧，比如很多纯 go 语言开发的应用。

#### WORKDIR
`WORKDIR` 命令用来指定工作目录，这里我们指定为 /app 目录，如果目录不存在，会自动创建。


#### COPY
`COPY` 命令用来复制文件，这里我们复制了 package.json 和 package-lock.json 文件，以及 src 和 public 目录。

`COPY` 命令有两种格式，分别是：
- COPY [--chown=<user>:<group>] <源路径>... <目标路径>              # 类似命令
- COPY [--chown=<user>:<group>] ["<源路径1>",... "<目标路径>"]      # 类似函数调用

#### RUN
`RUN` 指令用来执行命令，这里我们执行了 npm install 命令，安装了依赖包。

和 `COPY` 指令一样，`RUN` 指令也是那两种格式

#### EXPOSE
`EXPOSE` 指令用来指定端口，这里我们指定了 3000 端口。 
EXPOSE 仅仅是声明容器打算使用什么端口而已，并不会自动在宿主进行端口映射。
因此，如果想让外部进行访问，还需要在运行时通过 -p 参数来指定端口映射，或者通过 -P 参数来进行随机端口映射。

#### CMD
`CMD` 指令用来指定**容器启动时***要执行的命令，这里我们指定了 serve -s build 命令，也就是启动一个静态文件服务器。

Docker 不是虚拟机，容器中的应用都应该以前台执行，而不是像虚拟机、物理机里面那样，用 systemd 去启动后台服务，容器内没有后台服务的概念。
因此，Dockerfile 中的 CMD 指令，应该写为应用的启动命令，而不是后台服务的启动命令。比如，有些初学者可能会这么写：
```dockerfile
CMD service nginx start
```
然后发现容器执行后就立即退出了。甚至在容器内去使用 systemctl 命令结果却发现根本执行不了。这就是因为没有搞明白前台、后台的概念，没有区分容器和虚拟机的差异，依旧在以传统虚拟机的角度去理解容器。  

对于容器而言，其启动程序就是容器应用进程，容器就是为了主进程而存在的，主进程退出，容器就失去了存在的意义，从而退出，其它辅助进程不是它需要关心的东西。  

而使用 `service nginx start` 命令，则是希望 init 系统以后台守护进程的形式启动 nginx 服务。而刚才说了 `CMD service nginx start` 会被理解为 CMD [ "sh", "-c", "service nginx start"]，因此主进程实际上是 sh。那么当 `service nginx start` 命令结束后，sh 也就结束了，sh 作为主进程退出了，自然就会令容器退出。
正确的做法是直接执行 nginx 可执行文件，并且要求以前台形式运行。比如：
```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

CMD 是容器启动时执行程序的命令，如果在 Dockerfile 中写了多个 CMD 指令，只有最后一个 CMD 指令会生效。

#### ENTRYPOINT
ENTRYPOINT 的格式和 RUN 指令格式一样，分为 exec 格式和 shell 格式。
ENTRYPOINT 的目的和 CMD 一样，都是在指定容器启动程序及参数。ENTRYPOINT 在运行时也可以替代，不过比 CMD 要略显繁琐，需要通过 docker run 的参数 --entrypoint 来指定。
当指定了 ENTRYPOINT 后，CMD 的含义就发生了改变，不再是直接的运行其命令，而是将 CMD 的内容作为参数传给 ENTRYPOINT 指令，换句话说实际执行时，将变为：
```dockerfile
<ENTRYPOINT> "<CMD>"
```

### Dockerfile 多阶段构建
Dockerfile 支持多阶段构建，这是一个高级特性，可以让我们更加灵活的构建镜像。比如，我们可以在一个 Dockerfile 中，既安装构建工具，又安装运行时依赖，最后编译出发布用的产物，而且不用担心构建出来的镜像会比较臃肿，因为我们可以精确地复制某个阶段的产物，而忽略掉其它阶段。
这种 Dockerfile 我们通常可以看到，包含多个 FROM 指令，每个 FROM 指令都会引用不同的基础镜像，并且可以使用 COPY --from=<stage> 指令从其它阶段复制文件. <stage> 
是阶段的名称或者数字（从0开始）


## 运行多个容器的应用

`docker compose` 命令用于运行多个容器的应用，它的配置文件是 `docker-compose.yml` ，或者是 `compose.yaml` 。通常都是在有这个文件的目录下，执行 `docker compose  up` 命令。当然，也可以使用 `-f` 参数指定配置文件的路径。

```shell
docker compose up -d  # 以后台模式启动并创建服务
```

`-d` 参数表示后台运行

其他的常用命令有：

```shell
docker compose up      # 启动并创建您的服务，如果服务不存在则会先构建服务
docker compose up -d   # 以后台模式启动并创建服务
docker compose down    # 停止并删除正在运行的服务
docker compose ps      # 显示正在运行的服务
docker compose logs    # 查看服务的日志输出
docker compose logs <service_name>   # 查看指定服务的日志输出
docker compose exec <service_name> <command>   # 在正在运行的服务中执行命令

docker compose watch   # 监视文件变化并重新启动服务。在开发环境中非常有用，可以自动重启服务。
```


## 使用 volumes 来持久化容器中的文件

见 例子 multi-container-app 中的 compose.xml 文件中对 volumes 的声明 和 引用


## 使用 bind mount 从容器访问宿主机文件

```yaml
services:
  todo-app:
    build:
      context: ./app
    links:
      - todo-database
    volumes: 
      - ./app:/usr/src/app
      - /usr/src/app/node_modules
    ports:
      - 3001:3001

  todo-database:
    image: mongo:6
    command: mongod --port 27018
    ports:
      - 27018:27018
```



这里的 "volumes" 元素中的 第一条指令将本地文件夹 "./app" 挂载到容器中的 "todo-app" 服务的 "/usr/src/app" 目录。

这种绑定挂载会覆盖容器中 "/usr/src/app" 目录的静态内容，并创建了所谓的开发容器。改变宿主机中 ./app 目录下的文件，也就是改变容器中的 /usr/src/app 中的文件

第二条指令 "/usr/src/app/node_modules" 阻止了绑定挂载覆盖容器中的 "node_modules" 目录，以保留容器中安装的软件包。
