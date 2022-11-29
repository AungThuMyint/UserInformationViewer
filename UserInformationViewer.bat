@ECHO OFF
if "%~s0"=="%~s1" ( cd %~sp1 & shift ) else (
  echo CreateObject^("Shell.Application"^).ShellExecute "%~s0","%~0 %*","","runas",1 >"%tmp%%~n0.vbs" & "%tmp%%~n0.vbs" & del /q "%tmp%%~n0.vbs" & goto :eof
)
title User Information Viewer [Coder : MR47M]
for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID') DO set edition=%%A
for /f "tokens=3" %%B in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion') DO set display_version=%%B
for /f "tokens=3" %%C in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber') DO set version=%%C
for /f "tokens=3" %%D in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v SystemRoot') DO set root=%%D
for /f "delims=[] tokens=2" %%X in ('ping -4 -n 1 %COMPUTERNAME% ^| findstr [') DO set NetworkIP=%%X
for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections') DO set output=%%A
for /f "tokens=2 delims==" %%I in ('%SystemRoot%\System32\wbem\wmic.exe CPU GET Name /VALUE') DO set cpu=%%I
for /f "tokens=2 delims==" %%J in ('%SystemRoot%\System32\wbem\wmic.exe MEMORYCHIP get Speed /VALUE') DO set ram_type=%%J
for /f %%J in ('powershell -command "$env:firmware_type"') DO set bios=%%J
for /f %%K in ('powershell -command "Confirm-SecureBootUEFI"') DO set boot=%%K
for /f "tokens=2 delims==" %%I in ('%SystemRoot%\System32\wbem\wmic.exe computersystem get TotalPhysicalMemory /format:list') DO set ram_storage=%%I
reg query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
set host=%COMPUTERNAME%
echo Domain          : %host%
echo Username        : %username%
echo IP Address      : %NetworkIP%
if %output%==0x0 (
	echo RDP Status      : Enable
) else (
	echo RDP Status      : Disable
)
if %OS%==32BIT (
	echo System          : 32 Bit
) else (
	echo System          : 64 Bit
)
echo CPU             : %cpu%
set ram_gb=%~z2
set ram_gb=%ram_storage%
set /A GB=%ram_gb:~0,-3%/1000/1000
if %ram_type% LSS 1601 (
	echo RAM             : DDR3 %ram_type% MHz %GB%GB
) else (
	echo RAM             : DDR4 %ram_type% MHz %GB%GB
)
for /f Tokens^=6Delims^=^" %%G In ('^""%SystemRoot%\System32\wbem\WMIC.exe" /NameSpace:\\root\Microsoft\Windows\Storage Path MSFT_PhysicalDisk Where "MediaType='4' And SpindleSpeed='0'" Get Model /Format:MOF 2^>NUL^"') DO (
	if %%G=="" (
		goto not_ssd
	) else (
		echo SSD             : %%G
		goto not_ssd
	)
)
:not_ssd
for /f Tokens^=6Delims^=^" %%G In ('^""%SystemRoot%\System32\wbem\WMIC.exe" /NameSpace:\\root\Microsoft\Windows\Storage Path MSFT_PhysicalDisk Where "MediaType='3' And SpindleSpeed='4294967295'" Get Model /Format:MOF 2^>NUL^"') DO @echo HDD             : %%G
if %bios%==UEFI (
	echo BIOS            : UEFI
) else (
	echo BIOS            : Legacy
)
if %boot%==True (
	echo SecureBoot      : On
) else (
	echo SecureBoot      : Off
)
echo Windows Edition : %edition%
echo Version         : %display_version%.%version%
echo SystemRoot      : %root%
ECHO.
pause
exit