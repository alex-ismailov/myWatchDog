#! /bin/bash


# Дата запуска
# telegram bot
# MESSAGE="$rig_name started "$(date +%d-%m-%Y)" at "$(date  +%H:%M) 
# URL="https://api.telegram.org/bot$TOKEN/sendMessage"
# curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"

start_date=$(date +%d-%m-%Y)
sec=0
min=0
hour=0
day=0
tmptime=0
nvidia_driver_version=$(nvidia-settings -q NvidiaDriverVersion | awk -F":" ' NR==3,NR==3 ' | awk -F" " '{print $4}')

while [[ true ]]; do
	clear

	###########  time counter  #####################

	$tmptime=$(($sec + 1))
	echo 'time counter = '$tmptime


	################################################
	
	echo 'Rig startup: '$start_date' at '$(date  +%H:%M)
	echo

	echo 'DriverVersion: '$nvidia_driver_version
	echo

	graphics_clock=$(nvidia-settings -t -q [gpu:0]/GPUCurrentClockFreqs | awk -F"," '{print $1}')
	echo 'Graphics Clock = '$graphics_clock' MHz'
	echo	

	memory_transfer_rate=$(nvidia-settings -t -q [gpu:0]/GPUCurrentClockFreqs | awk -F"," '{print $2}')
	echo 'Memory Transfer Rate = '$(($memory_transfer_rate * 2))' MHz'
	echo	

	gpucore_temp=$(nvidia-settings -t -q [gpu:0]/GPUCoreTemp)
	echo 'GPU Core Temp = '$gpucore_temp'*C'
	echo	

	gpu_power_mizer_mode=$(nvidia-settings -q [gpu:0]/GPUPowerMizerMode |  awk -F":" ' NR==2,NR==2 ' | awk -F" " '{print $4}' | awk -F"." '{print $1}')
	echo 'GPU Power Mizer Mode: '$gpu_power_mizer_mode
	echo

	sleep 1
done

#sleep 20
