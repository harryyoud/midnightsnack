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
      trap "TrapCtrlC" 2
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

      if [[ -z $WithSU ]]; then
        WithSU=false
      fi

      if [[ $WithSU = true ]]; then
        export WITH_SU=true
      else
#       override eventually existing environment variable
        export WITH_SU=false
      fi

      SkipOTA=false
      if [[ -z $IncrementalOTA ]]; then
        IncrementalOTA=false
      else
        if [[ $MakeClean = "AtStart" ]] || [[ $MakeClean = "BetweenDevices" ]]; then
#         make clean will clean the out/target/product/... directory
#         that means we cant build an incremental OTA update 
          IncrementalOTA=false
        fi
      fi

      if [[ -z $LineageUpdater ]]; then
        LineageUpdater=false
      else
        if [[ $LineageUpdater = true ]]; then
          if [[ -z $LineageUpdaterApikey ]]; then
            LineageUpdater=false
          elif [[ -z $LineageUpdaterURL ]]; then
            LineageUpdater=false
          elif [[ -z $DownloadBaseURL ]]; then
            LineageUpdater=false
          fi
        fi
      fi

      if [[ -z $SignBuilds ]]; then
        SignBuilds=false
      else
        if [[ $SignBuilds = true ]]; then
          if [[ -z $SigningKeysPath ]]; then
            SignBuilds=false
          else
#           check if keys directory exists
            if ! [[ -d $SigningKeysPath ]]; then
              SignBuilds=false
            else
#             check if releasekey.pk8 exists in keys directory
              if ! [[ -f $SigningKeysPath/releasekey.pk8 ]]; then
                SignBuilds=false
              fi
            fi
          fi
#         check for key passwords file
          if ! [[ -z $SigningKeyPasswordsFile ]]; then
            if [[ -f $SigningKeyPasswordsFile ]]; then
              export ANDROID_PW_FILE=$SigningKeyPasswordsFile
            fi
          fi
        fi
      fi

# 3.  LogHeaders
#     We'll output all the admin information at the top of the log file, so it can be seen
#     We'll set the builddate here too, so it's early and can be outputted

      LogMain ""
      LogMain "########################"
      LogMain "Beginning midnightsnack v$Version on $(hostname) for $USER"
      LogMain "The time is $(date +'%T') on $(date +%Y/%m/%d)"
      LogMain "Devices to build for: ${DeviceList[*]}"
      LogMain "Build date is going to be set to $BuildDate"
      LogMain "Here we go..."
      LogMain "########################"

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
        LogCommandMainErrors "/home/$USER/bin/repo sync -q"
      else
        LogMain "\$SyncOnStart not set; skipping repo sync"
      fi
      if ! [[ -z $RepoPicks ]]; then
        LogMain "Applying repopicks from Gerrit (by changeID):"
          for RepoChangeID in "${RepoPicks[@]}"; do
            LogCommandMainErrors "repopick -q $RepoChangeID"
          done
        LogMain "Repopicks (by changeID) complete"
      else
        LogMain "No repopick changeIDs defined; skipping"
      fi
      if ! [[ -z $RepoTopics ]]; then
        LogMain "Applying repopicks from Gerrit (by topic):"
          for RepoTopic in "${RepoTopics[@]}"; do
            LogCommandMainErrors "repopick -q -t $RepoTopic"
          done
        LogMain "Repopicks (by topic) complete"
      else
        LogMain "No repopick topics defined; skipping"
      fi
      if ! [[ -z $AdditionalScriptsAfterRepoSync ]]; then
        LogMain "Running Additional Scripts:"
          for AdditionalScript in "${AdditionalScriptsAfterRepoSync[@]}"; do
            LogCommandMainErrors "$AdditionalScript"
          done
        LogMain "Done"
      else
        LogMain "No Additional Scripts defined; skipping"
      fi
      if [[ $MakeClean = "AtStart" ]] || [[ $MakeClean = "BetweenDevices" ]]; then
        LogMain "Removing build directory, as \$MakeClean set to $MakeClean"
        LogCommandMainErrors "make clean"
      else
        LogMain "Skipping make clean as MakeClean set to no"
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

        if [[ $SignBuilds = true ]]; then
          LogMain "\tSign Build"
          SignBuild $Device
        fi

