#!/bin/sh

SEPARATOR_KEY="EnCt2ee3705edca2222a3"

#Go through the update queue every 2 seconds and handle requests
while [ 1 -eq 1 ] 
do
    while IFS='' read -r update || [[ -n "$update" ]];
    do
        #echo "Read: $update"
	temp=`echo "$update" | sed -e 's/EnCt2ee3705edca2222a3/|/g'`
	IFS='|'
	params=($temp)
        source ./handleCommand.sh "${params[0]}" "${params[1]}" "${params[2]}" &
	IFS='' 
    done < "./telegramBotFiles/updateQueue.txt"
    sleep 2
done
