#!/bin/bash

# Handler for SIGTERM from docker stop command. Sends "stop" to
# the bedrock server terminal for graceful shutdown.
stop() {
    screen -S `screen -ls | grep Attached | cut -f2` -X stuff "stop^M"
}

# Trap SIGTERM
trap 'kill ${!}; stop' TERM

# Start the command in a separate screen session and send it to background.
bash -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen $@" &

# Wait until the background process is killed.
pid="$!"
if [[ ! -v TEST ]]; then
    while kill -0 $pid > /dev/null 2>&1; do
        wait
    done
fi
