#!/bin/bash

# Default host
HOST=192.168.1.6
#Default port
PORT=2121
# Default backup store dir overrides over command line opts
BACKUPDIR="/media/backups/ps4"
# Current date in format
CURRDATE=$(date +"%Y-%m-%d %H:%M")
BACKUPALL=true

# Folders or files to backup relatively by user/home/{uuid}/
FOLDERS=(savedata trophy username.dat)

color_violet="\e[1;35m";
color_red="\e[0;31m";
color_normal="\e[0m";
color_green="\e[32m";
color_blue="\e[0;34m";

DONE="[  ${color_green}done${color_normal}  ]"
FAIL="[  ${color_red}fail${color_normal}  ]"

DOTSTRING=""
cols=`tput cols`
cols=$((cols / 4))
#cols=$((cols - 10))
for i in `seq 1 $cols`; do
    DOTSTRING=$DOTSTRING"."
done
function align_left() {
    local chars="$1"
    local str="${@:2}"
    echo -n ${str}${chars:${#str}}
}

function align_echo() {
    if [[ "$1" != 0 ]]; then
        echo -e $FAIL
        echo "$2"
    else
        echo -e $DONE
    fi
}

function check_connection() {
    wget -q ftp://$HOST:$PORT -O /dev/null
    if [ ! $? -eq 0 ]; then
        echo $((wget -nv ftp://$HOST:$PORT) 2>&1)
    fi
    echo ""
}

function recovery() {
    echo "Backup will be recovery from $BACKUPDIR"

    result=$(check_connection)
    if [ ! -z "$result"  ]; then
        echo "Error: "$result
        exit 1
    fi

    # Show backups
    echo "Please select backup date:"
    d_backups=($BACKUPDIR/*)
    backups=()
    #printf '%s\n' "${d_backups[@]}"
    for d_backup in "${d_backups[@]}"; do
        backups+=("$(basename "$d_backup")")
    done
    COLUMNS=1
    select backup in "${backups[@]}" "Quit"; do
        if [ "$REPLY" -ge 1  ] && [ "$REPLY" -le "${#users[@]}"  ]; then
            echo "Backup ${backups[$(($REPLY-1))]} profile:"
            backup=${backups[$(($REPLY-1))]}
            #do_backup $id
            break
        else
            echo "Exit"
            break
        fi
    done
    echo "Will be restored from $backup"

    # Check structure (first users)
    d_users=("$BACKUPDIR"/"$backup/user/home"/*)
    users=()
    for d_user in "${d_users[@]}"; do
        echo "$d_user"
        users+=("$(basename "$d_user")")
    done
    #user=(`wget -q -O - ftp://$HOST:$PORT/user/home/$dir/username.dat | tr -d '\0'`)
    printf '%s\n' "${users[@]}"
#    d_users=("$BACKUPDIR"/"$backup"/*)
#    users=()
#    printf '%s\n' "${d_users[@]}"
#
#    IFS=$'\n' && for i in `ftp -n $HOST $PORT 2>&1 <<EOF
#cd user/home
#dir
#close
#EOF
#`; do
#    dir=`echo $i | awk '{print $9}'`
#    if [ $dir != "."  ] && [ $dir != ".."  ]; then
#        user=(`wget -q -O - ftp://$HOST:$PORT/user/home/$dir/username.dat | tr -d '\0'`)
#        # if no username.dat file - profile is guest, skip them
#        if [ ! -z "$user"  ]; then
#            ids+=($dir)
#            users+=($user)
#        fi
#    fi
#    done
}

usage="$(basename "$0") [-u] [-h host] [-p port] [-b backupdir] -- Script for recovery user data to PS4
    where:
        -b base backups dir (default: $BACKUPDIR)
        -h ftp host (default: $HOST)
        -p ftp port (default: $PORT)
        -u  show this help text and exit
"
while getopts ':b:h:p:ua' option; do
    case "$option" in
        b) BACKUPDIR=$OPTARG
            ;;
        h) HOST=$OPTARG
            ;;
        p) PORT=$OPTARG
            ;;
        u) echo "$usage"
            exit
            ;;
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
    esac
done

recovery
