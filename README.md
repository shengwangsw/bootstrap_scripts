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
```txt
* no cache to not look for cache builds of existing image layers and will force a clean build of the Docker image from the Dockerfile
```
```shell
docker build https://github.com/shenggwang/bootstrap_scripts/blob/main/Dockerfile --no-cache --tag per_dev:1.0
```
#### run
```txt
* Run ubuntu image with name per_dev
* Detach to run container in background
* Interactive to make container waiting for input (not exiting)
* Volume mounted to ~/Personal in order to keep the data when the container is killed
```
``` shell
docker run --detach --interactive --hostname home.env --name per_dev --volume ~/Personal:/root per_dev:1.0
```
#### setup
```txt
* get into the container
* Interactive so we can make input
* TTY so we can receive output
* Workdir set to the container user path
```
``` shell
docker exec --interactive --tty --workdir /root per_dev bash -c "$(curl -fsSL https://raw.githubusercontent.com/shenggwang/bootstrap_scripts/main/setup.sh)"
```
* execute
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
