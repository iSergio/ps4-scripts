#!/bin/bash

PS4_HOST=192.168.1.6
PS4_PORT=12800

SERVER_HOST=192.168.1.2
SERVER_PORT=8000
SERVER_HOME=/media/data2/ps4

PID_FILE=/tmp/ps4-http-server.pid

SLEEP_TTL=2

TRIM="s/^.//;s/.$//"

function stop() {
    if [[ -f $PID_FILE ]]; then
        kill -s 9 `cat $PID_FILE`
        rm -rf $PID_FILE
    fi
}

function start() {
#: <<'COMMENT'
    http-server -a $SERVER_HOST -p $SERVER_PORT $SERVER_HOME &>/dev/null &
    #python3 -m http.server -b $SERVER_HOST -d $SERVER_HOME $SERVER_PORT &>/dev/null &
    echo $! > $PID_FILE

    sleep 1
#COMMENT
}

function upload() {
    package=`realpath --relative-to="$SERVER_HOME" "$1"`
    package=$(printf %s "$package" |jq -sRr @uri)
    package=$(printf %s "$package" |jq -sRr @uri)

    json=`curl -s 'http://'$PS4_HOST':'$PS4_PORT'/api/install' --data '{"type":"direct","packages":["http://'$SERVER_HOST':'$SERVER_PORT'/'$package'"]}'`

    status=`echo $json | jq '.status' | sed $TRIM`
    taskId=`echo $json | jq '.task_id'`

    if [ "$status" = "success" ]; then
        while [ "$status" = "success" ]; do
            # Get status
            json=`curl -s 'http://'$PS4_HOST':'$PS4_PORT'/api/get_task_progress' --data '{"task_id":'$taskId'}'`
            greps=(`echo $json | grep -o -E "(0x[0-9a-fA-F]+|[0-9]+)|([0-9]+)"`)
            for grep in ${greps[@]}; do
                json=${json/ $grep/ \"$grep\"}
            done
            status=`echo $json | jq '.status' | sed $TRIM`
            if [ "$status" = "fail" ]; then
                error_code=`echo $json | jq '.error_code' | sed $TRIM`
                echo Exist with error code $error_code
                return
            fi
            transferred_total=$((16#`echo $json | jq '.transferred_total' | sed $TRIM | sed "s/0x//"`))
            length_total=$((16#`echo $json | jq '.length_total' | sed $TRIM | sed "s/0x//"`))
            if [ $transferred_total -gt 0 ] && [ $transferred_total = $length_total ]; then
                echo -ne "\nDone\n"
                return
            fi
            transferred_total=`numfmt --to iec --format "%.1f" $transferred_total`
            length_total=`numfmt --to iec --format "%.1f" $length_total`
            progress="$transferred_total of $length_total"
            echo -ne " $transferred_total of $length_total\033[0K\r"
            sleep $SLEEP_TTL
        done
    else
        echo $json
        return
    fi
}

start
for arg; do
    upload "$arg"
done
stop
