# Sia-Docker

A set of docker containers scripts to construct a test Sia network. These containers will not connect to the default Sia network and are intended to be used as a testing framework.

To use download the source code, enter the downloaded directory and run:

````
./build.sh
docker-compose up &
````

To shutdown the network run `docker-compose down` in the same directory as the `docker-compose.yml` file.
You can access the WeaveScope instance on `localhost:4040` for web browser based debugging.
