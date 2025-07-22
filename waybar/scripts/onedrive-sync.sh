#!/bin/bash

if rclone sync ~/Documents onedrive:/Backup/Documents; then
	echo"✔"
else
  	echo "⚠"
fi
