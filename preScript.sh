#!/bin/bash
# variables used for returning the status of the script
success=0
error=1
warning=2
exstatus=$success

log_path="/var/tmp/BackupScript.log"   #path of log file

# don't forget to enable O/S authentication (root)
iris session iris -U%SYS "##Class(Backup.General).ExternalFreeze(0)" >> $log_path
status=$?
if [ $status -eq 5 ]; then
  printf  "SYSTEM IS FROZEN\n" >> $log_path
  exstatus=$success
elif [ $status -eq 3 ]; then
  printf  "SYSTEM FREEZE FAILED\n" >> $log_path
  exstatus=$error
  iris session iris -U%SYS "##Class(Backup.General).ExternalThaw(0)" >> $log_path
fi
sync
exit $exstatus
