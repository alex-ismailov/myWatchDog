#! /bin/bash


echo "Fan Speed Control script started"

#Включение/выключение watchdog. Отключить: watch_dog=0. Мониторинг будет происходить, но перезагрузка отключена
watch_dog=1

TOKEN=xxx
CHAT_ID=xxx

numberofgpu=`nvidia-smi -L | wc -l` #how many GPU do you have
echo "how many GPU do you have , numberofgpu = $numberofgpu"
min_using=90
temp_limit=40
error_level=8
pause=2 # in seconds

error_state=0
error_count=0

while (true); do
    clear
    echo '+-----+--------+-------+------+'
    echo '| GPU |  Temp  | Using | Fans |'
    echo '+-----+--------+-------+------+'
    if [ $error_state -ne 0 ]; then
        error_count=$(( $error_count + 1 ))
    else
        error_count=0
    fi

    if [ $error_count -ne 0 ]; then
        echo '|          WARNING!!!         |'
        echo "|$error_msg|"
        echo '+-----+--------+-------+------+'
        if [ $watch_dog -eq 1 ]; then
            remain_in_cicle=$(( $error_level - $error_count ))
            remain_in_sec=$(( $remain_in_cicle * $pause ))
            if [ $remain_in_cicle -le 0 ]; then
                echo $(date +%d-%m-%Y)" в "$(date  +%H:%M)" $error_msg" >> ~/WatchDogErrorLog.log
                
                # telegram bot send msg with description of problem
                MESSAGE=$(date +%d-%m-%Y)" в "$(date  +%H:%M)" $error_msg" 
                URL="https://api.telegram.org/bot$TOKEN/sendMessage"
                curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
                clear

                # reboot # Временно отключил
                # вместо ребута, тест режим
                echo '+-----+--------+-------+------+'
                echo '|   Your PC will be turn off  |'
                echo '+-----+--------+-------+------+'
                error_state=0
                error_count=0
                sleep $pause
                #####################################
            else
                echo '|  PC will be rebooted after  |'
                # костыль
                if [[ $remain_in_sec -lt 10 ]]; then
                    echo "|          $remain_in_sec  sec             |"
                else
                    echo "|          $remain_in_sec sec             |"
                fi
                echo '+-----+--------+-------+------+'
            fi
        else
            echo '|         MyWD disabled       |'
            echo '+-----+--------+-------+------+'
        fi
    else
        if [ $watch_dog -eq 1 ]; then
            echo '|          WD enabled         |'
            echo '+-----+-------+--------+------+'
        else
            echo '|          WD disabled        |'
            echo '+-----+--------+-------+------+'
        fi
    fi
    
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

        ############ Если все в порядке выводим в консоль показатели по картам ########
        
        echo "|  $i  |   $temp   |  $using  | ---- |"
        echo '+-----+--------+-------+------+'

        ###############################################################################
    done
    sleep $pause
done

