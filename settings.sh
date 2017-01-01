#!/bin/bash

# Needed Settings
  SourceTreeLoc="/home/harry/android/system"
  DeviceList=(  "angler"
                "deb"
                "falcon"
                "flo"
                "flounder"
                "flounder_lte"
                "huashan"
                "klte"
                "serranoltexx"  )
  SyncOnStart=true
  LogFileLoc="/home/harry/android/system/logs"
  DeleteBuildAfterUpload=true
  UseCcache=true
  RomVariant="cm"
  RomBuildType="userdebug"
  RomVersion="14.1"
  Officiality="UNOFFICIAL"

# Optionals
  BuildTomorrow=true
  StopOnWarn=false
# SSH Upload
