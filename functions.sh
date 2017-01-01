HandleError() {
  if [[ -z "$1" ]]; then
    if [[ $1 = 210 ]]; then
      # Log file not writable
      exit 210
    else
      ErrorNum=$1
      LogMain '"Error "$ErrorNum": "$ErrorDesc' "a"
      LogMain 'Stopping due to error' "a"
      exit $ErrorNum
    fi
  else
    LogMain "Unspecified Error" "a"
    LogMain 'Stopping due to error' "a"
    exit 255
  fi
}

HandleWarn() {
  if [[ -z "$1" ]]; then
    WarnNum=$1
    GetErrorDesc $WarnNum
    LogMain '"Warning "$WarnNum": "$ErrorDesc' "a"
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
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'-'$Device'-mka.zip.log'
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    if [[ "$2" = "r" ]]; then
      "$1" >  "$MakeLogFile" 2>&1
    else
      "$1" >>  "$MakeLogFile" 2>&1
    fi
  else
    "$1" >>  "$MakeLogFile" 2>&1
  fi;
}

LogMake() {
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'-'$Device'-mka.zip.log'
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    if [[ "$2" = "r" ]]; then
      echo "$1" >  "$MakeLogFile" 2>&1
    else
      echo "$1" >>  "$MakeLogFile" 2>&1
    fi
  else
    echo "$1" >>  "$MakeLogFile" 2>&1
  fi;
}

LogCommandMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$(GetBuildDate)'-'$Officiality'.zip.log'
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    if [[ "$2" = "r" ]]; then
      "$1" >  "$MainLogFile" 2>&1
    else
      "$1" >>  "$MainLogFile" 2>&1
    fi
  else
    "$1" >>  "$MainLogFile" 2>&1
  fi;
}

LogCommandMainErrors() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'.zip.log'
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    if [[ "$2" = "r" ]]; then
      "$1" 2>  "$MainLogFile" 1>/dev/null
    else
      "$1" 2>>  "$MainLogFile" 1>/dev/null
    fi
  else
    $1 >>  "$MainLogFile" 2>&1
  fi;
}

LogMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$GetBuildDate'-'$Officiality'.zip.log'
  if ! [[ -w $LogFileLoc ]]; then
    HandleError 210
  fi
  if ! [[ -z "$2" ]]; then
    if [[ "$2" = "r" ]]; then
      echo "$1" > "$MainLogFile" 2>&1
    else
      echo "$1" >> "$MainLogFile" 2>&1
    fi
  else
    echo "$1" >> "$MainLogFile" 2>&1
  fi;
}

SupperLunch() {
  if ! [[ -z $1 ]]; then
    LogCommandMake "lunch $RomVariant'_'$1'-'$RomBuildType";
  else
    HandleError 214
  fi
}

SupperMake() {
  if ! [[ $(LogCommandMake "mka otapackage") ]]; then
    echo 0
  else
    HandleError 200
  fi
}

GetBuildDate() {
  if [[ $BuildTomorrow = true ]]; then
      echo $(date --date="+1 day" +%Y%m%d);
  else
    echo $(date +%Y%m%d);
  fi
}

GetNewName() {
  if ! [[ -z $1 ]]; then
    NewName=$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'-'$1'.zip'
  else
    HandleError 211
  fi
}

GetOutputZip() {
  if ! [[ -z $1 ]]; then
    if [[ -e $SourceTreeLoc/out/target/product/$1 ]]; then
      OutputZip=$(find $SourceTreeLoc/out/target/product/$1/ -maxdepth 1 -name 'cm_*.zip' -printf "%T+\t%p\n" | sort -r | cut -f 2- | head -n 1)
      if ! [[ -z $OutputZip ]]; then
        echo $OutputZip
      else
        HandleError 213
      fi
    else
      HandleError 212
    fi
  else
    HandleError 213
  fi
}

GetLocalMD5SUM() {
  if ! [[ -z $1 ]]; then
    if [[ -e $1 ]]; then
      MD5SUM=$(md5sum $1)
      echo $MD5SUM
    else
      HandleError 214
    fi
  else
    HandleError 215
  fi
}

UploadZipAndRename() {
  if ! [[ -z $1 ]]; then
    if ! [[ -z $2 ]]; then
      LocalZipPath=$1
      LocalZipName=$2
      scp $SSHUser@$SSHHost -P $SSHPort $LocalZipPath $SSHUser@$SSHHost:"$SSHDirectory/$LocalZipName.part"
      ssh $SSHUser@$SSHHost -P $SSHPort mv $SSHDirectory/$LocalZipName.part $SSHDirectory/$LocalZipName
    else
      HandleError 216
    fi
  else
    HandleError 217
fi
}

UploadMD5() {
  if ! [[ -z $1 ]]; then
    if ! [[ -z $2 ]]; then
      LocalZipPath=$1
      LocalZipName=$2
      scp -P $SSHPort $LocalZipPath.md5sum $SSHUser@$SSHHost:"$SSHDirectory/$LocalZipName.md5sum"
    else
      HandleError 218
    fi
  else
    HandleError 219
fi
}
