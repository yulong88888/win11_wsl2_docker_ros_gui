# 作用
* 在win11上无侵入安装使用学习ros，含GUI与Gazebo

# 实现环境
* CPU：intel i7-12700F and i7-10700F
* GPU：nvidia-3060ti and nvidia-2060s
* SYSTEM：windows11-家庭中文版

# 使用方法
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

# ROS环境
```shell
# 拉取ros镜像【版本可选】
sudo docker pull osrf/ros:melodic-desktop
sudo docker pull osrf/ros:foxy-desktop
# 含gazebo仿真
sudo docker pull osrf/ros:melodic-desktop-full
sudo docker pull osrf/ros:foxy-desktop-full

# 临时启动测试【注意自己的镜像版本，--rm参数，退出后会自动删除容器】
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name test osrf/ros:melodic-desktop-full
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name test osrf/ros:foxy-desktop-full

# 官方镜像ros路径需要source
source /opt/ros/melodic/setup.bash
source /opt/ros/foxy/setup.bash
# 偷懒方式
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc

# 常规启动【无挂载目录】
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name ros-melodic-container osrf/ros:melodic-desktop-full
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name ros-foxy-container osrf/ros:foxy-desktop-full

# 挂载目录启动【注意修改自己的路径】
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/c/Users/GYL88/Desktop/ros_ws:/root/ros_ws --name ros-melodic-container osrf/ros:melodic-desktop-full
sudo docker run -it -d --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/c/Users/GYL88/Desktop/ros_ws:/root/ros_ws --name ros-foxy-container osrf/ros:foxy-desktop-full

# 查看容器状态
sudo docker ps -a

# 停止并删除容器
sudo docker stop ros-melodic-container && sudo docker rm ros-melodic-container
sudo docker stop ros-foxy-container && sudo docker rm ros-foxy-container

# 进入容器
sudo docker exec -it ros-melodic-container bash
sudo docker exec -it ros-foxy-container bash
```

# 自定义镜像【这里提供了阿里云软件源，其它的需求可以照葫芦画瓢】
```shell
# 进入目录【wsl默认挂载了win的磁盘，例如桌面路径为/mnt/c/Users/GYL88/Desktop】
cd ./win11_wsl2_docker_ros_gui
# 创建镜像【后面的点也要】
sudo docker build -f Dockerfile.melodic -t ros-melodic .
sudo docker build -f Dockerfile.foxy -t ros-foxy .

# 启动命令和上方的类似、将尾缀的镜像名换一下即可
osrf/ros:melodic-desktop-full -> ros-melodic
osrf/ros:foxy-desktop-full -> ros-foxy

# 查看镜像
sudo docker images

# 删除镜像
sudo docker rm ros-melodic
sudo docker rm ros-foxy

# 虚悬镜像
sudo docker image prune
```

# 其它命令
```shell
# 查看wsl里安装的子系统
wsl -l
# 删除wsl安装的子系统
wslconfig /u Ubuntu
# 重启子系统
wsl -t Ubuntu
```