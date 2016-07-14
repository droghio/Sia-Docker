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

cp -r /data/consensus ./consensus

case "$SIA_ROLE" in
    "miner")
        cp -r /data/wallets/miners/miner0 ./wallet
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

LOG=/data/logs/$SIA_ROLE-`date -u +%s`
echo "Log location is $LOG"

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

#Run specific script.
if [[ $SCRIPT ]]
then
    bash $SCRIPT
fi

#When done wait for siad to quit.
wait $!

echo `date -u +%s`: Siad quit. >> $LOG
echo `date -u +%s`: That\'s all folks!
