#! /bin/bash

# Sia Docker Boostrap Script
#    Bootstraps node for specified role based via SIA_ROLE environment variable.
#    Clones blockchain and specified wallet.
#
# John Drogo
# July 13, 2016
# Version 1.0

# NEEDS ENVIRONMENT VARIABLES
#     $SIA_ROLE
#     $SIAD_WALLET_PASSWORD

case "$SIA_ROLE" in
    "miner")
        cp -r /data/wallets/miners/miner0 ./wallet
        cp -r /data/consensus ./consensus
        SCRIPT="/data/scripts/miner.sh"
        ;;

    "renter")
        cp -r /data/wallets/renters/renter0 ./wallet
        SCRIPT="/data/scripts/renter.sh"
        ;;

    "host")
        cp -r /data/wallets/hosts/host0 ./wallet
        SCRIPT="/data/scripts/host.sh"
        ;;
    "")
        echo "No role defined"
        SIA_ROLE="noname"
        ;;
    *)
        echo "Unknow role $SIA_ROLE"
        ;;
esac

#Very ugly regex to get our primary ip address.
IP=`ip addr | grep "eth0" | grep "inet" | sed "s/.* \([0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*\).*/\1/g"`

LOG=/data/logs/$SIA_ROLE-$IP-`date -u +%s`
ERROR_LOG=/data/error/$SIA_ROLE-$IP-`date -u +%s`

echo "Log location is $LOG"
echo "Error log location is $ERROR_LOG"

# Start siad
siad --no-bootstrap &>> $LOG &

function waitForSiad {
    while [[ `siac 2>&1` == "Could not get current consensus state: no response from daemon" ]]
    do
        echo `date -u +%s`: Waiting for siad to start... >> $LOG
        sleep 1
    done
    echo `date -u +%s`: Siad successfully started! >> $LOG
}

waitForSiad

# Now we are able to issue api calles.
siac &>> $LOG

# Start the error logging
SIAD_PID=$!
export SIAD_PID
export ERROR_LOG
bash error_log.sh

#Run specific script.
if [[ $SCRIPT ]]
then
    bash $SCRIPT
fi

#When done wait for siad to quit.
trap "kill -SIGTERM $SIAD_PID" SIGTERM SIGINT
while [[ `ps -c $SIAD_PID | grep "siad"` ]]
do
    wait $SIAD_PID
done

echo `date -u +%s`: Siad quit. >> $LOG
echo `date -u +%s`: That\'s all folks!
