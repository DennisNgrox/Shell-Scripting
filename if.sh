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

{
    "jsonrpc": "2.0",
    "method": "trigger.create",
    "params": [
        {
            "description": "Processor load is too high on {HOST.NAME}",
            "expression": "{Linux server:system.cpu.load[percpu,avg1].last()}>5"
        }],
