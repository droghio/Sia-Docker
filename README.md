# Sia-Docker

A set of docker containers scripts to construct a test Sia network. These containers will not connect to the default Sia network and are intended to be used as a testing framework.

To use download the source code, enter the downloaded directory and run:

````
./build.sh
./run.sh tests/peer_connection.yml
````

To shutdown the network press `Ctrl-C`. The run script will automatically shutdown all the nodes.
You can access the WeaveScope instance on `localhost:4040` for web browser based debugging.
