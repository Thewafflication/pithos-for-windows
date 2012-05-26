Name "Pithos"
OutFile "Pithos_Installer.exe"
InstallDir "$PROGRAMFILES\Pithos\"
RequestExecutionLevel admin

!include EnvVarUpdate.nsh
!include MUI2.nsh

Var StartMenuFolder

!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Pithos" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

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
#move files in here on compile

WriteUninstaller "$INSTDIR\Uninstall.exe"
WriteRegStr HKCU "Software\Pithos" "" $INSTDIR
!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Pithos.lnk" "$INSTDIR\pithos.pyw"
CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Python 2.7.3"
SetOutPath "$TEMP\Pithos"
File python.msi
ExecWait 'msiexec TARGETDIR="$PROGRAMFILES\Python" /i "$TEMP\Pithos\python.msi"'
${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$PROGRAMFILES\Python"
SetOutPath "$PROGRAMFILES\Python\Lib"
File /r "site-packages"
SectionEnd

Section "Uninstall"
RMDir /r "$INSTDIR"
RMDir /r "$SMPROGRAMS\$StartMenuFolder"
DeleteRegKey HKCU "Software\Pithos"
SectionEnd

