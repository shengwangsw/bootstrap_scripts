# Bootstrap Scripts

The current repository stores scripts for bootstrapping OS (Operating System) with personal setup.

1. setup.sh: for macos and linux PC.
1. setup_rasp.sh: for raspbian.

## Run
If you already have curl, you can simply run
### Linux or Macos
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shengwangsw/bootstrap_scripts/main/setup.sh)"
```
### Raspberry pi
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shengwangsw/bootstrap_scripts/main/setup_rasp.sh)"
```
### Docker container
#### build
* no cache to force a clean build
* tag the container with a name (here we use per_dev)
```shell
docker build https://raw.githubusercontent.com/shengwangsw/bootstrap_scripts/main/Dockerfile --no-cache --tag per_dev:1.0
```
#### run
* Run Ubuntu image with the given name (per_dev)
* Detach to run container in background
* Interactive to make container waiting for input (not exiting)
* Volume mounted to ~/Personal in order to keep the data when the container is killed

``` shell
docker run --detach --interactive --hostname home.env --name per_dev --volume ~/Personal:/root per_dev:1.0
```
#### setup
* get into the container
* Interactive so we can make input
* TTY so we can receive output
* Workdir set to the container user path

``` shell
docker exec --interactive --tty --workdir /root per_dev bash -c "$(curl -fsSL https://raw.githubusercontent.com/shengwangsw/bootstrap_scripts/main/setup.sh)"
```
#### get in to the terminal
```shell
docker exec --interactive --tty --workdir /root per_dev tmux new -s session
```

#### Upgrade Ubuntu Major version
When a version of Ubuntu in the container reaches EoL, we can either build the image or upgrade it within the container.
The former is easier since the workspace is within a folder named `/Personal`. We won't lose data, only the settings.
The latter requires entering the container and upgrading it manually. Follow the below commands to achieve it.
```shell
docker exec -it per_dev /bin/bash
```
Within the container:
```shell
apt-get update
apt-get dist-upgrade
apt-get install -y update-manager-core

do-release-upgrade
apt-get autoremove -y
apt-get clean
```
Exit the container and run:
```shell
docker restart per_dev
```
To check the Ubuntu version:
```shell
lsb_release -a
cat /etc/os-release
```

### Docker clean up

#### stop image
```shell
docker stop per_dev
```
#### remove image
```shell
docker rm per_dev
```
#### check if container is removed
```shell
docker ps -a | grep per_dev
```
#### check dangling images
```shell
docker images -q -f dangling=true
```
#### remove dangling images
```shell
docker rmi $(docker images -q -f dangling=true)
```

## Config
* .zshrc
    * change ZSH_THEME
    * add alias for tmux mode
* execute to configure powerlevel10k
    ```shell
    p10k configure
    ```
* Reload tmux config
    * prefix + r
