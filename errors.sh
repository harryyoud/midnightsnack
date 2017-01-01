GetErrorDesc() {
  $ErrorNum=$1
  case $ErrorNum in
    200)
      ErrorDesc="You've missed argument 2 for LogCommandMake(), it needs to 'a' for append or 'r' for rewrite"
      ;;
    201)
      ErrorDesc="Argument 2 for LogCommandMake() is neither 'a' nor 'r'"
      ;;
    202)
      ErrorDesc="You've missed argument 2 for LogMake(), it needs to 'a' for append or 'r' for rewrite"
      ;;
    203)
      ErrorDesc="Argument 2 for LogMake() is neither 'a' nor 'r'"
      ;;
    204)
      ErrorDesc="You've missed argument 2 for LogCommandMain(), it needs to 'a' for append or 'r' for rewrite"
      ;;
    205)
      ErrorDesc="Argument 2 for LogCommandMain() is neither 'a' nor 'r'"
      ;;
    206)
      ErrorDesc="You've missed argument 2 for LogMain(), it needs to 'a' for append or 'r' for rewrite"
      ;;
    207)
      ErrorDesc="Argument 2 for LogMain() is neither 'a' nor 'r'"
      ;;
    *)
      ErrorDesc=""
      ;;
  esac;
  echo "$ErrorDesc"
}
