#!/bin/bash

VALOR=$(echo "$1" | sed 's/<\*>/\.*/g')

echo $VALOR


if echo "$VALOR" | egrep '(^(\.\*))'  > /dev/null

then
        VALORANTE=$(echo "$VALOR" | sed 's/^\.\*//g')

        echo $VALORANTE
else
        echo 'deuruim'
fi


if echo "$VALORANTE" | egrep '((\.\*)$)'  > /dev/null

then
        FINAL=$(echo "$VALORANTE" | sed 's/\.\*$//g')

        echo $FINAL
else
        echo 'deu ruim'
fi
