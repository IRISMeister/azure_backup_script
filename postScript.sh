#!/bin/bash
# variables used for returning the status of the script

success=0
error=1
warning=2
exstatus=$success

log_path="/var/tmp/BackupScript.log"   #path of log file

iris session iris -U%SYS "##class(Backup.General).ExternalThaw(0)" >> $log_path
status=$?
if [ $status -eq 5 ]; then
  printf  "SYSTEM IS UNFROZEN\n" >> $log_path
  exstatus=$success
elif [ $status -eq 3 ]; then
  printf  "SYSTEM UNFREEZE FAILED\n" >> $log_path
  exstatus=$error
fi

exit $exstatus
