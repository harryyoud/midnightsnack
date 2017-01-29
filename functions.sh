CheckVariablesExist() {
  if [[ -z $SourceTreeLoc ]]; then
    HandleError 230; fi
  if [[ -z $DeviceList ]]; then
    HandleError 231; fi
  if ! [[ "$(declare -p DeviceList)" =~ "declare -a" ]]; then
    HandleError 232; fi
  if [[ -z $LogFileLoc ]]; then
    HandleError 233; fi
  if [[ -z $RomVariant ]]; then
    HandleError 234; fi
  if [[ -z $RomBuildType ]]; then
    HandleError 235; fi
  if [[ -z $RomVersion ]]; then
    HandleError 236; fi
  if [[ -z $JackRAM ]]; then
    HandleError 243; fi
  if [[ -z $MakeClean ]]; then
    HandleError 237; fi
  if ! [[ -z $RepoPicks ]]; then
    if ! [[ "$(declare -p RepoPicks)" =~ "declare -a" ]]; then
      HandleError 242; fi
  fi
  if ! [[ -z $RepoTopics ]]; then
    if ! [[ "$(declare -p RepoTopics)" =~ "declare -a" ]]; then
      HandleError 244; fi
  fi
  if [[ $SSHUpload = true ]]; then
    if [[ -z $SSHHost ]]; then
      HandleError 238; fi
    if [[ -z $SSHUser ]]; then
      HandleError 239; fi
    if [[ -z $SSHPort ]]; then
      HandleError 240; fi
    if [[ -z $SSHDirectory ]]; then
      HandleError 241; fi
  fi
}

HandleError() {
  # Check we were passed an error code as 1st argument
  if ! [[ -z "$1" ]]; then
    # If it's error 210 (log file not writable), exit without writing to log file (otherwise we go round in circles)
    if [[ $1 = 210 ]]; then
      # Log file not writable
      echo "Log file directory not writable, aborting"
      exit 210
    elif [[ $1 = 233 ]]; then
      # If it's error 233, $LogFileLoc has not been set, so don't write a log
      echo "\$LogFileLoc not defined in settings.sh. This is needed desperately"
      exit 233
    else
      # All other error codes are looked up
      ErrorNum=$1
      # Get error description (listed in ./errors.sh)
      GetErrorDesc $ErrorNum
      LogMain "Error $ErrorNum: $ErrorDesc"
      LogMain 'Killing jack-server and stopping due to error'
      LogCommandMainErrors "KillJack"
      exit $ErrorNum
    fi
  else
    # We weren't passed an error code, so exit
    LogMain "Unspecified Error" "a"
    LogMain 'Killing jack-server and stopping due to error' "a"
    LogCommandMainErrors "KillJack"
    exit 255
  fi
}

HandleWarn() {
  # Check we were passed a warning code as 1st argument
  if ! [[ -z "$1" ]]; then
    WarnNum=$1
    GetErrorDesc $WarnNum
    LogMain "Warning $WarnNum: $ErrorDesc"
    # If StopOnWarn in settings is set, then we stop on non-trivial errors (==warnings)
    if [[ $StopOnWarn = true ]]; then
      LogMain 'Stopping as \$StopOnWarn set' "a"
      exit $WarnNum
    fi
  else
    LogMain "Unspecified Warning (probably non-breaking)" "a"
    if [[ $StopOnWarn = true ]]; then
      LogMain 'Stopping as \$StopOnWarn set' "a"
      exit 255
    fi
  fi
}

LogCommandMake() {
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'UNOFFICIAL'-'$Device'.zip.log'
  # If log file folder isn't writable, error code 210 passed
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    # If Log is called in rewrite mode (Log "Blah blah" "r"), overwrite log file
    if [[ "$2" = "r" ]]; then
      $1 >  "$MakeLogFile" 2>&1
                #          ^^^^ redirect errors too
    # Otherwise, append
    else
      $1 >>  "$MakeLogFile" 2>&1
    fi
  else
    $1 >>  "$MakeLogFile" 2>&1
  fi;
}

