#!/bin/bash
#
# Copyright Steem FOSSbot under GNU GLP v3
#
#
# voter-docker
# A docker deployment management script for SteemFOSSbot Voter,
# based completely on @shaunmza 's tutorial post:
#     https://steemit.com/bots/@shaunmza/dockerizing-the-steem-fossbot
#
# Script and support written by thrize AKA @personz
#
#
# Code modified from steem-docker on 4th March 2017, originally copyright Someguy123
#
# Original copyright message reads:
# Steem node manager
# Released under GNU AGPL by Someguy123
#
# ----------------------------------------
#
# DEVELOPMENT VERSION
#
# Note this should be executed
# git submodule add -b docker-develop https://github.com/Steem-FOSSbot/steem-fossbot-voter.git


BOLD="$(tput bold)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
RESET="$(tput sgr0)"


help() {
    echo $CYAN"Usage: $0 COMMAND"
    echo
    echo $CYAN"Commands: "
    echo $CYAN"    setup   - first time set up"
    echo $YELLOW"            must run setup as root, e.g. with sudo"
    echo $CYAN"    update  - update Voter code, keeping setup settings"
    echo $CYAN"    build   - (re)builds docker"
    echo $CYAN"    start   - starts Voter in docker container"
    echo $CYAN"    bgstart - starts Voter in docker container in background process"
    echo $CYAN"    bgstop  - stops docker container, use if started with bgstart"
    echo $CYAN"    logs    - shows logs, use if started with bgstart"
    echo $RESET
    exit
}

setup() {
	if [ "$EUID" -ne 0 ]
	  then echo $RED"Please run as root"
    echo $RESET
	  exit
	fi
	if ! git_loc="$(type -p "git")" || [ -z "$git_loc" ]; then
      echo $RED"git not installed, setup cannot run!"
      echo $YELLOW"Please install git"
      echo $RESET
      exit
  fi
  if ! dc_loc="$(type -p "docker-compose")" || [ -z "$dc_loc" ]; then
    echo $RED"docker-compose is not installed, setup cannot run!"
    echo $YELLOW"install docker-compose and then start again"
    echo $RESET
    exit
  fi
  git submodule init
  # if submodule repo already exists, make sure to stash any previous changes
  if [ -d "steem-fossbot-voter" ]; then
    cd steem-fossbot-voter
    fileexists="n"
    # check previous setup files exist
    if [ -e "Dockerfile" ]; then
      fileexists="Y"
    fi
    if [ -e "bot.sh" ]; then
      fileexists="Y"
    fi
    if [ -e "crontab" ]; then
      fileexists="Y"
    fi
    if [[ $fileexists == "Y" ]]
    then
    	# check that user wants to continue to wipe any changes made to repo and update submodule
    	echo
    	echo $YELLOW"Continuing will remove any --code-- changes you made to the local copy of Voter"
    	echo $YELLOW"  NOTE that this does not include your algorithm or config, code changes only"
    	echo
    	echo $YELLOW"For normal usage this is safe"
    	while true; do
        echo -n $CYAN"Continue? (Y/n):"
      	read answer

    		if [[ -z "$answer" ]]
            then
                echo $RED"Please answer the question"
                echo
            else
    			if [[ $answer == "n" ]]
    			then
    				echo
    				echo $YELLOW"Please do something with your changes, such as stashing them,"
    				echo $YELLOW"and then start config again"
            echo $RESET
            cd ..
    				exit
    			fi
          if [[ $answer == "Y" ]]
          then
              echo $YELLOW
              rm Dockerfile
              rm bot.sh
              rm crontab
              break
          fi
          echo $RED"Please answer the question"
          echo
    		fi
    	done
    fi
    echo $GREEN"Updating Voter code..."
    echo $CYAN
    git reset --hard
    echo $CYAN"steem-fossbot-voter submodule changes have been reset, if any"
    cd ..
  else
    echo $GREEN"Updating Voter code..."
  fi
  # update everything
  git submodule update --remote
  echo
	echo $GREEN"Running Voter docker config..."
	echo
	chmod +x ./steem-fossbot-voter/docker-config.sh
	chmod 755 ./steem-fossbot-voter/docker-config.sh
  cd steem-fossbot-voter 
  echo $RESET
	./docker-config.sh
  cd ..
  echo $GREEN"Voter docker config finished!"
  echo
  echo $YELLOW"Do you want to build the Docker deployment now?"
  while true; do
    echo -n $CYAN"Build? (Y/n):"
    read answer

    if [[ -z "$answer" ]]
    then
      echo $RED"Please answer the question"
      echo
    else
      if [[ $answer == "n" ]]
      then
        echo
        echo $CYAN"Please run ./run.sh build to create Docker deployment from set up files"
        break
      fi
      if [[ $answer == "Y" ]]
      then
        echo $RESET
        echo $RESET
        docker-compose build
        echo $GREEN"Assuming no errors, Voter is now bulid as a Docker deployment"
        echo $CYAN"Use the start or bgstart commands to start the container"
        break
      fi
      echo $RED"Please answer the question"
      echo
    fi
  done
  echo $RESET
}

