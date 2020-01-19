#! /bin/bash

#Включение/выключение watchdog. Отключить: watch_dog=0. Мониторинг будет происходить, но перезагрузка отключена
watch_dog=1
rig_name="Rig1"
TOKEN=xxx
CHAT_ID=xxx

numberofgpu=`nvidia-smi -L | wc -l` #how many GPU do you have
nvidia_driver_version=$(nvidia-settings -q NvidiaDriverVersion | awk -F":" ' NR==3,NR==3 ' | awk -F" " '{print $4}')
min_using=90
temp_limit=50
error_level=15
pause=1 # in seconds

error_state=0
error_count=0

start_date="$(date +%d-%m-%Y) в $(date  +%H:%M)"
sec=0
min=0
hour=0
day=0
tmptime=0

# telegram bot
# MESSAGE="$rig_name started "$(date +%d-%m-%Y)" at "$(date  +%H:%M) 
# URL="https://api.telegram.org/bot$TOKEN/sendMessage"
# curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
clear
while (true); do
    clear


    ####################### time counter  #############################

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

    echo ' +----------------------------------------------------------------------------+'
    echo ' |        	     	          Риг работает:			              |'
    echo ' |  	    		'$tmpDay $tmpHour $tmpMin $tmpSec		 
    echo ' |		      	       '$start_date'                     	      |'
    echo ' +----------------------------------------------------------------------------+'
    
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


    #######################################################







    echo ' |     	             	     Версия драйвера: '$nvidia_driver_version'		              |'
    echo ' +----------------------------------------------------------------------------+'
    
    # echo '+-----+-----------+-----------+-----------+---------+'
    # echo '| GPU | GPU Clock | Mem Clock | Core Temp | Voltage |'
    # echo '+-----+-----------+-----------+-----------+---------+'
    if [ $error_state -ne 0 ]; then
        error_count=$(( $error_count + 1 ))
    else
        error_count=0
    fi

    if [ $error_count -ne 0 ]; then
        echo ' |          		  	   WARNING!!!         	                      |'
        echo " |		  	    $error_msg		      |"
        echo ' +----------------------------------------------------------------------------+'

        if [ $watch_dog -eq 1 ]; then
            remain_in_cicle=$(( $error_level - $error_count ))
            remain_in_sec=$(( $remain_in_cicle * $pause ))
            if [ $remain_in_cicle -le 0 ]; then
                echo $(date +%d-%m-%Y)" в "$(date  +%H:%M)" $rig_name was rebooted, $error_msg" >> ~/WatchDogErrorLog.log
                
                # telegram bot send msg with description of problem
                # MESSAGE=$(date +%d-%m-%Y)" в "$(date  +%H:%M)"    $rig_name was rebooted, $error_msg" 
                # URL="https://api.telegram.org/bot$TOKEN/sendMessage"
                # curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
                clear

                echo
                echo
                echo ' +-------------------------------------------------------------+'
                echo ' |		    Your PC will be turn off  		      |'
                echo ' +-------------------------------------------------------------+'
                sleep 180
                #reboot
                break
                #####################################
            else
                echo ' |		    	   PC will be rebooted after  		              |'
                
                # костыль
                if [[ $remain_in_sec -lt 10 ]]; then
                    echo " |          		      	      $remain_in_sec  sec             	              |"
                else
                    echo " |          		      	      $remain_in_sec sec             	              |"
                fi
                echo ' +----------------------------------------------------------------------------+'
            fi
        else
            echo ' |         			   WD disabled       			      |' # Доделать !!!!!!
            echo ' +----------------------------------------------------------------------------+'
        fi
    else
        if [ $watch_dog -eq 1 ]; then
            ttmp=0
            #echo ' |          	          	   WD enabled 		                      |'
            #echo ' +----------------------------------------------------------------------------+'
        else
            echo ' |         			   WD disabled       			      |' # Доделать !!!!!!
            echo ' +----------------------------------------------------------------------------+'
        fi
    fi

    # echo ' +-------+-------------+-------------+-------------+-----------+--------------+'
    # echo ' |  GPU  |  GPU Clock  |  Mem Clock  |  Core Temp  |  Voltage  |  Fans Speed  |'
    # echo ' +-------+-------------+-------------+-------------+-----------+--------------+'

    echo ' +-----+-----------+-----------+-----------+-----------+---------+------------+'
    echo ' | GPU | GPU Clock | Mem Clock | Core Temp |  Voltage  |  Using  | Fans Speed |'
    echo ' +-----+-----------+-----------+-----------+-----------+---------+------------+'
    echo ' +----------------------------------------------------------------------------+'
    
    ################################ Внутренний цикл for ##############################
    error_state=0

    for (( i = 0; i < numberofgpu; i++ )); do
        
        ######### Проверяем отвечает ли карта, не отвалилась ли GPU ###################
        
        res_req=0
        temp=$(nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader,nounits)
        res_req=$?
        if [ $res_req -ne 0 ]; then
            error_state=1
            error_msg="    GPU$i does not RESPOND    "
            continue
        fi

        ####################### Температурный лимит карты #############################
        
        if [ $temp -ge $temp_limit ]
        then
            error_state=1
            error_msg=" GPU$i is OVERHEATING, t = $temp!"
            continue
        fi
        ##############################################################################

        ####################### Блок проверки загрузки карты #########################
        
        using=$(nvidia-smi -i $i --query-gpu=utilization.gpu --format=csv,noheader,nounits)
        if [ $using -lt $min_using ]
        then
            error_state=1
            if [[ $using -lt 10 ]]; then
                error_msg="   GPU$i low using = $using %      "
            else
                error_msg="   GPU$i low using = $using %     "
            fi
            
            continue
        fi
        ###############################################################################

        ####################### Graphics Clock #########################
        graphics_clock=$(nvidia-settings -t -q [gpu:0]/GPUCurrentClockFreqs | awk -F"," '{print $1}')
        #echo $graphics_clock

        #######################  Memory Clock  #########################
        memory_clock_tmp=$(nvidia-settings -t -q [gpu:0]/GPUCurrentClockFreqs | awk -F"," '{print $2}')
        memory_clock=$((memory_clock_tmp * 2))

        #######################  Power  #########################
        power=$(nvidia-smi -i 0 --format=csv,noheader --query-gpu=power.draw | awk -F"." '{print $1}')

        #######################  Fans speed  #########################
        fan_speed=$(nvidia-settings -t -q [fan:0]/GPUCurrentFanSpeed)

        #########################################################

        ############ Если все в порядке выводим в консоль показатели по картам ########
        
        if [[  $using -lt 100 ]]; then
            echo " |  $i  | $graphics_clock MHz  | $memory_clock MHz  |   $temp C    |   W$power W   |  $using  %  |     $fan_speed %   |" # Не забыть сделать правило для длины строки когда POWER 3х значный !!!!
        else
            echo " |  $i  | $graphics_clock MHz  | $memory_clock MHz  |   $temp C    |   W$power W   |  $using %  |     $fan_speed %   |"
        fi
        echo ' +----------------------------------------------------------------------------+'

        ###############################################################################
    done
    sleep $pause
done

 #    echo ' +-------+---------+-----------+-----------+---------+-------+-------+--------+'
 #    echo ' | GPU | GPU Clock | Mem Clock | Core Temp | Voltage | Using | Using |  Fans  |'
 #    echo ' +-------+---------+-----------+-----------+---------+-------+-------+--------+'