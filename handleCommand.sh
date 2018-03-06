#!/bin/sh

CHAT_MESSAGE=$1
CHAT_ID=$2
MESSAGE_ID=$3

#echo "Received command: $CHAT_MESSAGE"
#echo "Chat id: $CHAT_ID"

main() {
    #Handling add commands
    echo "$CHAT_MESSAGE" | grep -q '/add'

    if [ $? -eq 0 ]
    then
        handle_add
    fi

    #Handling get commands
    echo "$CHAT_MESSAGE" | grep -q '/get'

    if [ $? -eq 0 ]
    then
        handle_get
    fi

    echo "$CHAT_ID|$MESSAGE_ID" >> "./telegramBotFiles/handled.txt"
}

#Expects:
#       Chat id as first param
#       Chat message as second param
send_chat() {
    curl -s "https://api.telegram.org/bot526971927:AAEXn9rvEuTf-klDkOq6M9KGVIyt8TP1rVg/sendMessage?chat_id=$1&text=$2"
}

handle_add() {
    #echo "found add command"
    #Remove "/add" as well as leading whitespace into the quote
    newQuote=`echo "$CHAT_MESSAGE" | sed -n -e 's/^.*add//p' | sed -e 's/@AnimeClubQuotesbot//' | sed -e 's/^[ \t]*//'`

    #Only add quote if it's distinct from others
    grep -qw "$newQuote" ./telegramBotFiles/quotes.txt

    if [ $? -eq 0 ]
    then
        #echo "Quote already added"
        send_chat "$CHAT_ID" "I already know \"$newQuote\""
    else
        echo "$newQuote" >> "./telegramBotFiles/quotes.txt"
	send_chat "$CHAT_ID" "Added: $newQuote"
    fi

}

handle_get() {
    #echo "found get command"
    randomQuote=$( head -$((${RANDOM} % `wc -l < "./telegramBotFiles/quotes.txt"` + 1)) "./telegramBotFiles/quotes.txt" | tail -1 )
    #echo "$randomQuote"
    send_chat "$CHAT_ID" "$randomQuote"
}

grep -q "$CHAT_ID|$MESSAGE_ID" "./telegramBotFiles/handled.txt"
if [ $? -eq 1 ]
then
    main
fi
