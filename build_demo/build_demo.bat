:: called as build event
:: Hanno 2021

@ECHO OFF
setlocal

set CWD=%~dp0
set CONFIG_DIR=%CWD%configs\
set INSTALL_DIR=%CWD%cinema_demo

if "%~1" NEQ "cinema" goto :finish

rmdir /q /s %INSTALL_DIR% >NUL
mkdir %INSTALL_DIR%
mkdir %INSTALL_DIR%\configs

pushd %CONFIG_DIR%
for %%f in (*.ini) do (call :handle_config_file "%%~nxf")
popd

:: copy over stuff from bin folder
mkdir %INSTALL_DIR%\bin
xcopy /E /I %~2..\Release %INSTALL_DIR%\bin\Release >NUL
xcopy /E /I %~2..\media %INSTALL_DIR%\bin\media >NUL
xcopy /E /I %~2..\settings %INSTALL_DIR%\bin\settings >NUL
del %INSTALL_DIR%\bin\Release\*.pdb >NUL
del %INSTALL_DIR%\bin\Release\extract.exe >NUL

:: zip the shebang to cinema_demo.zip
powershell Compress-Archive -Update %INSTALL_DIR% cinema_demo.zip

:: cleanup
rmdir /q /s %INSTALL_DIR% >NUL

:finish
exit /B %ERRORLEVEL%

:handle_config_file
:: copies over config file and generates .bat file
copy %~1 %INSTALL_DIR%\configs >NUL
set /p descr=< %~1
set BATFILE=%INSTALL_DIR%\%~n1.bat
echo @echo off > %BATFILE%
echo echo %descr% >> %BATFILE%
echo pushd bin\Release\ >> %BATFILE%
echo cinema.exe --gui config="..\..\configs\%~1" >> %BATFILE%
echo popd >> %BATFILE%
exit /B 0