LogMake() {
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'UNOFFICIAL'-'$Device'.zip.log'
  # If log file folder isn't writable, error code 210 passed
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    # If Log is called in rewrite mode (Log "Blah blah" "r"), overwrite log file
    if [[ "$2" = "r" ]]; then
      printf "%b\r\n"  "$1" >  "$MakeLogFile" 2>&1
                     #          ^^^^ redirect errors too
    # Otherwise, append
    else
      printf "%b\r\n"  "$1" >>  "$MakeLogFile" 2>&1
    fi
  else
    printf "%b\r\n"  "$1" >>  "$MakeLogFile" 2>&1
  fi;
}

LogCommandMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'UNOFFICIAL'.log'
  # If log file folder isn't writable, error code 210 passed
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    # If Log is called in rewrite mode (Log "Blah blah" "r"), overwrite log file
    if [[ "$2" = "r" ]]; then
      $1 >  "$MainLogFile" 2>&1
                #          ^^^^ redirect errors too
    # Otherwise, append
    else
      $1 >>  "$MainLogFile" 2>&1
    fi
  else
    $1 >>  "$MainLogFile" 2>&1
  fi;
}

LogCommandMainErrors() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'UNOFFICIAL'.log'
  # If log file folder isn't writable, error code 210 passed
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    # If Log is called in rewrite mode (Log "Blah blah" "r"), overwrite log file
    if [[ "$2" = "r" ]]; then
      $1 >/dev/null 2> "$MainLogFile"
      #             ^^^^^^^^^^^^^^^^^ redirect errors to MainLog
      #  ^^^^^^^^^^ discard stdout
    # Otherwise, append
    else
      $1 >>/dev/null 2>> "$MainLogFile"
    fi
  else
    $1 >>/dev/null 2>> "$MainLogFile"
  fi;
}

LogMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'UNOFFICIAL'.log'
  # If log file folder isn't writable, error code 210 passed
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
  # If log file folder isn't writable, error code 210 passed
    if [[ "$2" = "r" ]]; then
      printf "%b\r\n" "$1" > "$MainLogFile" 2>&1
    # Otherwise, append
    else
      printf "%b\r\n" "$1" >> "$MainLogFile" 2>&1
    fi
  else
    printf "%b\r\n" "$1" >> "$MainLogFile" 2>&1
  fi;
}

MidnightSnackLunch() {
  # Check we've been given argument 1 (device)
  if ! [[ -z $1 ]]; then
    # Run this from source directory...
    cd $SourceTreeLoc
    # ... for envsetup.sh to work
    LogCommandMainErrors "source build/envsetup.sh"
    LunchCommand=$RomVariant'_'$1'-'$RomBuildType
    LogCommandMake "lunch $LunchCommand" || HandleError 202
  else
    # Gimme more arguments
    HandleError 201
  fi
}

MidnightSnackMake() {
  if [[ -z $MakeThreadCount ]]; then
    LogCommandMake "mka otapackage" || HandleError 200
  else
    LogCommandMake "make -j$MakeThreadCount otapackage" || HandleError 200
  fi
}

GetBuildDate() {
  if [[ $BuildTomorrow = true ]]; then
      # Get YYYYMMDD for tomorrow
      BuildDate=$(date --date="+1 day" +%Y%m%d);
  else
    # Get YYYYMMDD for today
    BuildDate=$(date +%Y%m%d);
  fi
}

GetNewName() {
  # Check we've been given the first argument (device)
  if ! [[ -z $1 ]]; then
    NewName=$RomVariant'-'$RomVersion'-'$BuildDate'-'UNOFFICIAL'-'$1'.zip'
  else
    # Can I haz moar argument?
    HandleError 211
  fi
}

