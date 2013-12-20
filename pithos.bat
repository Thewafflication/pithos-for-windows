@echo off
REM 
REM Win32 launch script for Pithos based on Exailes
REM
REM Since GStreamer SDK and OSSBuild are a bit difficult to work with, we
REM go through and set things up for the user so they don't need to worry
REM too much about PATH variables being set properly and other madness. 
REM
REM Additionally, this script tries to be a bit more verbose and let the 
REM user know more about the errors that they are seeing, instead of just a
REM stack trace.
REM

setlocal

set PYTHON_EXE=pythonw.exe

echo Detecting Pithos requirements (this may take a minute): 

REM Detect Python in the path
for %%X in (%PYTHON_EXE%) do (set PYTHON_BIN=%%~$PATH:X)
if defined PYTHON_BIN set PYTHON_VIA=environment
if defined PYTHON_BIN goto python_found

REM No python in path, see if its in a default location. Prefer
REM Python 2.7, since our installer ships with that as default
set PYTHON_BIN=C:\Python27\%PYTHON_EXE%
set PYTHON_VIA=hardcoded
if exist python goto python_found

:python_found
echo     Python                     : %PYTHON_BIN% (via %PYTHON_VIA%)
if %PYTHON_VIA%==environment set PYTHON_BIN=%PYTHON_EXE%
if %PYTHON_VIA%==hardcoded echo "If this is incorrect add the correct one to the PATH environment variable (google is your friend)"

REM Detect GStreamer SDK
set GST_VIA=environment
set GST_SDK=N
if defined GSTREAMER_SDK_ROOT_X86 set GST_SDK=%GSTREAMER_SDK_ROOT_X86%
if defined GSTREAMER_SDK_ROOT_X86_64 set GST_SDK=%GSTREAMER_SDK_ROOT_X86_64%

if not "%GST_SDK%" == "N" goto pygst_env_found

REM For some reason the GStreamer SDK doesn't define the environment
REM variables globally, so we just have to cheat if we can't do it
REM the 'correct' way
if exist C:\gstreamer-sdk\0.10\x86\bin goto found_pygst_x86_hardcoded
if exist C:\gstreamer-sdk\0.10\x86_64\bin goto found_pygst_x64_hardcoded
goto nogst

:found_pygst_x86_hardcoded
set GSTREAMER_SDK_ROOT_X86=C:\gstreamer-sdk\0.10\x86
set GST_SDK=%GSTREAMER_SDK_ROOT_X86%
set GST_VIA=hardcoded path
goto pygst_env_found

:found_pygst_x64_hardcoded
set GSTREAMER_SDK_ROOT_X64=C:\gstreamer-sdk\0.10\x86_64
set GST_SDK=%GSTREAMER_SDK_ROOT_X64%
set GST_VIA=hardcoded path
goto pygst_env_found

:pygst_env_found
echo     GStreamer SDK Runtime      : %GST_SDK% (via %GST_VIA%)

REM
REM Then try to setup the environment properly for GStreamer SDK
REM -> Note that we put the GST path first, so that any needed DLLs
REM    are searched for there first, hopefully avoiding DLL hell
REM 

set PATH=%GST_SDK%\bin;%PATH%
set PYGST_BINDINGS=%GST_SDK%\lib\python2.7\site-packages
if defined PYTHONPATH set PYTHONPATH=%PYGST_BINDINGS%;%PYTHONPATH%
if not defined PYTHONPATH set PYTHONPATH=%PYGST_BINDINGS%

:: Do this in case user has installed Python33 and selected for it to be added to PATH. Pithos does not work with Python33, it gives an exit code ^> 0.
if exist "C:\Python27\%PYTHON_BIN%" set "PYTHON_BIN=C:\Python27\%PYTHON_BIN%"

%PYTHON_BIN% -c "import pygst;pygst.require('0.10');import gst"
if not %ERRORLEVEL% == 0 goto badgst

:pygst_found
echo     GStreamer Python Bindings  : %PYGST_BINDINGS%

REM Detect PyGTK. We do detection here since it may be in the GStreamer SDK
%PYTHON_BIN% -c "import pygtk;pygtk.require('2.0');import gtk"
if not %ERRORLEVEL% == 0 goto badgtk

echo     PyGTK                      : OK

echo Dependencies good, starting Pithos.
echo.

goto start_pithos

REM Various errors

:nopython
echo Python 2.7 was not detected. Please include the python directory in your
echo PATH, or install it. You can download it at http://www.python.com/
echo.
pause && goto end

:nogst
echo     GStreamer SDK Runtime      : not found
echo.
echo GStreamer SDK Runtime was not found. 
echo.
echo You can download the 32bit GST SDK runtime at http://www.gstreamer.com/
echo.
pause && goto end

:badgst
echo     GStreamer Python Bindings  : not found
echo.
echo The python bindings for GStreamer could not be imported. Please re-run the
echo installer and ensure that the python bindings are selected for 
echo installation (they should be selected by default). 
echo.
echo You can download the 32bit GST SDK runtime at http://www.gstreamer.com/ 
echo.
pause && goto end

:badgtk
echo.
echo PyGTK 2.x could not be imported. It is installed by default with the
echo GStreamer SDK (select GTK Python Bindings), or you can use the 
echo PyGTK all-in-one installer from http://www.pygtk.org/
echo.
echo Note that the PyGTK all-in-one installer is NOT compatible with
echo the GStreamer SDK. Please Uninstall it.
echo.
echo You can download the 32bit GST SDK runtime at http://www.gstreamer.com/
echo.
pause && goto end


:start_pithos
pushd %~dp0
start %PYTHON_BIN% pithos.pyw
popd
goto end

:end
endlocal
