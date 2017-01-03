#       Midnight Snack Build Script

##      What does this do?
                This basically automates the process of building Android and its derivatives, as well as uploading the builds to a remote SSH server and sending emails notifying the status of the builds.

                1.  Import includes (functions, settings, error descs) and set vars
                2.  CheckVariablesExist
                3.  LogHeaders
                4.  Repo Sync
                5.  DeviceLoop
                     a. LogHeaders
                     b. Lunch
                     c. Make
                     d. Find and rename zip
                     e. MD5sum
                     f. Upload zip, then rename
                     g. Delete Build zip
                6.  TarGZ logs
                7.  Drop email with successes and fails with attached logs

##      Why do I want this?
                Because:
                  - You're too lazy to do it manually
                  - You're too lazy to set up Jenkins

##      How do I use it?
                Clone the repo:
                  git clone git@github.com:harryyoud/midnightsnack

##      Configuration
                All configuration happens in the settings.sh file. They variables in there are either self-explanatory or have a comment attached

##      Errors
                Being a long and complicated drawn out process, the script could fail at lots of points. The various errors you might encounter are explained quite well in errors.sh

##      Improving/Building on top of
                I tried to make this as easy as possible to build upon or change, because everybody's needs are different.
                Hopefully, the only changes you need to make are in main.sh, to add post-/pre-build hooks or change the order of some things
