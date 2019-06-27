#!/bin/bash
# variables used for returning the status of the script
success=0
error=1
warning=2
status=$success

log_path="/etc/preScript.log"   #path of log file
printf  "Logs:\n" > $log_path


# don't forget to enable O/S authentication
iris session iris1 -U%SYS "##Class(Backup.General).ExternalFreeze(0)" >> $log_path
status=$?
if [ $status -eq 5 ]; then
echo "SYSTEM IS FROZEN"
printf  "SYSTEM IS FROZEN\n" >> $log_path
elif [ $status -eq 3 ]; then
echo "SYSTEM FREEZE FAILED"
printf  "SYSTEM FREEZE FAILED\n" >> $log_path
status=$error
iris session iris1 -U%SYS "##Class(Backup.General).ExternalThaw(0)"
fi

exit $status
