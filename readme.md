## 作用
* 在win11上无侵入安装使用学习ros，含GUI与Gazebo

## 官方镜像
* [https://hub.docker.com/r/osrf/ros](https://hub.docker.com/r/osrf/ros)

## 实现环境
* CPU：intel i7-12700F and i7-10700F
* GPU：nvidia-3060ti and nvidia-2060s
* SYSTEM：windows11-家庭中文版

## 使用方法
* 需右键点击开始（win11的logo）随后以管理员身份打开PowerShell
```shell
# 安装Ubuntu默认为20.04
wsl --install -d Ubuntu
# 安装完成需要重启，随后右键桌面打开终端，输入wsl，可能需要多尝试几次，我这里也尝试过再次运行上面的安装命令

# 进入wsl的ubuntu后，常规操作
sudo apt update
sudo apt upgrade

# 为WSL的Ubuntu安装显卡驱动
sudo apt install mesa-utils

# 测试
# 查看显卡信息
nvidia-smi
# 查看图形测试
glxgears

# 安装Docker
# 获取安装脚本
curl -fsSL get.docker.com -o get-docker.sh
# 执行安装脚本，需要等待一会
sh get-docker.sh
# 删除脚本文件
rm get-docker.sh
# 启动服务
sudo service docker start
# 开机启动【wsl里不怎么起作用】
sudo systemctl enable docker
```

## ROS环境
```shell
# 拉取ros镜像【版本可选】
sudo docker pull osrf/ros:melodic-desktop
sudo docker pull osrf/ros:foxy-desktop
sudo docker pull osrf/ros:galactic-desktop
# ！！！melodic-desktop-full含gazebo仿真、ros2下须自行安装！！！
sudo docker pull osrf/ros:melodic-desktop-full

# 临时启动测试【注意自己的镜像版本，--rm参数，退出后会自动删除容器】
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name test osrf/ros:melodic-desktop-full
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name test osrf/ros:foxy-desktop

# 官方镜像ros路径需要source
source /opt/ros/melodic/setup.bash
source /opt/ros/foxy/setup.bash
source /opt/ros/galactic/setup.bash
# 偷懒方式
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc
echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc

# 常规启动【无挂载目录】
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name ros-melodic-container osrf/ros:melodic-desktop-full
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name ros-foxy-container osrf/ros:foxy-desktop
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name ros-galactic-container osrf/ros:galactic-desktop

# 挂载目录启动【注意修改自己的路径】
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/root/ros_ws --name ros-melodic-container osrf/ros:melodic-desktop-full
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/root/ros_ws --name ros-foxy-container osrf/ros:foxy-desktop

# 查看容器状态
sudo docker ps -a

# 停止并删除容器
sudo docker stop ros-melodic-container && sudo docker rm ros-melodic-container
sudo docker stop ros-foxy-container && sudo docker rm ros-foxy-container

# 进入容器
sudo docker exec -it ros-melodic-container bash
sudo docker exec -it ros-foxy-container bash
```

## DockerGPU
```shell
# 添加源
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
# 安装toolkit
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
# 制作foxy镜像
sudo docker build -f Dockerfile.foxy -t ros-foxy .
# 使用GPU，进入容器后，可以正常使用'nvidia-smi'命令，Gazebo11不太行，GazeboGarden可以
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --gpus all --name test ros-foxy
# 完整命令
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/root/ros_ws --gpus all --name ros-foxy-container ros-foxy
```

## 自定义镜像【这里提供了阿里云软件源，其它的需求可以照葫芦画瓢】
```shell
# 进入目录【wsl默认挂载了win的磁盘，例如桌面路径为/mnt/c/Users/GYL88/Desktop】
cd ./win11_wsl2_docker_ros_gui
# 创建镜像【后面的点也要】
sudo docker build -f Dockerfile.melodic -t ros-melodic .
# foxy版本这时才安装了gazebo仿真
sudo docker build -f Dockerfile.foxy -t ros-foxy .

# 启动命令和上方的类似、将尾缀的镜像名换一下即可
osrf/ros:melodic-desktop-full -> ros-melodic
osrf/ros:foxy-desktop -> ros-foxy

# 查看镜像
sudo docker images

# 删除镜像
sudo docker rm ros-melodic
sudo docker rm ros-foxy

# 虚悬镜像
sudo docker image prune
```

## 使用硬件
```shell
# 如何通透到wsl
# win系统安装
winget install --interactive --exact dorssel.usbipd-win
# 使用时候可能需要更新并关机
wsl --update
wsl --shutdown
# wsl的linux安装
sudo apt install linux-tools-5.4.0-77-generic hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/5.4.0-77-generic/usbip 20
# win系统操作选择挂载设备
usbipd wsl list
usbipd wsl attach -b x-xx
usbipd wsl detach -b x-xx

# 挂载到wsl后，可自行使用docker参数挂载到ros容器上，network使用host后，can总线默认也可以挂上
sudo docker run -d -it --network host --restart=always --name=test --privileged -v /home/nvidia/Desktop/ros_ws:/root/ros_ws --device /dev/ttyUSB0:/dev/ttyUSB0 osrf/ros:foxy-desktop
```

## 其它命令
```shell
# 查看wsl里安装的子系统
wsl -l
# 删除wsl安装的子系统
wslconfig /u Ubuntu
# 重启子系统
wsl -t Ubuntu
```

## Ubuntu系统下的问题总结
* 仅在Ubuntu22.10上测试，测试系统无显卡
```shell
# Docker容器无法连接显示器
xhost +local:docker

# OpenGL报错加上这个配置
# --device /dev/dri
# 例如
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/root/ros_ws --device /dev/dri --name ros-galactic osrf/ros:galactic-desktop
```