#!/bin/bash
copyAndLink() {
    cp -n /bedrock-server/defaultconfig/$1 /bedrock-server/config/$1
    [ ! -L $1 ] && ln -s ./config/$1 $1
}

# Update permissions on new directories
find . \! -user minecraft -exec chown minecraft '{}' +

# Copy the default config files if not present
copyAndLink server.properties
copyAndLink permissions.json
copyAndLink whitelist.json

# Start server.
exec gosu minecraft /start-server.sh "$@"

# Wait until the background process is killed.
pid="$!"
while kill -0 $pid > /dev/null 2>&1; do
    wait
done