GetOutputZip() {
  # Check we've been given first argument (device)
  if ! [[ -z $1 ]]; then
    # Check device output folder exists
    if [[ -e $SourceTreeLoc/out/target/product/$1 ]]; then
                # find *.zip in the root of the output directory, reverse ordered by date modified, take the top line
      OutputZip=$(find $SourceTreeLoc/out/target/product/$1/ -maxdepth 1 -name '*.zip' -printf "%T+\t%p\n" | sort -r | cut -f 2- | head -n 1)
                #                                                                                                                  ^^^^^^^^^ take top line
                #                                                                                                      ^^^^^^^^^ take the second field after the tab (chop date modified off front)
                #                                                                                            ^^^^^^^ sort numerically in reverse
                #                                                                      ^^^^^^^^^^^^^^^^^^^ print as "2017-01-02+18:45:41.7878729150 android/system/out/target/product/angler/cm_angler-ota-a0db5d5712.zip"
                #                                                        ^^^^^^^^^^^^^ All zip files
                #                                            ^^^^^^^^^^^ Only files in the root of the directory
      # If find found a zip, output it
      if [[ -z $OutputZip ]]; then
        HandleError 212
      fi
    else
      # The device output folder doesn't exist
      HandleError 213
    fi
  else
    # Not given device argument
    HandleError 214
  fi
}

GetLocalMD5SUM() {
  # Check we've been given first argument (OutputZip)
  if ! [[ -z $1 ]]; then
    # Check output zip exists
    if [[ -e $1 ]]; then
      MD5SUM=$(md5sum $1)
    else
      # Output file doesn't exist
      HandleError 215
    fi
  else
    # First argument not given
    HandleError 216
  fi
}

UploadZipAndRename() {
  # Check we've been given first argument (Absolute path to zip)
  if ! [[ -z $1 ]]; then
    # Check we've been given second argument (Name of zip file)
    if ! [[ -z $2 ]]; then
      LocalZipPath=$1
      LocalZipName=$2
      ssh $SSHUser@$SSHHost -p $SSHPort "mkdir -p $SSHDirectory/$Device"
      # Upload Zip file to nameofzipfile.zip.part
      scp -P $SSHPort $LocalZipPath $SSHUser@$SSHHost:"$SSHDirectory/$Device/$LocalZipName.part"
      # Move nameofzipfile.zip.part to nameofzipfile
      ssh $SSHUser@$SSHHost -p $SSHPort "mv $SSHDirectory/$Device/$LocalZipName.part $SSHDirectory/$Device/$LocalZipName"
    else
      # Second argument not given
      HandleError 217
    fi
  else
    # First argument not given
    HandleError 218
fi
}

UploadMD5() {
  # Check for first argument (Absolute path to zip file)
  if ! [[ -z $1 ]]; then
    # Check for second argument (Name of zip file)
    if ! [[ -z $2 ]]; then
      LocalZipPath=$1
      LocalZipName=$2
      ssh $SSHUser@$SSHHost -p $SSHPort "mkdir -p $SSHDirectory/$Device"
      scp -P $SSHPort $LocalZipPath.md5sum $SSHUser@$SSHHost:"$SSHDirectory/$Device/$LocalZipName.md5sum"
    else
      # Second argument not given
      HandleError 219
    fi
  else
    # First argument given
    HandleError 220
fi
}

KillJack() {
  # Kill the jack-server so we can restart with more RAM
  cd $SourceTreeLoc
  ./prebuilts/sdk/tools/jack-admin list-server && ./prebuilts/sdk/tools/jack-admin kill-server
}

ResuscitateJack() {
  # Bring Jack back with more RAM
  cd $SourceTreeLoc
  export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx$JackRAM"
  ./prebuilts/sdk/tools/jack-admin start-server
}

TrapCtrlC() {
  LogMain "Ctrl-C caught. Beginning clean up and ending..."
  echo "We've got your message, give us a second to clean up and we'll hand back control"
  LogMain "We leave no men or women behind. We're taking Jack and Jill with us"
  # Oops, we killed him
  LogCommandMainErrors "KillJack"
  LogMain "Cleanup finished. Now we quit."
  echo "All done. See you in the afterlife"
  HandleError 245
}
