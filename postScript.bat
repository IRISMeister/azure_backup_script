echo off
SET success=0
SET error=1
SET warning=2
SET status=%success%

SET log_path="c:\temp/postScript.log"
echo Logs: > %log_path%

C:\InterSystems\IRIS\bin\iris runw iris THAW^^ZBACKUP %%SYS
SET sts=%errorlevel%
if %sts%==0 goto OK
if %sts%==1 goto FAIL
:OK
echo SYSTEM IS UNFROZEN >> %log_path%
SET status=%success%
goto END
:FAIL
echo SYSTEM UNFREEZE FAILED >> %log_path%
SET status=%error%
:END

exit/B %status%