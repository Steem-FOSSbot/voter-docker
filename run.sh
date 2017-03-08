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
    echo $CYAN"    build   - (re)builds docker"
    echo $CYAN"    start   - starts Voter in docker container"
    echo $CYAN"    bgstart - starts Voter in docker container in background process"
    echo $CYAN"    bgstop  - stops docker container if started with bgstart"
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
      echo $YELLOW"git not available, setup is still possible but updates are not"
      echo
      echo $YELLOW"To allow for automatic updating, please install git"
  else
    # if submodule repo already exists, make sure to stash any previous changes
    if [ -d "steem-fossbot-voter" ]; then
    	# check that user wants to continue to wipe any changes made to repo and update submodule
    	echo
    	echo $YELLOW"Continuing will remove any --code-- changes you made to the local copy of Voter"
    	echo $YELLOW"  NOTE that this does not include your algorithm or config, code changes only"
    	echo
    	echo $YELLOW"For normal usage this is safe"
    	while true; do
            echo -n $CYAN"Continue? (Y/n):"
	    	read steemusername

    		if [[ -z "$steemusername" ]]
            then
                echo $RED"Please answer the question"
                echo
            else
    			if [[ $steemusername == "n" ]]
    			then
    				echo
    				echo $YELLOW"Please do something with your changes, such as stashing them,"
    				echo $YELLOW"and then start config again"
            echo $RESET
    				exit
    			fi
                if [[ $steemusername == "Y" ]]
                then
                    break
                fi
                echo $RED"Please answer the question"
                echo
    		fi
    	done
    	cd steem-fossbot-voter
    	git reset --hard
    	cd ..
    	echo $CYAN"steem-fossbot-voter submodule changes have been reset, if any"
    	# update everything
      git submodule update --remote
    else
      git submodule init
      git submodule update --remote
    fi
  fi
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
  echo $CYAN"Please run ./run.sh build to create Docker deployment from set up files"
  echo $RESET
}

build() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"-= Build =-"
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
      echo $GREEN"-= Start =-"
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
    docker-compose up
}

bgstart() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"-= Background Start =-"
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
    nohup docker-compose up > /dev/null 2>&1 &
    echo
    echo $GREEN"Go to http://127.0.0.1:5000 with your browser to view the dashboard"
    echo $RESET
}

bgstop() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"-= Background Stop =-"
    else
      echo "Do not run as root, don't use sudo or su"
      echo $RESET
      exit
    fi
	echo $RED"bgstop command is not implemented yet!"
  # TODO : shaunmza, can you figure this out?
  echo $RESET
}


if [ "$#" -ne 1 ]; then
    help
fi

case $1 in
    setup)
        setup
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
    *)
        echo "Invalid cmd"
        help
        ;;
esac
