GetErrorDesc() {
  $ErrorNum=$1
  case $ErrorNum in
    100)
      ErrorDesc="\$BuildTomorrow is not true/false, assuming building for today ($(date +%Y%m%d))"
      ;;
    *)
      ErrorDesc=""
      ;;
  esac;
  echo "$ErrorDesc"
}
