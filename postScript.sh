#!/bin/bash
# variables used for returning the status of the script

success=0
error=1
warning=2
status=$success

log_path="/var/tmp/BackupScript.log"   #path of log file
printf  "Logs:\n" > $log_path

iris session iris -U%SYS "##class(Backup.General).ExternalThaw(0)"
status=$?
if [ $status -eq 5 ]; then
  echo "SYSTEM IS UNFROZEN"
  printf  "SYSTEM IS UNFROZEN\n" >> $log_path
  status=$success
elif [ $status -eq 3 ]; then
  echo "SYSTEM UNFREEZE FAILED"
  printf  "SYSTEM UNFREEZE FAILED\n" >> $log_path
  status=$error
fi

exit $status
