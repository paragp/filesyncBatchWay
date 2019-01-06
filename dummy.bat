@echo on
setlocal enabledelayedexpansion
set ip_address_string="IP Address"

rem Uncomment the following line when using Windows 7 or Windows 8 / 8.1 (with removing "rem")!
set ip_address_string="IPv4 Address"
set _IPaddr=
for /f "tokens=14" %%a in ('ipconfig ^| findstr IPv4') do set _IPaddr=%%a
echo IP is: %_IPaddr%
echo IP is: %_IPaddr%