#! /bin/bash

# Basic wrapper to coordinate test launching.

if [[ $1  ]]
then
    TEST=$1
else
    echo "Please specify a docker-compose file to run."
    echo "Usage:"
    echo -e "\t./run.sh test-file-to-run.yml"
    exit 1
fi

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
