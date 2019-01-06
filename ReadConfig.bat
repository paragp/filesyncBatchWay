@echo off

rem eol stops comments from being parsed
rem otherwise split lines at the = char into two tokens
for /F "eol=# delims== tokens=1,*" %%a in (config.properties) do (

    rem proper lines have both a and b set
    rem if okay, assign property to some kind of namespace
    rem so some.property becomes location.localFolder.property in batch-land
    if NOT "%%a"=="" if NOT "%%b"=="" set location.%%a=%%b
	echo Reading...%%a $$$$ %%b
)

rem debug namespace location.
set location


set "LocalFolder=%location.localFolder.property%"
set "SharedFolder=%location.sharedFolder.property%"
set "ArchiveFolder=%location.archiveFolder.property%"
set "LogFolder=%location.logFolder.property%"
set "ServerLogFolder=%location.ServerlogFolder.property%"

set local enabledelayedexpansion
REM Preparing Timestamp Information
set year=%date:~6,4%
set month=%date:~3,2%
set day=%date:~0,2%
set hour=%time:~0,2%
set minute=%time:~3,2%
set seconds=%time:~6,2%
set timestamp=%year%%month%%day%%hour%%minute%%seconds%



IF not exist %LogFolder% (mkdir %LogFolder%)
IF not exist %LocalFolder% (mkdir %LocalFolder%)

::Get IP address

set ip_address_string="IP Address"

rem Uncomment the following line when using Windows 7 or Windows 8 / 8.1 (with removing "rem")!
set ip_address_string="IPv4 Address"
set _IPaddr=
for /f "tokens=14" %%a in ('ipconfig ^| findstr IPv4') do set _IPaddr=%%a


Set LogFile=%LogFolder%\log_%_IPaddr%_%timestamp%.txt
If exist "%LogFile%" Del "%LogFile%"




echo IP Address %_IPaddr%  
:: Is folder empty
set _FILECHECK=
FOR /f "delims=" %%f IN ('dir /b /s "%LocalFolder%\*.*"') DO set _FILECHECK=%%f

IF {%_FILECHECK%}=={} (
  echo 
    ( 
		echo No files found in %LocalFolder%   
				
    )>> "%LogFile%"
	echo Log file is %LogFile%
	robocopy /mov "%LogFolder%" "%ServerLogFolder%" 
	exit
) 

REM Iterates throw all text files on %LocalFolder% and its subfolders.
REM And Populate the array with existent files in this folder and its subfolders
echo     Please wait a while ... We populate the array with filesNames ...
SetLocal EnableDelayedexpansion
@FOR /f "delims=" %%f IN ('dir /b /s "%LocalFolder%\*.*"') DO (
    set /a "idx+=1"
    set "FileName[!idx!]=%%~nxf"
    set "FilePath[!idx!]=%%~dpFf"
)
echo Display the files in %LocalFolder%
rem Display array elements
for /L %%i in (1,1,%idx%) do (
    echo Files [%%i] "!FileName[%%i]!"
    ( 

		echo Xcopying  
		
		xcopy "%LocalFolder%\!FileName[%%i]!" %ArchiveFolder%\ /y
		
		echo Robocopying  
	
        robocopy /mov "%LocalFolder%" "%SharedFolder%" "!FileName[%%i]!" 
    
    )>> "%LogFile%"
	     
)

echo Total files(s) : !idx! >> "%LogFile%"
robocopy /mov "%LogFolder%" "%ServerLogFolder%" 
ECHO(
ECHO Total files(s) : !idx!
TimeOut /T 10 /nobreak>nul
rem Start "" "%LogFile%"
)
exit