#       5d. Find and rename zip
#       This finds the most recently modified zip file in the device out directory, and renames it to something sensible
        GetOutputZip $Device
        LogMain "\tFound zip at $OutputZip"
        GetNewName $Device
        LogMain "\tRenaming it to $NewName"
        NewOutputZip=$SourceTreeLoc/out/target/product/$Device/$NewName
        LogCommandMainErrors "mv $OutputZip $NewOutputZip"

        if [[ $IncrementalOTA = true ]]; then
          LogMain "\tBuilding Incremental OTA"
          GetCurrentOTAHash
          if ! [[ -z $OTAHash ]]; then
            GetPreviousOTAHash
            if ! [[ -z $PreviousOTAHash ]]; then
              GetNewOTAName $Device
              if [[ $SignBuilds = true ]]; then
                OldOTAZip="$SourceTreeLoc/out/target/product/$Device/obj/PACKAGING/target_files_intermediates/lineage_$Device-target_files-$PreviousOTAHash-signed.zip"
                NewOTAZip="$SourceTreeLoc/out/target/product/$Device/obj/PACKAGING/target_files_intermediates/lineage_$Device-target_files-$OTAHash-signed.zip"
              else
                OldOTAZip="$SourceTreeLoc/out/target/product/$Device/obj/PACKAGING/target_files_intermediates/lineage_$Device-target_files-$PreviousOTAHash.zip"
                NewOTAZip="$SourceTreeLoc/out/target/product/$Device/obj/PACKAGING/target_files_intermediates/lineage_$Device-target_files-$OTAHash.zip"
              fi

              OTAOutputZip="$SourceTreeLoc/out/target/product/$Device/$NewOTAName"

              if [[ -f $SourceTreeLoc/out/target/product/$1/ota_script_path ]]; then
                  OtaScriptPath=$(cat $SourceTreeLoc/out/target/product/$1/ota_script_path)
              else
                  OtaScriptPath="build/tools/releasetools/ota_from_target_files"
              fi

              if [[ $SignBuilds = true ]]; then
                LogCommandMake "$OtaScriptPath -k $SigningKeysPath/releasekey --block -i $OldOTAZip $NewOTAZip $OTAOutputZip"
              else
                LogCommandMake "$OtaScriptPath --block -i $OldOTAZip $NewOTAZip $OTAOutputZip"
              fi

              if ! [[ -f $OTAOutputZip ]]; then
                LogMain "\tError: Building Incremental OTA failed!"
				SkipOTA=true
              fi
            else
              LogMain "\tNo Previous OTA found, Skipping"
			  SkipOTA=true
            fi
          else
            LogMain "\tNo OTA found, Skipping"
			SkipOTA=true
          fi
        fi

#       5e. MD5SUM
#       Output md5sum of zip to log and file
        if [[ $IncrementalOTA = true ]] && [[ $SkipOTA = false ]]; then
          GetLocalMD5SUM $OTAOutputZip
          LogMain "\tCreating $NewOTAName.md5sum"
          echo $MD5SUM > $OTAOutputZip.md5sum
          LogMain "\tMD5sum of $NewOTAName: ${MD5SUM:0:32}"
        fi

        GetLocalMD5SUM $NewOutputZip
        LogMain "\tCreating $NewName.md5sum"
        echo $MD5SUM > $NewOutputZip.md5sum
        LogMain "\tMD5sum of $NewName: ${MD5SUM:0:32}"

#       5f. Upload zip, then rename
#       We first upload the zip. The zip is named weird, as we don't want people downloading it while it's uploading
#       After both have been uploaded, we can rename the zip
        if [[ $SSHUpload = true ]]; then
          LogMain "\tUploading zip to $SSHHost"
          LogCommandMainErrors "UploadZipAndRename $NewOutputZip $NewName"
          LogMain "\tUploading MD5"
          LogCommandMainErrors "UploadMD5 $NewOutputZip $NewName"

          if [[ $IncrementalOTA = true ]] && [[ $SkipOTA = false ]]; then
            if [[ -a $OTAOutputZip ]]; then
              LogMain "\tUploading OTA zip to $SSHHost"
              LogCommandMainErrors "UploadZipAndRename $OTAOutputZip $NewOTAName"
              LogMain "\tUploading OTA MD5"
              LogCommandMainErrors "UploadMD5 $OTAOutputZip $NewOTAName"
            fi
          fi

        else
          LogMain "\tSkipping SSH Upload as \$SSHUpload not set"
        fi

        if [[ $LineageUpdater = true ]]; then
          FlaskAddRomRemote
        fi

        if ! [[ -z $DeleteBuildAfterUpload ]]; then
          if [[ $DeleteBuildAfterUpload = true ]]; then
            CleanupAfterBuild
          fi
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
