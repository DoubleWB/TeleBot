#!/bin/sh

LAST_PROCESS_ID=""

while [ 1 -eq 1 ]
do
    #Gets only most recent message received. TODO: get all unprocessed messages if handling is too slow and two+ get sent while one is being dealt with.
    FULL_UPDATE=`curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/getUpdates"`
    echo "$FULL_UPDATE" > "./telegramBotFiles/output.txt" 
    LAST_UPDATE=`tail -n 1 "./telegramBotFiles/output.txt"`
    CHAT_ID=`echo "$LAST_UPDATE" | grep -o -P '(?<=chat\":{\"id\":).*(?=})' | cut -d ',' -f1`
    MESSAGE_ID=`echo "$LAST_UPDATE" | grep -o -P '(?<=\"message_id\":).*(?=,\"from\")'`
    PROCESS_ID="$CHAT_ID|$MESSAGE_ID"

    #echo "$LAST_PROCESS_ID"

    #Only proceed if the most recent message hasn't been dealt with already
    if [ "$PROCESS_ID" != "$LAST_PROCESS_ID" ]
    then
        curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/sendMessage?chat_id=$CHAT_ID&text=I think my last message ($LAST_PROCESS_ID) is different from this one ($PROCESS_ID)"
	#Trickily only get the text if it is a bot command (only json with the entities field)
    	LAST_TEXT=`echo "$LAST_UPDATE" | grep -o -P '(?<=text\":\").*(?=\",\"entities)'`

    	#echo "Received command: $LAST_TEXT"
	#echo "Chat id: $CHAT_ID"

	#Handling add commands
    	echo "$LAST_TEXT" | grep -q '/add'

    	if [ $? -eq 0 ]
    	then
            #echo "found add command"
	    #Remove "/add" as well as leading whitespace into the quote
    	    newQuote=`echo "$LAST_TEXT" | sed -n -e 's/^.*add//p' | sed -e 's/@AnimeClubQuotesbot//' | sed -e 's/^[ \t]*//'`

	    #Only add quote if it's distinct from others
	    grep -q "$newQuote" ./telegramBotFiles/quotes.txt

	    if [ $? -eq 0 ]
    	    then
	    	#echo "Quote already added"
            	curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/sendMessage?chat_id=$CHAT_ID&text=I already know this one..."
    	    else
	    	echo "$newQuote" >> "./telegramBotFiles/quotes.txt"
            	curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/sendMessage?chat_id=$CHAT_ID&text=Added: $newQuote"
    	    fi
    	fi

	#Handling get commands
    	echo "$LAST_TEXT" | grep -q '/get'

    	if [ $? -eq 0 ]
    	then
    	    #echo "found get command"
	    randomQuote=$( head -$((${RANDOM} % `wc -l < "./telegramBotFiles/quotes.txt"` + 1)) "./telegramBotFiles/quotes.txt" | tail -1 )
	    #echo "$randomQuote"
	    curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/sendMessage?chat_id=$CHAT_ID&text=$randomQuote"
    	fi
    LAST_PROCESS_ID="$PROCESS_ID"
    fi

done
