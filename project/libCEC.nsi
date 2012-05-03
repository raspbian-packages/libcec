;libCEC installer
;Copyright (C) 2012 Pulse-Eight Ltd.
;http://www.pulse-eight.com/

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

Name "Pulse-Eight USB-CEC Adapter"
OutFile "..\build\libCEC-installer.exe"

XPStyle on
InstallDir "$PROGRAMFILES\Pulse-Eight\USB-CEC Adapter"
InstallDirRegKey HKLM "Software\Pulse-Eight\USB-CEC Adapter software" ""
RequestExecutionLevel admin
Var StartMenuFolder
Var VSRedistSetupError
Var VSRedistInstalled

!define MUI_FINISHPAGE_LINK "Visit http://www.pulse-eight.com/ for more information."
!define MUI_FINISHPAGE_LINK_LOCATION "http://www.pulse-eight.com/"
!define MUI_ABORTWARNING  

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\COPYING"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Pulse-Eight\USB-CEC Adapter sofware" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder  

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

InstType "USB-CEC driver & libCEC"
InstType "USB-CEC driver only"
InstType "Full installation"

Section "USB-CEC driver" SecDriver
  SetShellVarContext current
  SectionIn RO
  SectionIn 1 2 3

  ; Uninstall the old unsigned software if it's found
  ReadRegStr $1 HKCU "Software\libCEC" ""
  ${If} $1 != ""
    MessageBox MB_OK \
	  "A previous libCEC and USB-CEC driver was found. This update requires the old version to be uninstalled. Press OK to uninstall the old version."
    ExecWait '"$1\Uninstall.exe" /S _?=$1'
	Delete "$1\Uninstall.exe"
	RMDir "$1"
  ${EndIf}

  ; Delete libcec.dll and libcec.x64.dll from the system directory
  ; Let a seperate installer do this, when we need it
  Delete "$SYSDIR\libcec.dll"
  ${If} ${RunningX64}
    Delete "$SYSDIR\libcec.x64.dll"
  ${EndIf}

  ; Copy to the installation directory
  SetOutPath "$INSTDIR"
  File "..\AUTHORS"
  File "..\COPYING"

  ; Copy the driver installer
  SetOutPath "$INSTDIR\driver"
  File "..\build\p8-usbcec-driver-installer.exe"

  ;Store installation folder
  WriteRegStr HKLM "Software\Pulse-Eight\USB-CEC Adapter software" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetOutPath "$INSTDIR"

  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall Pulse-Eight USB-CEC Adapter software.lnk" "$INSTDIR\Uninstall.exe" \
    "" "$INSTDIR\Uninstall.exe" 0 SW_SHOWNORMAL \
    "" "Uninstall Pulse-Eight USB-CEC Adapter software."

  WriteINIStr "$SMPROGRAMS\$StartMenuFolder\Visit Pulse-Eight.url" "InternetShortcut" "URL" "http://www.pulse-eight.com/"
  !insertmacro MUI_STARTMENU_WRITE_END  
    
  ;add entry to add/remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "DisplayName" "Pulse-Eight USB-CEC Adapter software"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "NoRepair" 1
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "DisplayIcon" "$INSTDIR\cec-client.exe,0"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "Publisher" "Pulse-Eight Limited"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "HelpLink" "http://www.pulse-eight.com/"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware" \
                 "URLInfoAbout" "http://www.pulse-eight.com"

  ;install driver
  ExecWait '"$INSTDIR\driver\p8-usbcec-driver-installer.exe" /S'
  Delete "$INSTDIR\driver\p8-usbcec-driver-installer.exe"
SectionEnd

Section "libCEC" SecLibCec
  SetShellVarContext current
  SectionIn 1 3

  ; Copy to the installation directory
  SetOutPath "$INSTDIR"
  File "..\ChangeLog"
  File "..\README"
  File "..\build\*.dll"
  SetOutPath "$INSTDIR\x64"
  File /nonfatal "..\build\x64\*.dll"

  ; Copy to XBMC\system
  ReadRegStr $1 HKCU "Software\XBMC" ""
  ${If} $1 != ""
    SetOutPath "$1\system"
	File "..\build\libcec.dll"
  ${EndIf}

  ; Copy the headers
  SetOutPath "$INSTDIR\include"
  File /r /x *.so "..\include\cec*.*"
SectionEnd

Section "CEC debug client" SecCecClient
  SetShellVarContext current
  SectionIn 3

  ; Copy to the installation directory
  SetOutPath "$INSTDIR"
  File /x p8-usbcec-driver-installer.exe /x cec-config-gui.exe "..\build\*.exe"
  SetOutPath "$INSTDIR\x64"
  File /nonfatal /x cec-config-gui.exe "..\build\x64\*.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetOutPath "$INSTDIR"

  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  ${If} ${RunningX64}
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\CEC Test client (x64).lnk" "$INSTDIR\x64\cec-client.x64.exe" \
      "" "$INSTDIR\cec-client.x64.exe" 0 SW_SHOWNORMAL \
      "" "Start the CEC Test client (x64)."
  ${Else}
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\CEC Test client.lnk" "$INSTDIR\cec-client.exe" \
      "" "$INSTDIR\cec-client.exe" 0 SW_SHOWNORMAL \
      "" "Start the CEC Test client."
  ${EndIf}
  !insertmacro MUI_STARTMENU_WRITE_END  
    
SectionEnd

