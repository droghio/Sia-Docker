#! /bin/bash

echo""
echo "* Building Sia"
echo ""
cd sia
docker build --no-cache -t droghio/sia .

echo ""
echo "* Building Sia Genesis Node"
echo ""
cd ../sia-gen
docker build --no-cache -t droghio/sia-gen .

echo ""
echo "* Building echoip service"
echo ""
cd ../echoip
docker build --no-cache -t echoip .

cd ../

echo ""
echo "* Creating data directiory"
echo ""
mkdir nodes_data
mkdir nodes_data/logs

echo "Build Complete!"
echo ""
echo "To start nodes run:"
echo -e "\tdocker-compose up"
