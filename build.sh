#! /bin/bash

case $1 in
    "--no-cache")
        ARGS="--no-cache"
        ;;

    "")
        ;;

   *)
       echo Unknown argument: $1
       echo Usage:
       echo -e "\t./build.sh [--no-cache]"
       exit 1
       ;;
esac

echo "-----------------------------"
echo "* Building Sia Container"
echo "-----------------------------"
echo ""
cd containers

cd sia
docker build $ARGS -t droghio/sia .

echo ""
echo "-----------------------------"
echo "* Building Sia Test Container"
echo "-----------------------------"
echo""
cd ../sia-test
docker build $ARGS -t droghio/sia-test .

echo ""
echo "-----------------------------"
echo "* Building Sia Genesis Container"
echo "-----------------------------"
echo""
cd ../sia-gen
docker build $ARGS -t droghio/sia-gen .

echo ""
echo "-----------------------------"
echo "* Building EchoIP Container"
echo "-----------------------------"
echo ""
cd ../echoip
docker build $ARGS -t echoip .

cd ../

echo ""
echo "-----------------------------"
echo "* Creating Data Directiories"
echo "-----------------------------"
echo ""
stat nodes_data &> /dev/null
if [[ $? == 1 ]]
then
    mkdir nodes_data
else
    echo "Using existing nodes_data directory"
fi
stat nodes_data/logs &> /dev/null
if [[ $? == 1 ]]
then
    mkdir nodes_data/logs
else
    echo "Using existing log directory"
fi
stat nodes_data/error &> /dev/null
if [[ $? == 1 ]]
then
    mkdir nodes_data/error
else
    echo "Using existing error log directory"
fi

stat /var/run/scope/plugins &> /dev/null
if [[ $? == 1 ]]
then
    mkdir /var/run/scope
    mkdir /var/run/scope/plugins
else
    echo "Using existing plugins directory"
fi

cd ..

echo ""
echo "-----------------------------"
echo "* Build Complete!"
echo "-----------------------------"
echo ""
echo "To start nodes run:"
echo -e "\t./run.sh tests/test_to_run.yml"
