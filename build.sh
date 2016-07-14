#! /bin/bash

echo""
echo "* Building Sia"
echo ""
cd v1a
docker build --no-cache -t droghio/sia .

echo ""
echo "* Building Sia Genesis Node"
echo ""
cd ../v1-gen
docker build --no-cache -t droghio/sia-gen .

echo ""
echo "* Building echoip service"
echo ""
cd ../echoip
docker build --no-cache -t echoip .

cd ../

echo "Build Complete!"
echo ""
echo "To start nodes run:"
echo -e "\tdocker-compose up"
