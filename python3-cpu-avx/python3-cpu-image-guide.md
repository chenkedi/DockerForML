#一、安装Docker
1. 参考官方文档，按步骤安装docker ce stable版：
https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce-1
2. 并按照下面的步骤，将自己的用户加入docker用户组：
https://docs.docker.com/engine/installation/linux/linux-postinstall/

#二、构建docker镜像
1、将icode中的python3-cpu-avx文件夹检出后，传输到服务器。
2、进入服务器上的python3-cpu-avx文件夹，执行以下命令：
```shell
docker build -t="iot-data/python3-cpu-avx" .
```
然后等待docker镜像构建完成。

#三、启动Docker镜像
1、执行如下命令，检查是否存在名字为iot-data/python3-cpu-avx的镜像：
```shell
docker images
```
2、存在的话，则以默认方式启动改镜像：
```shell
docker run -d -v /mnt:/mnt -p 8088:8088 iot-data/python3-cpu-avx
```
**注意**：-v参数中的第一个文件夹可以是服务器上的任意工作目录，目的是将该目录挂载到docker中，以做到环境和数据完全分离，第二个文件夹不可更改；-p参数的第一个端口号，可以根据当前服务器开发的端口号指定，第二个端口号不可更改。
3、若需要进入镜像内部进行运行shell，进行自定义操作，可以使用以下方式启动：
```shell
docker run -it -v /mnt:/mnt -p 8088:8088 --entrypoint /bin/bash iot-data/python3-cpu-avx
```
5、使用第二步骤中的方式启动后，则可以在任何一台电脑上的工作文件上传服务器，并访问服务器地址来进行使用了,密码为 “iotdata”
```url
http://your.server.ip:8088
```
四、关于Docker环境的完善
> 通过对项目中Dockerfile的更改，大家可以向我们的环境中添加目前没有的包，然后向icode中提交更改，然后拉取最新的Dockerfile进行增量构建，就可以快速得到的最新的统一的环境了。

>这种方式有以下几种优点：
1、不用存储巨大的镜像，而只要存储构建镜像的灵魂Dockerfile，就可以在任何一台安装了docker，并且有网络的机器上完美的复现我们的环境。
2、以git的方式管理我们的环境，对于环境的更改体现在对Dockerfile代码的版本管理上，让大家可以方便的同步更新后的环境。
