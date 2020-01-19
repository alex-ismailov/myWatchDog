#! /bin/bash


echo "Fan Speed Control script started"

#Включение/выключение watchdog. Отключить: watch_dog=0. Мониторинг будет происходить, но перезагрузка отключена
watch_dog=1

TOKEN=xxx
CHAT_ID=xxx

numberofgpu=`nvidia-smi -L | wc -l` #how many GPU do you have
echo "how many GPU do you have , numberofgpu = $numberofgpu"
min_using=90
temp_limit=50
error_level=8
pause=2 # in seconds

error_state=0
error_count=0

while (true); do
    clear # Временно отключил
    echo '+-----+--------+-------+------+'
    echo '| GPU |  Temp  | Using | Fans |'
    echo '+-----+--------+-------+------+'
    if [ $error_state -ne 0 ]; then
        error_count=$(( $error_count + 1 ))
    else
        error_count=0
    fi

    if [ $error_count -ne 0 ]; then
        #echo '+-----+-------+--------+------+'
        echo '|          WARNING!!!         |'
        echo "|$error_msg|"
        echo '+-----+--------+-------+------+'
        if [ $watch_dog -eq 1 ]; then
            remain_in_cicle=$(( $error_level - $error_count ))
            remain_in_sec=$(( $remain_in_cicle * $pause ))
            if [ $remain_in_cicle -le 0 ]; then
                #echo '+-----+-------+--------+------+'
                echo '|Your PC will be rebooted now!|'
                #echo '+-----+-------+--------+------+'
                echo $(date +%d-%m-%Y\ %H:%M:%S) $error_msg >> ~/mywd_draft_0.0.log
                
                # reboot # Временно отключил
                # вместо ребута, тест режим
                #echo '+-----+-------+--------+------+'
                echo '|    Your PC is turn off!!!   |'
                echo '+-----+--------+-------+------+'
                error_state=0
                error_count=0
                sleep $pause
                #clear
                
                # telegram bot send msg with description of problem
                MESSAGE=$(date +%d-%m-%Y)" в "$(date  +%H:%M)" $error_msg" 
                URL="https://api.telegram.org/bot$TOKEN/sendMessage"
                curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
            
                ###########################
            else
                #echo '+-----+-------+--------+------+'
                echo '|  PC will be rebooted after  |'
                # костыль
                if [[ $remain_in_sec -lt 10 ]]; then
                    echo "|          $remain_in_sec  sec             |"
                else
                    echo "|          $remain_in_sec sec             |"
                fi
                #echo "          $remain_in_sec sec"
                echo '+-----+--------+-------+------+'
            fi
        else
            #echo '+-----+-------+--------+------+'
            echo '|         MyWD disabled       |'
            echo '+-----+--------+-------+------+'
        fi
    else
        if [ $watch_dog -eq 1 ]; then
            #echo '+-----+-------+--------+------+'
            # echo '|     MyWD enabled. All OK    |'
            # echo '+-----+-------+--------+------+'
            tmp=0
        else
            #echo '+---- -+-------+--------+------+'
            echo '|        MyWD disabled       |'
            echo '+-----+--------+-------+------+'
        fi
    fi
    
    ###################################################################################
    error_state=0

    for (( i = 0; i < numberofgpu; i++ )); do
        
        ######### Проверяем отвечает ли карта, не отвалилась ли GPU ###################
        res_req=0
        temp=$(nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader,nounits)
        res_req=$?
        if [ $res_req -ne 0 ]; then
            echo "Error get data from card "$i
            error_state=1
            error_msg="GPU$i does not respond"
            # echo '+-----+-------+--------+------+'
            # echo '|    GPU$i does not respond   |'
            # echo '+-----+-------+--------+------+'
            continue
        
        fi

        ####################### Температурный лимит карты #############################
        if [ $temp -ge $temp_limit ]
        then
            echo $(date +%d-%m-%Y\ %H:%M:%S)" GPU$i is overheating, temperature($temp C) > temp_limit($temp_limit C)">> ~/mywd_draft_0.0.log
            
            # # telegram bot send msg with description of problem
            # MESSAGE=$(date +%d-%m-%Y)" в "$(date  +%H:%M)" GPU$i is OVERHEATING!, temperature($temp C) > temp_limit($temp_limit C)"
            # URL="https://api.telegram.org/bot$TOKEN/sendMessage"
            # curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
            
            #отслеживается error_level раз, затем перезагружает комп
            error_state=1
            error_msg=" GPU$i is OVERHEATING, t = $temp!"
            # echo '+-----+-------+--------+------+'
            # echo "|GPU$i is OVERHEATING,t=$temp!|"
            # echo '+-----+-------+--------+------+'
            continue
        fi

        ####################### Блок проверки загрузки карты #########################
        using=$(nvidia-smi -i $i --query-gpu=utilization.gpu --format=csv,noheader,nounits)
        if [ $using -lt $min_using ]
        then
            echo $(date +%d-%m-%Y\ %H:%M:%S)" The perfomance of the GPU$i DECREASED!">> ~/mywd_draft_0.0.log
            
            # # telegram bot send msg with description of problem
            # MESSAGE=$(date +%d-%m-%Y)" в "$(date  +%H:%M)" The perfomance of the GPU$i DECREASED!"
            # URL="https://api.telegram.org/bot$TOKEN/sendMessage"
            # curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
            
            #отслеживается error_level раз, затем перезагружает комп 
            error_state=1
            error_msg="GPU$i The perfomance DECREASED"
                 #echo '+-----+--------+-------+------+'

            #echo '+-----+-------+--------+------+'
            # echo "|Using of the GPU$i DECREASED! |"
            # echo '+-----+-------+--------+------+'
            
            ##### TEST #####
            #echo "error_count = $error_count"
            ################
            
            continue
        fi

        ############ Если все в порядке выводим в консоль показатели по картам ########

        # echo '+-----+-------+-------+------+'
        # echo '| GPU |  Temp | Using | Fans |'
        # echo '+-----+-------+-------+------+'
        echo "|  $i  |   $temp   |  $using  | ---- |"
        echo '+-----+--------+-------+------+'

        ###############################################################################
    done
    sleep $pause
done

