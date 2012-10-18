;Pithos for Windows installer script
;Modified by TingPing
;Based on Exaile Windows installer script
;Modified by Dustin Spicuzza
;Based on the Quod Libet / Ex Falso Windows installer script
;Modified by Steven Robertson
;Based on the NSIS Modern User Interface Start Menu Folder Example Script
;Written by Joost Verburg

    ;compression
    SetCompressor /SOLID LZMA

    !define MULTIUSER_EXECUTIONLEVEL Highest
    !define MULTIUSER_MUI
    !define MULTIUSER_INSTALLMODE_COMMANDLINE

    !define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pithos"
    !define INSTDIR_KEY "Software\Pithos"
    !define INSTDIR_SUBKEY "InstDir"

;--------------------------------
;Include Modern UI and other libs

    !include "MUI2.nsh"
    !include "LogicLib.nsh"

;--------------------------------
;General

    ;Name and file
    Name "Pithos"
    OutFile "pithos_installer.exe"

    ;Default installation folder
    InstallDir "$PROGRAMFILES\Pithos"

    ;Get installation folder from registry if available
    ;InstallDirRegKey HKCU "${INSTDIR_KEY}" ""
    ;doesn't work with multi user -> see onInit..

    ;Request application privileges for Windows Vista+
    RequestExecutionLevel admin

;--------------------------------
;Variables

    Var StartMenuFolder
    Var instdir_temp
    
    Var HAVE_PYTHON
    Var HAVE_GSTCOMSDK
    
    Var NEED_PYTHON
    Var NEED_GSTCOMSDK
    

;--------------------------------
;Interface Settings

    !define MUI_ABORTWARNING
    !define MUI_ICON "..\data\icons\pithos-small.ico"
  
;--------------------------------
;Pages

    !insertmacro MUI_PAGE_LICENSE "..\LICENSE"
    !insertmacro MUI_PAGE_DIRECTORY
    
    Page custom dependenciesCreate dependenciesLeave

    ;Start Menu Folder Page Configuration
    !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
    !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Pithos" 
    !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

    !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

    !insertmacro MUI_PAGE_INSTFILES

    !insertmacro MUI_UNPAGE_CONFIRM
    !insertmacro MUI_UNPAGE_INSTFILES

;------------------------------------------------------------
; DOWNLOAD AND INSTALL DEPENDENCIES FIRST
;!define TEST_URL ""

; Use the official python.org Python packages
!define PYTHON_VERSION          "2.7"
!define PYTHON_FULL_VERSION     "2.7.3"
!define PYTHON_PATH             "C:\Python27"
!define PYTHON_FN               "python-${PYTHON_FULL_VERSION}.msi"
!define PYTHON_FSIZE            "15MB"
!define PYTHON_URL              "http://python.org/ftp/python/${PYTHON_FULL_VERSION}/${PYTHON_FN}"
;!define PYTHON_URL              "${TEST_URL}/${PYTHON_FN}"
!define PYTHON_CMD              "msiexec /i $DAI_TMPFILE /passive ALLUSERS=1"

; Use the GStreamer.com SDK
!define GSTCOMSDK_VERSION       "2012.9"
!define GSTCOMSDK_FN            "gstreamer-sdk-x86-${GSTCOMSDK_VERSION}.msi"
!define GSTCOMSDK_FSIZE         "97MB"
!define GSTCOMSDK_URL           "http://www.freedesktop.org/software/gstreamer-sdk/data/packages/windows/x86/${GSTCOMSDK_FN}"
;!define GSTCOMSDK_URL           "${TEST_URL}/${GSTCOMSDK_FN}"
!define GSTCOMSDK_FEATURES      "_gstreamer_core,_gstreamer_system,_gstreamer_playback,_gstreamer_codecs,_gstreamer_networking,_gstreamer_python,_gtk__2.0,_gtk__2.0_python,_gstreamer_codecs_restricted,_gstreamer_networking_restricted"
!define GSTCOMSDK_CMD           "msiexec /i $DAI_TMPFILE /passive ALLUSERS=1 ADDLOCAL=${GSTCOMSDK_FEATURES}"

!include "download.nsi"

Section "-python"
    ${If} $NEED_PYTHON == '1'
        DetailPrint "--- DOWNLOAD PYTHON ---"
        !insertmacro downloadAndInstall "Python" "${PYTHON_URL}" "${PYTHON_FN}" "${PYTHON_CMD}"
        Call DetectPython
        ${If} $HAVE_PYTHON == 'NOK'
            MessageBox MB_OK "Python installation appears to have failed. You may need to retry manually."
        ${EndIf}
    ${EndIf}
SectionEnd

Section "-gstcomsdk"
    ${If} $NEED_GSTCOMSDK == '1'
        DetailPrint "--- DOWNLOAD GSTREAMER.COM SDK ---"
        !insertmacro downloadAndInstall "GStreamer.com SDK" "${GSTCOMSDK_URL}" "${GSTCOMSDK_FN}" "${GSTCOMSDK_CMD}"
        Pop $0
        ${If} $0 != "0"
            MessageBox MB_OK "GStreamer.com SDK installation appears to have failed. You may need to retry manually."
        ${EndIf}
    ${EndIf}
    
SectionEnd

;------------------------------------------------------------
; Install Pithos last

Section "-Pithos" SecPithos

    SetOutPath "$INSTDIR"

    File /r "..\data"
    File /r "..\pithos"
    File /r "..\pithos.pyw"
    File /r "..\pithos.bat"

    ;Store installation folder
    WriteRegStr SHCTX "${INSTDIR_KEY}" "${INSTDIR_SUBKEY}" $INSTDIR

    ;Multi user uninstaller stuff
    ;WriteRegStr SHCTX "${UNINST_KEY}" \
    ;"DisplayName" "Pithos - Pandora desktop client."
    ;WriteRegStr SHCTX "${UNINST_KEY}" "DisplayIcon" "$\"$INSTDIR\data\icons\pithos-small.ico$\""
    ;WriteRegStr SHCTX "${UNINST_KEY}" "UninstallString" \
    ;"$\"$INSTDIR\uninstall.exe$\" /$MultiUser.InstallMode"
    ;WriteRegStr SHCTX "${UNINST_KEY}" "QuietUninstallString" \
    ;"$\"$INSTDIR\uninstall.exe$\" /$MultiUser.InstallMode /S"

    ;Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"

    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

    ;Create shortcuts
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Pithos.lnk" "$INSTDIR\pithos.bat" "" "$INSTDIR\data\icons\pithos-large.ico"

    !insertmacro MUI_STARTMENU_WRITE_END

SectionEnd


!include "dependencies.nsi"

!include "detect.nsi"

;--------------------------------
;Uninstaller Section

Section "Uninstall"

    RMDir /r "$INSTDIR"

    Delete "$INSTDIR\uninstall.exe"

    !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder

    Delete "$SMPROGRAMS\$StartMenuFolder\Pithos.lnk"
    RMDir "$SMPROGRAMS\$StartMenuFolder"

    DeleteRegKey SHCTX "${UNINST_KEY}"
    DeleteRegKey SHCTX "${INSTDIR_KEY}"

SectionEnd

