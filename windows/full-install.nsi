Name "Pithos"
OutFile "Pithos_Full_Installer.exe"
InstallDir "$PROGRAMFILES\Pithos\"
RequestExecutionLevel admin

!include "FileFunc.nsh"
!include MUI2.nsh
!insertmacro Locate
var /GLOBAL switch_overwrite
!include "MoveFileFolder.nsh"
Var StartMenuFolder

!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Pithos" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_ICON "data\icons\pithos-small.ico"

!insertmacro MUI_PAGE_LICENSE ..\LICENSE
Page components
Page directory
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
Page instfiles

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

Section "Pithos"
SectionIn RO
CreateDirectory $INSTDIR
SetOutPath $INSTDIR
# Move Everything to this folder before compile
File /r "data"
File /r "pithos"
File "pithos.pyw"
WriteUninstaller "$INSTDIR\Uninstall.exe"
WriteRegStr HKCU "Software\Pithos" "" $INSTDIR
!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Pithos.lnk" "$INSTDIR\pithos.pyw" "" "$ProgramFiles\Pithos\data\icons\pithos-small.ico"
CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Python 2.7.3"
SetOutPath "$TEMP\Pithos"
File "python-2.7.3.msi"
ExecWait 'msiexec TARGETDIR="$PROGRAMFILES\Python" /i "$TEMP\Pithos\python-2.7.3.msi" /qn'
SectionEnd

Section "GStreamer 0.10.7"
SetOutPath "$TEMP\Pithos"
File "GStreamer-WinBuilds-GPL-x86-Beta04-0.10.7.msi"
File "GStreamer-WinBuilds-SDK-GPL-x86-Beta04-0.10.7.msi"
ExecWait 'msiexec /i "$TEMP\Pithos\GStreamer-WinBuilds-GPL-x86-Beta04-0.10.7.msi" /qn'
ExecWait 'msiexec /i "$TEMP\Pithos\GStreamer-WinBuilds-SDK-GPL-x86-Beta04-0.10.7.msi" /qn+'
# moving gstreamer stuff around sucks...
StrCpy $switch_overwrite 1
!insertmacro MoveFolder "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\sdk\bindings\python\v2.7\lib\" "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\lib\" "*"
!insertmacro MoveFolder "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\sdk\bindings\python\v2.7\share\" "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\share\" "*"
!insertmacro MoveFolder "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\lib\site-packages\gst-0.10\gst\"  "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\lib\site-packages\gst\" "*"
Delete "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\lib\gstreamer-0.10\libgstpython-v2.6.dll"
Delete "$PROGRAMFILES\OSSBuild\GStreamer\v0.10.7\lib\gstreamer-0.10\lib\site-packages\gst-0.10\"
SectionEnd

Section "GTK 2.24"
SetOutPath "$TEMP\Pithos"
File "pygtk-all-in-one-2.24.2.win32-py2.7.msi"
ExecWait 'msiexec /i "$TEMP\Pithos\pygtk-all-in-one-2.24.2.win32-py2.7.msi" /qn+'
SectionEnd

Section "Uninstall"
RMDir /r "$INSTDIR"
RMDir /r "$SMPROGRAMS\$StartMenuFolder"
DeleteRegKey HKCU "Software\Pithos"
SectionEnd

