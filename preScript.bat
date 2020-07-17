echo off
SET success=0
SET error=1
SET warning=2
SET status=%success%

SET log_path="c:\temp/preScript.log"
echo Logs: > %log_path%

rem %Service_Console have to be enabled and accept unauthorized login or O/S login
C:\InterSystems\IRIS\bin\iris runw iris FREEZE^^ZBACKUP %%SYS
SET sts=%errorlevel%
if %sts%==0 goto OK
if %sts%==1 goto FAIL
:OK
echo SYSTEM IS FROZEN >> %log_path%
SET status=%success%
goto END
:FAIL
echo SYSTEM FREEZE FAILED >> %log_path%
SET status=%error%
C:\InterSystems\IRIS\bin\iris runw iris THAW^^ZBACKUP %%SYS
:END

exit/B %status%