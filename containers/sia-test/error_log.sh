#! /bin/bash

# Sia Docker Error Logger
#     Scans for warnings and errors in all logs and collects them into STDOUT
#
# John Drogo
# July 14, 2016
#

# NEEDS ENVIRONMENT VARIABLES    
#     $SIAD_PID

for file in $(find ./ -name *.log)
do
    echo -e "\tLogging $file for $SIAD_PID"
    echo "`date` New Logging Session" >> $file # Makes sure we don't repeat old warnings.
    tail --pid=$SIAD_PID -n 1 -f $file |
    sed -n --unbuffered '/.*WARN\|ERROR.*/p' &
done 
