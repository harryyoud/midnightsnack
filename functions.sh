HandleError() {
  if [ -z "$1" ]; then
    if [ $1 = 210 ]; then
      # Log file not readable
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
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$(BuildDate)'-'$Officiality'-'$Device'-mka.zip.log'
  if [ -w $MakeLogFile ]; then
    HandleError 210
  fi
  if [ -z "$2" ]; then
    if [ "$2" = "a" ]; then
      "$1" >> "$MakeLogFile" 2>&1
    elif [ "$2" = "r" ]; then
      "$1" >  "$MakeLogFile" 2>&1
    else
      HandleError 201
    fi;
  else
    HandleError 200
  fi;
}

LogMake() {
  MakeLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$(BuildDate)'-'$Officiality'-'$Device'-mka.zip.log'
  if [ -w $MakeLogFile ]; then
    HandleError 210
  fi
  if [ -z "$2" ]; then
    if [ "$2" = "a" ]; then
      echo "$1" >> "$MakeLogFile" 2>&1
    elif [ "$2" = "r" ]; then
      echo "$1" >  "$MakeLogFile" 2>&1
    else
      HandleError 202
    fi
  else
    HandleError 203
  fi;
}

LogCommandMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$(BuildDate)'-'$Officiality'.zip.log'
  if [ -w $MainLogFile ]; then
    HandleError 210
  fi
  if [ -z "$2" ]; then
    if [ "$2" = "a" ]; then
      "$1" >> "$MainLogFile" 2>&1
    elif [ "$2" = "r" ]; then
      "$1" >  "$MainLogFile" 2>&1
    else
      HandleError 204
    fi
  else
    HandleError 205
  fi;
}

LogMain() {
  MainLogFile=$LogFileLoc'/'$RomVariant'-'$RomVersion'-'$(BuildDate)'-'$Officiality'.zip.log'
  if [ -w $MainLogFile ]; then
    HandleError 210
  fi
  if [ -z "$2" ]; then
    if [ "$2" = "a" ]; then
      echo "$1" >> "$MainLogFile" 2>&1
    # If rewrite mode is enabled, overwite file
    elif [ "$2" = "r" ]; then
      echo "$1" >  "$MainLogFile" 2>&1
    else
      HandleError 206
    fi
  else
    HandleError 207
  fi;
}

LogLunch() {
  LogCommandMake "lunch $RomVariant'_'$DeviceCodename'-'$RomBuildType";
}

LogBuild() {
  LogCommandMake "mka otapackage"
}

BuildDate() {
  if [ $BuildTomorrow = true ]; then
      echo $(date --date="+1 day" +%Y%m%d);
    elif [ $BuildTomorrow = false]; then
      echo $(date +%Y%m%d);
    else
      LogMain "\$BuildTomorrow is not true/false, assuming building for today ($(date +%Y%m%d))"
      echo $(date +%Y%m%d);
  fi;
}
