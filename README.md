#       Midnight Snack Build Script

##      What does this do?
This basically automates the process of building Android and its derivatives, as well as uploading the builds to a remote SSH server and sending emails notifying the status of the builds.

1.  Import includes (functions, settings, error descs) and set vars
2.  CheckVariablesExist
3.  LogHeaders
4.  Repo Sync
5.  DeviceLoop
     1. LogHeaders
     2. Lunch
     3. Make
     4. Find and rename zip
     5. MD5sum
     6. Upload zip, then rename
     7. Delete Build zip
6.  TarGZ logs and move to LogFileLoc/archives
7.  Drop email with successes and fails with attached logs (coming in Version 2)

##      Why do I want this?
Because:
  - You're too lazy to do it manually
  - You're too lazy to set up Jenkins

##      How do I use it?

1.  git clone git@github.com:harryyoud/midnightsnack
2.  configure settings in `settings.sh`
3.  ./main.sh
4.  Wait....
5.  Profit (or it failed - check the logs)

##      Configuration
All configuration happens in the settings.sh file. They variables in there are either self-explanatory or have a comment attached

##      Errors
Being a long and complicated drawn out process, the script could fail at lots of points. The various errors you might encounter are explained quite well in errors.sh

##      Improving/Building on top of
I tried to make this as easy as possible to build upon or change, because everybody's needs are different.
Hopefully, the only changes you need to make are in main.sh, to add post-/pre-build hooks or change the order of some things
