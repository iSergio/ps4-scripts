#!/bin/bash
# Example for crontab
# ps4-backup.sh -b /media/backups/ps4/ -a

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

function do_backup() {
    for folder in ${FOLDERS[@]}; do
        printf "\t"
        align_left "$DOTSTRING" "$folder"
        result=`wget -nv -np -nH -q -r ftp://$HOST:$PORT/user/home/$id/$folder -P $BACKUPDIR/backup-$CURRDATE/`
        align_echo $? "$result"
    done
}

function backup() {
    echo "Backup will be stored in $BACKUPDIR"

    ids=()
    users=()

    result=$(check_connection)
    if [ ! -z "$result" ]; then
        echo "Error: "$result
        exit 1
    fi

    IFS=$'\n' && for i in `ftp -n $HOST $PORT 2>&1 <<EOF
cd user/home
dir
close
EOF
`; do
    dir=`echo $i | awk '{print $9}'`
    if [ $dir != "." ] && [ $dir != ".." ]; then
        user=(`wget -q -O - ftp://$HOST:$PORT/user/home/$dir/username.dat | tr -d '\0'`)
        # if no username.dat file - profile is guest, skip them
        if [ ! -z "$user" ]; then
            ids+=($dir)
            users+=($user)
        fi
    fi
done

    echo "Find the following profiles (name (uuid)):"
    for i in ${!ids[@]}; do
        echo "${users[$i]} (${ids[$i]})"
    done

    echo ""

    if [ $BACKUPALL == true ]; then
        echo "Backup all"
        for id in ${!ids[@]}; do
            echo "Backup ${users[$id]} profile:"
            id=${ids[$id]}
            do_backup $id
        done
    else
        echo "Select profiles to backup or select all profiles:"
        select user in "${users[@]}" "All" "Quit"; do
            if [ "$REPLY" -ge 1 ] && [ "$REPLY" -le "${#users[@]}" ]; then
                echo "Backup ${users[$(($REPLY-1))]} profile:"
                id=${ids[$(($REPLY-1))]}
                do_backup $id
                break
            elif [ "$REPLY" -eq $(("${#users[@]}" + 1)) ]; then
                echo "Backup all"
                for id in ${!ids[@]}; do
                    echo "Backup ${users[$id]} profile:"
                    id=${ids[$id]}
                    do_backup $id
                done
                break
            else
                echo "Exit"
                break
            fi
        done
    fi
}


usage="$(basename "$0") [-u] [-h host] [-p port] [-b backupdir] [-a] -- Script for backup user data from PS4
    where:
        -b base backups dir (default: $BACKUPDIR)
        -h ftp host (default: $HOST)
        -p ftp port (default: $PORT)
        -a backup all profiles (default: false, will be provided select menu)
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
        a) BACKUPALL=true
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

backup
