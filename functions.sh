LogMake() {
  # Set log file name
  $MakeLogFile=$RomVariant'-'$RomVersion'-'$(BuildDate)'-'$Officiality'-'$Device'.zip.log'
  # If append  mode is enabled, append output to file
  if [ $2 = "a" ]; then
      "$1" >> $MakeLogFile 2>&1
    # If rewrite mode is enabled, overwite file
    elif [ $2 = "r" ]; then
      "$1" >  $MakeLogFile 2>&1
    else
      echo "Error 200: You've missed argument 3 for LogMake(), it needs to 'a' for append or 'r' for rewrite"
      exit 200
  fi;
}

SupperLunch() {
  LogMake "lunch $RomVariant'_'$DeviceCodename'-'$RomBuildType";
}

BuildDate() {
  echo $(date --date="+1 day" +%Y%m%d);
}
