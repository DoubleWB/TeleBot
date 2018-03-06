#!/bin/sh

SEPARATOR_KEY="EnCt2ee3705edca2222a3"

#Remember to bring this to fg and kill upon bot shutdown - proper fix will come
source ./handleUpdate.sh &

while [ 1 -eq 1 ]
do
    FULL_UPDATE=`curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/getUpdates"`
    echo "$FULL_UPDATE" > "./telegramBotFiles/output.txt" 
    touch "./telegramBotFiles/updateQueueNew.txt" 
    while IFS='' read -r messageJSON || [[ -n "$messageJSON" ]];
    do
        CHAT_ID=`echo "$messageJSON" | grep -o -P '(?<=chat\":{\"id\":).*(?=})' | cut -d ',' -f1`
    	MESSAGE_ID=`echo "$messageJSON" | grep -o -P '(?<=\"message_id\":).*(?=,\"from\")'`

	#Trickily only get the text if it is a bot command (only json with the entities field)
        LAST_TEXT=`echo "$messageJSON" | grep -o -P '(?<=text\":\").*(?=\",\"entities)'`

	#echo "$LAST_TEXT"

	#Only add to the updateQueue if the message is a bot command and  has not already been handled
	#Update updateQueue only once to minimize concurrency issues
        if [ ${#LAST_TEXT} -eq 0 ]
        then
            continue
        else
            grep -q "$CHAT_ID|$MESSAGE_ID" "./telegramBotFiles/handled.txt"
	    if [ $? -eq 1 ]
	    then
                echo "$LAST_TEXT$SEPARATOR_KEY$CHAT_ID$SEPARATOR_KEY$MESSAGE_ID" >> "./telegramBotFiles/updateQueueNew.txt"
	    fi
        fi
    done < "./telegramBotFiles/output.txt"
    mv "./telegramBotFiles/updateQueueNew.txt" "./telegramBotFiles/updateQueue.txt"
    sleep 1
done
