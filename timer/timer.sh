#! /bin/bash


start_date=$(date +%d-%m-%Y)
sec=0
min=0
hour=0
day=0
tmptime=0
nvidia_driver_version=$(nvidia-settings -q NvidiaDriverVersion | awk -F":" ' NR==3,NR==3 ' | awk -F" " '{print $4}')

while [[ true ]]; do
    clear
    ### lastcharOfSec ###
	len=`expr length $sec`
	lastcharOfSec=`expr substr $sec $len 1`
	#echo '$lastcharOfSec = '$lastcharOfSec

	### lastcharOfMin ###
	len=`expr length $min`
	lastcharOfMin=`expr substr $min $len 1`
	#echo '$lastcharOfMin = '$lastcharOfMin

	### lastcharOfHour ###
	len=`expr length $hour`
	lastcharOfHour=`expr substr $hour $len 1`
	#echo '$lastcharOfHour = '$lastcharOfHour

	### lastcharOfDay ###
	len=`expr length $day`
	lastcharOfDay=`expr substr $day $len 1`
	#echo '$lastcharOfDay = '$lastcharOfDay

	
	############# Склонение по падежам секунд ###############
	
	if (($lastcharOfSec == 0 || $sec >= 5 && $sec < 21 || $lastcharOfSec >= 5 && $lastcharOfSec <=9)); then
		tmpSec="$sec секунд"
		
	elif (($lastcharOfSec == 1 && $sec != 11)); then
		tmpSec="$sec секунда"
	
	elif (($sec >= 2 && $sec < 5 || $lastcharOfSec >= 2 && $lastcharOfSec < 5)); then
		tmpSec="$sec секунды"
	
	fi

	#########################################################

	############# Склонение по падежам минут ###############
	
	if (($lastcharOfMin == 0 || $min >= 5 && $min < 21 || $lastcharOfMin >= 5 && $lastcharOfMin <=9)); then
		tmpMin="$min минут"
		
	elif (($lastcharOfMin == 1 && $min != 11)); then
		tmpMin="$min минута"
	
	elif (($min >= 2 && $sec < 5 || $lastcharOfMin >= 2 && $lastcharOfMin < 5)); then
		tmpMin="$min минуты"

	fi

	########################################################

	############# Склонение по падежам часов ###############
	
	if (($lastcharOfHour == 0 || $hour >= 5 && $hour < 21)); then
		tmpHour="$hour часов"
		
	elif (($hour == 1 || $hour == 21)); then
		tmpHour="$hour час"
	
	elif (($hour > 1 && $hour < 5 || $hour > 21)); then
		tmpHour="$hour часа"

	fi

	########################################################

	############# Склонение по падежам дней ################

	if (($lastcharOfDay == 0 || $day >=5 && $day < 21 || $lastcharOfDay >= 5 && $lastcharOfDay <=9)); then
		tmpDay="$day дней"

	elif (($lastcharOfDay == 1 && $lastcharOfDay != 11)); then
		tmpDay="$day день"

	elif (($lastcharOfDay >= 2 && $lastcharOfDay < 5)); then
		tmpDay="$day дня"

	fi

	########################################################

	echo "$tmpDay $tmpHour $tmpMin $tmpSec" 

	#######################################################

	#################  Block of clock #####################
    sec=$(($sec+1))
    if [[ $sec -eq 60 ]]; then
    	sec=0
    	min=$(($min+1))
    	if [[ $min -eq 60 ]]; then
    		min=0
    		hour=$(($hour+1))
    		if [[ $hour -eq 24 ]]; then
    			hour=0
    			day=$(($day+1))
    		fi
    	fi
    fi
    #######################################################

    sleep 1
done