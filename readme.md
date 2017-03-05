# voter-docker

A Docker deployment for [Steem FOSSbot Voter](https://github.com/Steem-FOSSbot/steem-fossbot-voter).

## What it is

This repository consists of Docker build files, and a convenience script ```run.sh``` to simplify the voter bot code update process, and configuring of the voter Docker build files.

Voter actually contains it's own script ```docker-config.sh``` which is called by ```run.sh```. The script sets up the voter environment variables from user prompted settings, which is similar to what you will find in the _Create Server_ section of the Voter [installation instructions](https://github.com/Steem-FOSSbot/steem-fossbot-voter/blob/docker-develop/docs/installation.md#create-server).

So essentially this repo ties it all together without you having to have direct contact with the [steem-fossbot-voter GitHub repo](https://github.com/Steem-FOSSbot/steem-fossbot-voter), it's automatically taken care of.

## Requirements

The helper script ```run.sh``` only runs on modern Linux (such as Ubuntu) or Mac OS X.

_If you would like to port the script to Windows batch file, please make a pull request!_

## Installation

### Without git

_Note that though better for non-developers, the advantage of using ```git``` is that you will get automatic updates of the Voter app when you rebuild the Docker, so it is highly recommended._

1. All you have to do is download a copy of this repository and unzip to any folder, and follow use usage instructions below.

### With git

Clone this repository with

```git clone https://github.com/Steem-FOSSbot/voter-docker.git```

Follow the usage guide as normal, git processes are automatically handled.

## Usage

_Regardless of how you installed the software._

Use the ```run.sh``` script for all operations. To run this in a terminal, navigate to the project folder, and type ```./run.sh COMMAND```, where ```COMMAND``` is one of the commands provided.

You should run setup and build first.

Note that build, start, bgstart and bgstop commands all require that Docker (i.e. the Docker daemon) is started and running.

### ./run.sh **setup**

Run this the first time, and any time you want to update if you have ```git``` installed.

It will configure the Voter Docker scripts with your chosen environment variables. This variables are the custom information the Voter app needs to run on your Steem account.

You will be asked for:

1. Cookie Secret
2. Bot API key
3. Your Steem username
4. Your Steem private posting key
5. How often you want the voter bot to run (e.g. every hour, or half hour, etc.)

### ./run.sh **build**

Run this command only after setup.

It will build the Docker instance from the config files, and will take a while to complete.

You will not be prompted as it runs.

### ./run.sh **start** _and_ ./run.sh **bgstart**

Starts the Docker instance and causes the bot to begin operation. This will start the dashboard web app interface at URL http://127.0.0.1:5000 and the bot will automatically run at the times you have configured in the setup.

If you use **bgstart** it will run as a background process, freeing up your terminal. However note that if on Mac, closing the terminal will end this process.

Please see:

- the [dashboard guide](https://github.com/Steem-FOSSbot/steem-fossbot-voter/blob/docker-develop/docs/dashboard-overview.md) for dashboard usage instructions
- the general [usage guide](https://github.com/Steem-FOSSbot/steem-fossbot-voter/blob/docker-develop/docs/usage-guide.md) to get started configuring the bot to vote as you like

### ./run.sh **bgstop**

If you used ```./run.sh bgstart``` then ```./run.sh bgstop``` to stop it, as it runs as a background service.

If you used ```./run.sh start``` you should just stop the bot by using Ctrl+C or closing the terminal.

## Acknowledgement, attribution and notices

This is based on Docker instructions tutorial by @shaunmza available on [Steemit here](https://steemit.com/bots/@shaunmza/dockerizing-the-steem-fossbot).

Special thanks to @someguy123 's great [steem-docker](https://github.com/Someguy123/steem-docker) project, of which the ```run.sh``` portion of this project is largely based. As per it's [license](https://github.com/Someguy123/steem-docker/blob/master/LICENSE), I am obliged to state the following:

[```run.sh```](https://github.com/Someguy123/steem-docker/blob/master/run.sh) in steem-docker was first modified on 4th March 2017 to create ```run.sh``` here in this project. Any further modifications of the source here will not be explicitly noted but are assumed read as git history.

Additionally we are forced to license this project under the same license, GNU GPL v3, and it is copyright to the organisation Steem FOSSbot.