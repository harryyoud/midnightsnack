HandleError() {
  if [ -z "$1" ]; then
    if [ $1 = 210 ]; then
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
  fi
}

HandleWarn() {
  if [ -z "$1" ]; then
    WarnNum=$1
    GetErrorDesc $WarnNum
    LogMain '"Warning "$WarnNum": "$ErrorDesc' "a"
    if [ $StopOnWarn = true ]; then
      LogMain 'Stopping as \$StopOnWarn set' "a"
      exit $WarnNum
    fi
  else
    LogMain "Unspecified Warning (probably non-breaking)" "a"
    if [ $StopOnWarn = true ]; then
      LogMain 'Stopping as \$StopOnWarn set' "a"
      exit 255
    fi
  fi
}

LogCommandMake() {
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'-'$Device'-mka.zip.log'
  if ! [ -w $LogFileLoc ]; then
    HandleError 210
  fi
  if ! [ -z "$2" ]; then
    if [ "$2" = "r" ]; then
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
  if ! [ -w $LogFileLoc ]; then
    HandleError 210
  fi
  if ! [ -z "$2" ]; then
    if [ "$2" = "r" ]; then
      echo "$1" >  "$MakeLogFile" 2>&1
    else
      echo "$1" >>  "$MakeLogFile" 2>&1
    fi
  else
    echo "$1" >>  "$MakeLogFile" 2>&1
  fi;
}

LogCommandMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'.zip.log'
  if ! [ -w $LogFileLoc ]; then
    HandleError 210
  fi
  if ! [ -z "$2" ]; then
    if [ "$2" = "r" ]; then
      "$1" >  "$MainLogFile" 2>&1
    else
      "$1" >>  "$MainLogFile" 2>&1
    fi
  else
    "$1" >>  "$MainLogFile" 2>&1
  fi;
}

LogMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$BuildDate'-'$Officiality'.zip.log'
  if ! [ -w $LogFileLoc ]; then
    HandleError 210
  fi
  if ! [ -z "$2" ]; then
    if [ "$2" = "r" ]; then
      echo "$1" > "$MainLogFile" 2>&1
    else
      echo "$1" >> "$MainLogFile" 2>&1
    fi
  else
    echo "$1" >> "$MainLogFile" 2>&1
  fi;
}

LogLunch() {
  LogCommandMake "lunch $RomVariant'_'$DeviceCodename'-'$RomBuildType";
}

LogBuild() {
  LogCommandMake "mka otapackage"
}

GetBuildDate() {
  if [ $BuildTomorrow = true ]; then
      echo $(date --date="+1 day" +%Y%m%d);
  else
    echo $(date +%Y%m%d);
  fi
}
