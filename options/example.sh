#!/bin/bash

if ! [[ -z "$1" ]]; then
  if [[ $1 = "set" ]]; then

    export WITH_SU=true
    export WITH_DEXPREOPT=true

  elif [[ $1 = "unset" ]]; then

    unset WITH_SU
    unset WITH_DEXPREOPT

  fi
fi
