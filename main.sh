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
# 7.  Drop email with successes and fails with attached logs



# 1. Import includes (functions, settings, error descs) and set vars
      source functions.sh
      source settings.sh
      source errors.sh
      export USER=$(whoami)
      export USE_CCACHE=1

# 2.  CheckVariablesExist
#     This is important, as empty variables will wreak havoc
#     We'll only check the "Needed settings"

      #if ! [[ $(CheckVariablesExist) ]]; then
      #  break
      #else
      #  HandleError 50
      #fi


# 3.  LogHeaders
#     We'll output all the admin information at the top of the log file, so it can be seen
#     We'll set the builddate here too, so it's early and can be outputted

      LogMain "Beginning supper on $(hostname) for $USER"
      LogMain "The time is $(date +'%T') on $(date +%Y/%m/%d)"
      LogMain "Devices to build for: ${DEVICES[*]}"

      BuildDate=$(GetBuildDate)

      LogMain "Build date is going to be set to $BuildDate"

      if [[ $StopOnWarn = true ]]; then
        LogMain "We'll bail out on warnings"
      else
        LogMain "We'll ignore warnings and bail out on errors"
      fi

      LogMain "Moving into $SourceTreeLoc"
      cd $SourceTreeLoc
      LogMain "Sourcing envsetup.sh"
      source build/envsetup.sh

# 4.  Repo Sync
#     If $SyncOnStart is set, sync repositories
#     Only output errors to log, and send stdout to /dev/null

      if [[ $SyncOnStart = true ]]; then
        LogMain "Syncing repositories"
        LogCommandMainErrors "/home/$USER/bin/repo sync"
      else
        LogMain "\$SyncOnStart not set; skipping repo sync"
      fi


# 5.  DeviceLoop
#     "It's just like replaying the worst day of your life over and over"
#     Begin the mega loop. To summarise, we'll iterate over the DeviceList, say some stuff, build and upload

      LogMain "Beginning main device loop at $(date +'%T')"
      for Device in "${DeviceList[@]}"; do

#       5a. LogHeaders
#       So we'll talk crap to the main log for a minute
        LogMain "Beginning loop as $Device"

#       5b. Lunch
#       This builds some makefiles and tells mka what device and variant we're building
        LogMain "Taking lunch for $Device"
        LogCommandMake "SupperLunch $Device"

#       5c. Make
#       This kicks off ninja amongst other things that makes the final files for our device
        LogMain "Making for $Device. Get the kettle on!"
        LogCommandMake "SupperMake"
        LogMain "Make finished"
        LogCommandMain "tail -n 2 $MakeLogFile | head -n 1"

#       5d. Find and rename zip
#       This finds the most recently modified zip file in the device out directory, and renames it to something sensible
        GetOutputZip $Device
        LogMain "Found zip at $OutputZip"
        GetNewName $Device
        LogMain "Renaming it to $NewName"
        $NewOutputZip=$SourceTreeLoc/out/target/product/$Device/$NewName

#       5e. MD5SUM
#       Output md5sum of zip to log and file
        GetLocalMD5SUM $NewOutputZip
        LogMain "Creating $NewOutputZip.md5sum"
        echo $MD5SUM > $NewOutputZip.md5sum
        LogMain "MD5sum of zip: $MD5SUM"

#       5f. Upload zip, then rename
#       We first upload the zip. The zip is named weird, as we don't want people downloading it while it's uploading
#       After both have been uploaded, we can rename the zip
        if [[ SSHUpload = true ]]; then
          LogMain "Uploading zip to $SSHHost"
          LogCommandMainErrors "UploadZipAndRename $NewOutputZip $NewName"
          LogMain "Uploading MD5"
          LogCommandMainErrors "UploadMD5 $NewOutputZip $NewName"
        else
          "Skipping SSH Upload as \$SSHUpload not set"
        fi
# End it all; I want to die
# Go back to 5a. and start again
"Finished main device loop for $Device"
done


# 6.  TarGZ Logs
      LogMain "Archiving Logs"
      LogMain "So we're done!"
      pushd $LogFileLoc
        LogCommandMainErrors "tar --remove-files -czvf $RomVariant-$RomVersion-$BuildDate-$Officiality.tar.gz $RomVariant-$RomVersion-$BuildDate-*"
      popd


# 7.  Drop email with successes and fails with attached logs
#     WIP
