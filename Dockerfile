FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM xterm-256color
WORKDIR /root

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install git ssh gpg zsh curl tmux vim
