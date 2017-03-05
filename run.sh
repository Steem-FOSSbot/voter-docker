#!/bin/bash
#
# voter-docker
# A docker deployment management script for SteemFOSSbot Voter,
# based completely on @shaunmza 's tutorial post:
#     https://steemit.com/bots/@shaunmza/dockerizing-the-steem-fossbot
#
# Script and support written by thrize AKA @personz
#
# This script structure copied from steem-docker run.sh script by
# @someguy123, available at https://github.com/Someguy123/steem-docker
#

# DEVELOPMENT VERSION
#
# Note this should be called
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
    echo $CYAN"    setup - first time set up"
    echo $CYAN"    build - (re)builds docker"
    echo $CYAN"    start - starts Voter in docker container"
    echo $CYAN"    bgstart - starts Voter in docker container in background process"
    echo $CYAN"    stop - stops docker container"
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
    git submodule init
    git submodule update
    
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
    	# TODO : change this branch to docker-master for release
    	git pull origin docker-develop
    	cd ..
    	echo $CYAN"steem-fossbot-voter submodule changes have been reset, if any"
    	# update everything first
    fi
  fi
  echo
	echo $GREEN"Running Voter docker config..."
	echo
	chmod +x ./steem-fossbot-voter/docker-config.sh
	chmod 755 ./steem-fossbot-voter/docker-config.sh
    cd steem-fossbot-voter 
	./docker-config.sh
    cd ..
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
	  docker-compose build
    echo $GREEN"Voter is now bulid as a Docker deployment"
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
    nohup docker-compose up > /dev/null 2>&1 &
    echo
    echo $GREEN"Go to http://127.0.0.1:5000 with your browser to view the dashboard"
    echo $RESET
}

stop() {
    if [ "$EUID" -ne 0 ]
      then
      echo $GREEN"-= Stop =-"
    else
      echo "Do not run as root, don't use sudo or su"
      echo $RESET
      exit
    fi
	echo $RED"Stop command is not implemented yet"
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
    stop)
        stop
        ;;
    *)
        echo "Invalid cmd"
        help
        ;;
esac
