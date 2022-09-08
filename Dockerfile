FROM osrf/ros:foxy-desktop

COPY ./sources.list /etc/apt/sources.list

RUN apt-get update

RUN apt-get install gazebo11 -y

WORKDIR /root
