#!/bin/bash

exec 3<> /tmp/.volume-notification-lock
flock -x -F 3

VOLUME=$(pactl list sinks | grep -A15 -P "(\#|№)$SINK" | grep -P "\d+\s*\/\s*\d+\%" | head -1 | awk "{print \$5}")
if [[ "${1:0:1}" = "+" || "${1:0:1}" = "-" ]]
then
    pactl set-sink-volume @DEFAULT_SINK@ $1
elif [[ "$1" = "mute" ]]
then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
elif [[ "$1" = "micmute" ]]
then
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    USEMIKE=1
    MIKEMUTED=$(pacmd list-sources | grep -e "index" -e "muted" | grep "* index" -A1 | grep muted | awk "{print \$2}")
fi

VOLUME=$(pactl list sinks | grep -A15 -P "(\#|№)$SINK" | grep -P "\d+\s*\/\s*\d+\%" | head -1 | awk "{print \$5}")
VOLUME=${VOLUME:0:-1}
MUTED=$(pactl list sinks | grep -A15 -P "(\#|№)$SINK" | grep Mute | awk "{print \$2}")

if [[ $USEMIKE == 1 ]]
then
    if [[ $MIKEMUTED == "yes" ]]
    then
        ICON="microphone-disabled"
    else
        ICON="microphone-sensitivity-high"
    fi
elif [[ $MUTED == "yes" ]]
then
    ICON="audio-volume-muted"
elif [[ "$VOLUME" == "0" ]]
then
    ICON="audio-volume-low"
elif [[ "$VOLUME" -lt "33" ]]
then
    ICON="audio-volume-low"
elif [[ "$VOLUME" -lt "66" ]]
then
    ICON="audio-volume-medium"
else
    ICON="audio-volume-high"
fi

NOTIFY_ARGS=(--session
             --dest org.freedesktop.Notifications
	     --object-path /org/freedesktop/Notifications)

HINTS="{\"value\": <int32 $VOLUME>}"
REPLACE_ID=0
if [ -s /tmp/.volume-notification-lock ]
then
    REPLACE_ID=$(< /tmp/.volume-notification-lock)
fi
echo "$REPLACE_ID"
ID=$(gdbus call "${NOTIFY_ARGS[@]}"  --method org.freedesktop.Notifications.Notify "volume-control" "$REPLACE_ID" "/usr/share/icons/Adwaita/scalable/status/$ICON-symbolic.svg" "$VOLUME %" "" [] "$HINTS" "int32 2000" | sed 's/(uint32 \(.*\),)/\1/')
echo $ID

echo $ID >&3
flock -u 3
exec 3>&-
sleep 2 && [ "$(echo "$(date +'%s') - $(stat /tmp/.volume-notification-lock -c "%Z")" | bc)" -gt "1" ] && rm /tmp/.volume-notification-lock &
