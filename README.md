# Elastic8-Lab
Ubuntu Setup Script and docker-compose to deploy elasticsearch 8 for lab use


THIS IS IN BETA PLEASE DO NOT USE JUST YET - Deploying the Elastic Stack can be difficult. This project hopes to simplify that.

### Initial Goal

Make it simple to deploy a full fledged Elastic Stack with advanced capabilities on a single vm using Docker.

### Long Term Goal

Contain scripts for easy deployment in a lab enviroment 

## Prerequisites
Install Ubuntu 22.04 or newer

```#Assumes you have downloaded and installed Ubuntu 22.04 minimum to start. Follow the rest of the steps below to configure and get up and running

# Once Ubuntu is insalled run update and upgrade commands to update system
sudo apt-get update -y && sudo apt-get upgrade -y

# Change to the working directory /opt
cd /opt

# Download the prerequisites script and run in bash
sudo wget https://github.com/slteksystemsllc/Elastic8-Lab/raw/main/setup.sh && sudo bash ./setup.sh
