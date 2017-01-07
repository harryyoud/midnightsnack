GetErrorDesc() {
  ErrorNum=$1
  case $ErrorNum in
    200)
      ErrorDesc="Make failed. Check $MakeLogFile"
      ;;
    201)
      ErrorDesc="MidnightSnackLunch() needs 1 argument (the device codename)"
      ;;
    202)
      ErrorDesc="Lunch failed. Is $LunchCommand on the menu?"
      ;;
    211)
      ErrorDesc="GetNewName() needs 1 argument (the device codename)"
      ;;
    212)
      ErrorDesc="Output ZIP was not found (maybe make failed silently?)"
      ;;
    213)
      ErrorDesc="Out folder for $Device doesn't exist. Something weird has happened"
      ;;
    214)
      ErrorDesc="GetOutputZip() needs 1 argument (the device codename)"
      ;;
    215)
      ErrorDesc="Output ZIP provided to GetLocalMD5SUM doesn't exist"
      ;;
    216)
      ErrorDesc="GetLocalMD5SUM() needs 1 argument (the output zip)"
      ;;
    217)
      ErrorDesc="UploadZipAndRename() needs 2 arguments (fullzippath, zipname). You provided only 1"
      ;;
    218)
      ErrorDesc="UploadZipAndRename() needs 2 arguments (fullzippath, zipname). You provided none"
      ;;
    219)
      ErrorDesc="UploadMD5() needs 2 arguments (fullzippath, zipname). You provided only 1"
      ;;
    220)
      ErrorDesc="UploadMD5() needs 2 arguments (fullzippath, zipname). You provided none"
      ;;
    230)
      ErrorDesc="\$SourceTreeLoc not set in settings.sh. This is a required variable"
      ;;
    231)
      ErrorDesc="\$DeviceList is not set in settings.sh. This is a required variable"
      ;;
    232)
      ErrorDesc="\$DeviceList is not an array. This is needs to be an array, regardless of if you have one device to build for"
      ;;
    234)
      ErrorDesc="\$RomVariant is not set in settings.sh. This is a required variable"
      ;;
    235)
      ErrorDesc="\$RomBuildType is not set in settings.sh. This is a required variable"
      ;;
    236)
      ErrorDesc="\$RomVersion is not set in settings.sh. This is a required variable"
      ;;
    238)
      ErrorDesc="\$SSHHost is not set in settings.sh. This is a required variable as \$SSHUpload = true"
      ;;
    239)
      ErrorDesc="\$SSHUser is not set in settings.sh. This is a required variable as \$SSHUpload = true"
      ;;
    240)
      ErrorDesc="\$SSHPort is not set in settings.sh. This is a required variable as \$SSHUpload = true"
      ;;
    241)
      ErrorDesc="\$SSHDirectory is not set in settings.sh. This is a required variable as \$SSHUpload = true"
      ;;
    242)
      ErrorDesc="\$RepoPicks needs to be an array in settings.sh if it is declared"
      ;;
    243)
      ErrorDesc="\$JackRAM is not set in settings.sh. This is a required variable"
      ;;
    244)
      ErrorDesc="\$RepoPicks needs to be an array in settings.sh if it is declared"
      ;;    
    *)
      ErrorDesc="This is embarassing. I have no explanation"
      ;;
  esac;
}
