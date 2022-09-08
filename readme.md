# 作用
* 在win11上无侵入安装使用学习ros，含GUI与Gazebo

# 实现环境
* CPU：intel i7-12700F
* GPU：nvidia-3060ti
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
# 开机启动
sudo systemctl enable docker

# 如果不使用gazebo仿真，可直接执行如下命令
# 拉取镜像
sudo docker pull osrf/ros:foxy-desktop
# 启动镜像测试，注意--rm参数，退出后会自动删除容器
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name test osrf/ros:foxy-desktop

# 如果需要gazebo仿真，可通过本项目的Dockerfile构建镜像
cd ./win11_wsl2_docker_ros2_gui
sudo docker build -f Dockerfile -t ros2-foxy .

# 启动镜像测试，注意--rm参数，退出后会自动删除容器
sudo docker run -it --rm --net host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name test ros2-foxy
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