update() {
  if [ "$EUID" -ne 0 ]
    then echo $RED"Please run as root"
    echo $RESET
    exit
  fi
  if ! git_loc="$(type -p "git")" || [ -z "$git_loc" ]; then
    echo $RED"git not installed, update cannot run!"
    echo $YELLOW"Please install git"
    echo $RESET
    exit
  fi
  if ! dc_loc="$(type -p "docker-compose")" || [ -z "$dc_loc" ]; then
    echo $RED"docker-compose is not installed, update cannot run!"
    echo $YELLOW"install docker-compose and then start again"
    echo $RESET
    exit
  fi
  # check Voter code folder exists
  if ! [ -d "steem-fossbot-voter" ]; then
    echo $RED"steem-fossbot-voter is not initialized, update cannot run!"
    echo $YELLOW"run ./run.sh setup instead"
    echo $RESET
    exit
  fi
  cd steem-fossbot-voter
  # check files exist
  if ! [ -e "Dockerfile" ]; then
    echo $RED"steem-fossbot-voter integrety issue (missing Dockerfile), update cannot run!"
    echo $YELLOW"run ./run.sh setup instead"
    echo $RESET
    exit
  fi
  if ! [ -e "bot.sh" ]; then
    echo $RED"steem-fossbot-voter integrety issue (missing bot.sh), update cannot run!"
    echo $YELLOW"run ./run.sh setup instead"
    echo $RESET
    exit
  fi
  if ! [ -e "crontab" ]; then
    echo $RED"steem-fossbot-voter integrety issue (missing crontab), update cannot run!"
    echo $YELLOW"run ./run.sh setup instead"
    echo $RESET
    exit
  fi
  # copy files
  echo $CYAN"copying setup files..."
  echo $RED
  cp Dockerfile ../Dockerfile_temp
  cp bot.sh ../bot_temp.sh
  cp crontab ../crontab_temp
  echo $YELLOW
  rm Dockerfile
  rm bot.sh
  rm crontab
  echo $CYAN"updating Voter code..."
  git reset --hard
  cd ..
  git submodule init
  git submodule update --remote
  echo $CYAN"restoring setup files..."
  cp Dockerfile_temp steem-fossbot-voter/Dockerfile
  cp bot_temp.sh steem-fossbot-voter/bot.sh
  cp crontab_temp steem-fossbot-voter/crontab
  rm Dockerfile_temp
  rm bot_temp.sh
  rm crontab_temp
  echo $GREEN"Voter docker update finished!"
  echo
  echo $YELLOW"Do you want to build the Docker deployment now?"
  while true; do
    echo -n $CYAN"Build? (Y/n):"
    read steemusername

    if [[ -z "$steemusername" ]]
    then
      echo $RED"Please answer the question"
      echo
    else
      if [[ $steemusername == "n" ]]
      then
        echo
        echo $CYAN"Please run ./run.sh build to create Docker deployment from set up files"
        break
      fi
      if [[ $steemusername == "Y" ]]
      then
        echo $RESET
        echo $RESET
        docker-compose build
        echo $GREEN"Assuming no errors, Voter is now bulid as a Docker deployment"
        echo $CYAN"Use the start or bgstart commands to start the container"
        break
      fi
      echo $RED"Please answer the question"
      echo
    fi
  done
  echo $RESET
}

build() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"Build..."
    else
      echo $RED"Do not run as root, don't use sudo or su"
      echo $RESET
      exit
    fi
    if ! dc_loc="$(type -p "docker-compose")" || [ -z "$dc_loc" ]; then
      echo $RED"docker-compose is not installed"
      echo $YELLOW"install docker-compose and then start again"
    fi
    echo $RESET
	  docker-compose build
    echo $GREEN"Assuming no errors, Voter is now bulid as a Docker deployment"
    echo $CYAN"Use the start or bgstart commands to start the container"
    echo $RESET
    exit
}

start() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"Start..."
    else
      echo $RED"Do not run as root, don't use sudo or su"
      echo $RESET
      exit
    fi
    if ! dc_loc="$(type -p "docker-compose")" || [ -z "$dc_loc" ]; then
      echo $RED"docker-compose is not installed"
      echo $YELLOW"install docker-compose and then start again"
      echo $RESET
      exit
    fi
    echo $GREEN"Starting docker in this process, you will need to type Ctrl+C to exit"
    echo
    echo $GREEN"When this process is up, go to http://127.0.0.1:5000 with your browser to view the dashboard"
    echo $CYAN"Press ENTER to continue..."
    read -n 1
    echo $RESET
    docker stop voterdocker_node_1
    docker stop voterdocker_redis_1
    docker-compose up
}

bgstart() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"Background start..."
    else
      echo $RED"Do not run as root, don't use sudo or su"
      echo $RESET
      exit
    fi
    if ! dc_loc="$(type -p "docker-compose")" || [ -z "$dc_loc" ]; then
      echo $RED"docker-compose is not installed"
      echo $YELLOW"install docker-compose and then start again"
      echo $RESET
      exit
    fi
    echo $RESET
    docker stop voterdocker_node_1
    docker stop voterdocker_redis_1
    nohup docker-compose up > /dev/null 2>&1 &
    echo
    echo $GREEN"Go to http://127.0.0.1:5000 with your browser to view the dashboard"
    echo $RESET
}

bgstop() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"Background stop..."
    else
      echo "Do not run as root, don't use sudo or su"
      echo $RESET
      exit
    fi
  echo $YELLOW"Stopping Voter docker..."
  echo $RESET
  docker stop voterdocker_node_1
  docker stop voterdocker_redis_1
  echo $GREEN"Stopped Voter docker"
  echo $RESET
}

logs() {
  if [ "$EUID" -ne 0 ]
    then
    echo $GREEN"Logs..."
  else
    echo "Do not run as root, don't use sudo or su"
    echo $RESET
    exit
  fi
  echo $RESET
  docker logs voterdocker_node_1
  docker logs voterdocker_redis_1
  echo $CYAN"--- end of logs"
  echo $RESET
}


if [ "$#" -ne 1 ]; then
    help
fi

case $1 in
    setup)
        setup
        ;;
    update)
        update
        ;;
    build)
        build
        ;;
    start)
        start
        ;;
    bgstart)
        bgstart
        ;;
    bgstop)
        bgstop
        ;;
    logs)
        logs
        ;;
    *)
        echo "Invalid cmd"
        help
        ;;
esac
