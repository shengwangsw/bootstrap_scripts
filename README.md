# Bootstrap Scripts

The current repository stores scripts for bootstrapping OS (Operating System) with personal setup.

1. setup.sh: for macos and linux PC.
1. setup_rasp.sh: for raspbian.

## Run
If you already have curl, you can simply run
### Linux or Macos
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shenggwang/bootstrap_scripts/main/setup.sh)"
```
### Raspberry pi
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/shenggwang/bootstrap_scripts/main/setup_rasp.sh)"
```
### Docker container
#### build
* no cache to force a clean build
* tag the container with given name
```shell
docker build https://raw.githubusercontent.com/shenggwang/bootstrap_scripts/main/Dockerfile --no-cache --tag per_dev:1.0
```
#### run
* Run ubuntu image with name per_dev
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
docker exec --interactive --tty --workdir /root per_dev bash -c "$(curl -fsSL https://raw.githubusercontent.com/shenggwang/bootstrap_scripts/main/setup.sh)"
```
#### get in to the terminal
```shell
docker exec --interactive --tty --workdir /root per_dev tmux new -s session
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
