#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then 
	echo "Usage: $0 [IMAGE_NAME] [CONTAINER_NAME] [DEVEL FOLDER]"
	exit 0
fi 

if [[ ($# -eq 0 ) ]]
then
	echo "No arguments specified, using wizard mode"
	
	echo "Insert the absolute path of the dev folder [~/dev]"
	read dev_folder
	if [[ ($dev_folder -eq "") ]]
	then 
		dev_folder="/home/$USER/dev"
	fi
	if [ ! -d $dev_folder ] 
	then
		echo "[WARNING] devel folder doesn't exists, creating a new one"
		mkdir /home/$USER/dev
	fi
	echo dev folder: $dev_folder
	
	echo "Insert the image name [osrf/ros:noetic-desktop]"
	read im_name
	if [[ ($im_name -eq "") ]]
	then 
		im_name=osrf/ros:noetic-desktop
	fi
	
	echo "Image name: " $im_name
	
	echo "Insert the name of the container"
	read container_name
	
	for c in $(docker container ls -a --format '{{.Names}}')
	do
		if [ $container_name == $c ] 
		then
			echo "[ERROR] Name already used for a container, exiting"
			exit 0
		fi
	done
else
	im_name=$1
	container_name=$2
	dev_folder=$3
fi

echo -e "\n\nCreating a new container" 
echo "Docker Image ... " $im_name
echo "Container name ... " $container_name
echo "Developer folder ... " $dev_folder

xhost +

docker run -it --privileged -v /dev/bus/usb:/dev/bus/usb \
-v $dev_folder:/home/dev/:rw \
-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
-e DISPLAY=$DISPLAY \
--network host \
--workdir="/home/dev/" \
--name=$container_name $im_name bash



