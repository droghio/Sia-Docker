#! /bin/bash

# Sia Docker Error Logger
#     Scans for warnings and errors in all logs and collects them in the errors directory.
#
# John Drogo
# July 14, 2016
#

# NEEDS ENVIRONMENT VARIABLES
#     $ERROR_LOG
#     $SIAD_PID

for file in $(find ./ -name *.log)
do
    echo "Logging $file for $SIAD_PID in $ERROR_LOG"
    echo "`date` New Logging Session" >> $file # Makes sure we don't repeat old warnings.
    tail --pid=$SIAD_PID -n 1 -f $file $file |
    sed -n --unbuffered '/.*WARN\|ERROR.*/p' |
    tee -a $ERROR_LOG &
done 
