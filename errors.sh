GetErrorDesc() {
  $ErrorNum=$1
  case $ErrorNum in
    214)
      ErrorDesc="SupperLunch() needs 1 argument (the device codename)"
      ;;
    211)
      ErrorDesc="GetNewName() needs 1 argument (the device codename)"
      ;;
    213)
      ErrorDesc="Output ZIP was not found (maybe make failed silently?)"
      ;;
    200)
      ErrorDesc="Make failed. Check $MakeLogFile"
      ;;
    212)
      ErrorDesc="Out folder for $Device doesn't exist. Something weird has happened"
      ;;
    213)
      ErrorDesc="GetOutputZip() needs 1 argument (the device codename)"
      ;;
    214)
      ErrorDesc="Output ZIP provided to GetLocalMD5SUM doesn't exist"
      ;;
    215)
      ErrorDesc="GetLocalMD5SUM() needs 1 argument (the output zip)"
      ;;
    216)
      ErrorDesc="UploadZipAndRename() needs 2 arguments (fullzippath, zipname). You provided only 1"
      ;;
    217)
    ErrorDesc="UploadZipAndRename() needs 2 arguments (fullzippath, zipname). You provided none"
      ;;
    218)
    ErrorDesc="UploadMD5() needs 2 arguments (fullzippath, zipname). You provided only 1"
      ;;
    2179)
    ErrorDesc="UploadMD5() needs 2 arguments (fullzippath, zipname). You provided none"
      ;;
    *)
      ErrorDesc="This is embarassing. I have no explanation"
      ;;
  esac;
  echo "$ErrorDesc"
}
