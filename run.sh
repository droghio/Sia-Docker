#! /bin/bash

# Basic wrapper to coordinate test launching.

TEST=$1

echo "-----------------------------------------"
echo "* Running test $TEST, use Ctrl-C to quit..."
echo "-----------------------------------------"
echo ""
docker-compose -f $TEST up &

trap "docker-compose -f $TEST down" SIGTERM SIGINT
while [[ `ps -c $! | grep "docker-compose"` ]]
do
    wait $!
done