Section "CEC configuration tool" SecCecConfig
  SetShellVarContext current
  SectionIn 1 3

  ; Copy to the installation directory
  SetOutPath "$INSTDIR"
  File "..\build\cec-config-gui.exe"
  SetOutPath "$INSTDIR\x64"
  File /nonfatal "..\build\x64\cec-config-gui.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  SetOutPath "$INSTDIR"

  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  ${If} ${RunningX64}
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\CEC Adapter Configuration (x64).lnk" "$INSTDIR\x64\cec-config-gui.exe" \
      "" "$INSTDIR\x64\cec-config-gui.exe" 0 SW_SHOWNORMAL \
      "" "Start the CEC Adapter Configuration tool (x64)."
  ${Else}
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\CEC Adapter Configuration.lnk" "$INSTDIR\cec-config-gui.exe" \
      "" "$INSTDIR\cec-config-gui.exe" 0 SW_SHOWNORMAL \
      "" "Start the CEC Adapter Configuration tool."
  ${EndIf}
  !insertmacro MUI_STARTMENU_WRITE_END  
    
SectionEnd

!define REDISTRIBUTABLE_SECTIONNAME "Microsoft Visual C++ 2010 Redistributable Package"
Section "" SecVCRedist
  SetShellVarContext current
  SectionIn 1 3


  ${If} $VSRedistInstalled != "Yes"
    ; Download redistributable
    SetOutPath "$TEMP\vc20XX"
    ${If} ${RunningX64}
      NSISdl::download http://packages.pulse-eight.net/windows/vcredist_x64.exe vcredist_x64.exe
      ExecWait '"$TEMP\vc20XX\vcredist_x64.exe" /q' $VSRedistSetupError
    ${Else}
      NSISdl::download http://packages.pulse-eight.net/windows/vcredist_x86.exe vcredist_x86.exe
      ExecWait '"$TEMP\vc20XX\vcredist_x86.exe" /q' $VSRedistSetupError
    ${Endif}
    RMDIR /r "$TEMP\vc20XX"
  ${Endif}

SectionEnd

Function .onInit

  ; SP0 x86
  ReadRegDword $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{196BB40D-1578-3D01-B289-BEFC77A11A1E}" "Version"
  ${If} $1 != ""
    StrCpy $VSRedistInstalled "Yes"
  ${Endif}

  ; SP0 x64
  ReadRegDword $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DA5E371C-6333-3D8A-93A4-6FD5B20BCC6E}" "Version"
  ${If} $1 != ""
    StrCpy $VSRedistInstalled "Yes"
  ${Endif}

  ; SP0 ia64
  ReadRegDword $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C1A35166-4301-38E9-BA67-02823AD72A1B}" "Version"
  ${If} $1 != ""
    StrCpy $VSRedistInstalled "Yes"
  ${Endif}

  ; SP1 x86
  ReadRegDword $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}" "Version"
  ${If} $1 != ""
    StrCpy $VSRedistInstalled "Yes"
  ${Endif}

  ; SP1 x64
  ReadRegDword $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1D8E6291-B0D5-35EC-8441-6616F567A0F7}" "Version"
  ${If} $1 != ""
    StrCpy $VSRedistInstalled "Yes"
  ${Endif}

  ; SP1 ia64
  ReadRegDword $1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{88C73C1C-2DE5-3B01-AFB8-B46EF4AB41CD}" "Version"
  ${If} $1 != ""
    StrCpy $VSRedistInstalled "Yes"
  ${Endif}

  ${If} $VSRedistInstalled == "Yes"
    !insertMacro UnSelectSection ${SecVCRedist}
    SectionSetText ${SecVCRedist} ""
  ${Else}
    !insertMacro SelectSection ${SecVCRedist}
    SectionSetText ${SecVCRedist} "${REDISTRIBUTABLE_SECTIONNAME}"
  ${Endif}

FunctionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  SetShellVarContext current

  Delete "$INSTDIR\AUTHORS"
  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\ChangeLog"
  Delete "$INSTDIR\COPYING"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\*.lib"
  Delete "$INSTDIR\x64\*.dll"
  Delete "$INSTDIR\x64\*.lib"
  Delete "$INSTDIR\x64\*.exe"
  Delete "$INSTDIR\README"
  Delete "$SYSDIR\libcec.dll"
  ${If} ${RunningX64}
    Delete "$SYSDIR\libcec.x64.dll"
  ${EndIf}

  ; Uninstall the driver
  ReadRegStr $1 HKLM "Software\Pulse-Eight\USB-CEC Adapter driver" ""
  ${If} $1 != ""
    ExecWait '"$1\Uninstall.exe" /S _?=$1'
  ${EndIf}

  RMDir /r "$INSTDIR\include"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"
  RMDir "$PROGRAMFILES\Pulse-Eight"
  
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\CEC Adapter Configuration.lnk"
  ${If} ${RunningX64}
    Delete "$SMPROGRAMS\$StartMenuFolder\CEC Adapter Configuration (x64).lnk"
  ${EndIf}
  Delete "$SMPROGRAMS\$StartMenuFolder\CEC Test client.lnk"
  ${If} ${RunningX64}
    Delete "$SMPROGRAMS\$StartMenuFolder\CEC Test client (x64).lnk"
  ${EndIf}
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall Pulse-Eight USB-CEC Adapter software.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\Visit Pulse-Eight.url"
  RMDir "$SMPROGRAMS\$StartMenuFolder"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter sofware"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Pulse-Eight USB-CEC Adapter driver"
  DeleteRegKey /ifempty HKLM "Software\Pulse-Eight\USB-CEC Adapter software"
  DeleteRegKey /ifempty HKLM "Software\Pulse-Eight"
SectionEnd
