#!/bin/bash

# 1.  Import includes (functions, settings, error descs) and set vars
# 2.  CheckVariablesExist
# 3.  LogHeaders
# 4.  Repo Sync
# 5.  DeviceLoop
#       5a. LogHeaders
#       5b. Lunch
#       5c. Make
#       5d. Find and rename zip
#       5e. MD5sum
#       5f. Upload zip, then rename
#       5g. Delete Build zip
# 6.  TarGZ logs
# 7.  Drop email with successes and fails with attached logs (coming in Version 2)



# 1. Import includes (functions, settings, error descs) and set vars
      whereami=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
      source $whereami/functions.sh
      source $whereami/settings.sh
      source $whereami/errors.sh
      GetBuildDate
      StartTimestamp=$(date +%s)
      Version='1.1.0'


# 2.  CheckVariablesExist
#     This is important, as empty variables will wreak havoc
#     We'll only check the "Needed settings"

      CheckVariablesExist
      export USER=$(whoami)
      if [[ UseCcache = true ]]; then
        export USE_CCACHE=1
      else
        export USE_CCACHE=0
      fi

# 3.  LogHeaders
#     We'll output all the admin information at the top of the log file, so it can be seen
#     We'll set the builddate here too, so it's early and can be outputted

      LogMain "Beginning midnightsnack v$Version on $(hostname) for $USER"
      LogMain "The time is $(date +'%T') on $(date +%Y/%m/%d)"
      LogMain "Devices to build for: ${DeviceList[*]}"
      LogMain "Build date is going to be set to $BuildDate"

      if [[ $StopOnWarn = true ]]; then
        LogMain "We'll bail out on warnings"
      else
        LogMain "We'll ignore warnings and bail out on errors"
      fi

      LogMain "Moving into $SourceTreeLoc"
      cd $SourceTreeLoc
      LogMain "Sourcing envsetup.sh"
      LogCommandMainErrors "source build/envsetup.sh"

# 4.  Repo Sync
#     If $SyncOnStart is set, sync repositories
#     Only output errors to log, and send stdout to /dev/null

      if [[ $SyncOnStart = true ]]; then
        LogMain "Syncing repositories"
        LogCommandMainErrors "/home/$USER/bin/repo sync"
      else
        LogMain "\$SyncOnStart not set; skipping repo sync"
      fi
      if ! [[ -z $RepoPicks ]]; then
        LogMain "Applying repopicks from Gerrit (by changeID):"
          for RepoChangeID in "${RepoPicks[@]}"; do
            LogCommandMainErrors "repopick $RepoChangeID"
          done
        LogMain "Repopicks (by changeID) complete"
      else
        LogMain "No repopick changeIDs defined; skipping"
      fi
      if ! [[ -z $RepoTopics ]]; then
        LogMain "Applying repopicks from Gerrit (by topic):"
          for RepoTopic in "${RepoTopics[@]}"; do
            LogCommandMainErrors "repopick -t $RepoTopic"
          done
        LogMain "Repopicks (by topic) complete"
      else
        LogMain "No repopick topics defined; skipping"
      fi
      if [[ $MakeClean = "AtStart" ]] || [[ $MakeClean = "BetweenDevices" ]]; then
        LogMain "Removing build directory, as \$MakeClean set to $MakeClean"
        LogCommandMainErrors "make clean"
      else
        LogMain "Skipping make clean as MakeClean set to No"
      fi


# 5.  DeviceLoop
#     "It's just like replaying the worst day of your life over and over"
#     Begin the mega loop. To summarise, we'll iterate over the DeviceList, say some stuff, build and upload

      LogMain "Beginning main device loop at $(date +'%T')"
      for Device in "${DeviceList[@]}"; do

#       5a. LogHeaders
#       So we'll talk crap to the main log for a minute
        LogMain "Beginning loop as $Device:"

#       5b. Lunch
#       This builds some makefiles and tells mka what device and variant we're building
        LogMain "\tTaking lunch for $Device"
        MidnightSnackLunch $Device

#       5c. Make
#       This kicks off ninja amongst other things that makes the final files for our device
        LogMain "\tKilling Jack"
        LogCommandMainErrors "KillJack"
        LogMain "\tBringing him back to life with more resources"
        LogCommandMainErrors "ResuscitateJack"

        if [[ $MakeClean = "BetweenDevices" ]]; then
          LogMain "Cleaning build directory, as \$MakeClean set to $MakeClean"
          LogCommandMainErrors "make clean"
        fi

        if [[ -z $MakeThreadCount ]]; then
          LogMain "\tMaking for $Device. Get the kettle on!"
        else
          LogMain "\tMaking for $Device with $MakeThreadCount threads. Get the kettle on!"
        fi
        MidnightSnackMake
        LogMain "\tMake finished"
        # Take next to last line of makelog, removes ### from start and end and removes colour control characters
        LastLineMakeLogFile=$(tail -n 2 $MakeLogFile | head -n 1 | tr -d \# | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" | cut -b 2-)
        LogMain "\t$LastLineMakeLogFile"

#       5d. Find and rename zip
#       This finds the most recently modified zip file in the device out directory, and renames it to something sensible
        GetOutputZip $Device
        LogMain "\tFound zip at $OutputZip"
        GetNewName $Device
        LogMain "\tRenaming it to $NewName"
        NewOutputZip=$SourceTreeLoc/out/target/product/$Device/$NewName
        LogCommandMainErrors "mv $OutputZip $NewOutputZip"

#       5e. MD5SUM
#       Output md5sum of zip to log and file
        GetLocalMD5SUM $NewOutputZip
        LogMain "\tCreating $NewOutputZip.md5sum"
        echo $MD5SUM > $NewOutputZip.md5sum
        LogMain "\tMD5sum of zip: ${MD5SUM:0:32}"

#       5f. Upload zip, then rename
#       We first upload the zip. The zip is named weird, as we don't want people downloading it while it's uploading
#       After both have been uploaded, we can rename the zip
        if [[ $SSHUpload = true ]]; then
          LogMain "\tUploading zip to $SSHHost"
          LogCommandMainErrors "UploadZipAndRename $NewOutputZip $NewName"
          LogMain "\tUploading MD5"
          LogCommandMainErrors "UploadMD5 $NewOutputZip $NewName"
        else
          LogMain "\tSkipping SSH Upload as \$SSHUpload not set"
        fi
#     End it all; I want to die
#     Go back to 5a. and start again
      LogMain "\tFinished main device loop for $Device"
      done
      LogMain "Completed the loop of death. Continuing..."
      LogMain "Killing Jack once and for all"
      LogCommandMainErrors "KillJack"


# 6.  TarGZ Logs
      LogMain "Archiving logs after last message of this script"
      LogMain "Finished script at $(date +'%T') on $(date +%Y/%m/%d)"
      SecondsForScript=$(expr $(date +%s) - $StartTimestamp)
      LogMain "That means it took $(printf '%dh:%dm:%ds\n' $(($SecondsForScript/3600)) $(($SecondsForScript%3600/60)) $(($SecondsForScript%60)))"
      LogMain "And we're done!"
      pushd $LogFileLoc
        LogCommandMainErrors "tar --remove-files -czvf $RomVariant-$RomVersion-$BuildDate-UNOFFICIAL.tar.gz $RomVariant-$RomVersion-$BuildDate-*"
        if ! [[ -e archives ]]; then
          LogCommandMainErrors "mkdir archives"
        fi
        mv $RomVariant-$RomVersion-$BuildDate-UNOFFICIAL.tar.gz archives/
      popd


# 7.  Drop email with successes and fails with attached logs
#     WIP
