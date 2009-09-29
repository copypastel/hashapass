#!/bin/bash
# Author: copypastel.com
# Copyright 2009
# Contact: 
#    - daicoden@copypastel.com
#    - ecin@copypastel.com
VERSION="0.2.1"

function output_version {
   printf "hashapass %s \n" $VERSION
}

function output_help {
  echo "Tired of remembering passwords? Hash them! This is a terminal app to"
  echo "simplify generation and copying to clipboard. Passwords are compatible"
  echo "with http://www.hashapass.com"
  echo ""
  echo "Example:"
  echo "If you wish to create a password for your gmail account..."
  echo ""
  echo "hashapass gmail"
  echo
  echo "... and you'll be asked for your master password."
  echo
  echo "Usage:"
  echo "hashapass [-nphv] something_simple"
  echo
  echo "Options:"
  echo "-n    Confirm password."
  echo "-p    Print generated password."
  echo "-h    Displays help message."
  echo "-v    Display version."
  echo ""
  echo "Licensed under the MIT license:"
  echo "http://www.opensource.org/licenses/mit-license.php"
}

function echo_off {
    stty -echo
}

function echo_on {
    stty echo
}

function assert_matching {
    if [ $1 != $2 ]
    then
        printf "Passwords do not match.  Exiting...\n"
        exit
    fi
}

function hidden_read {
    printf $2
    echo_off
    read tmp
    echo_on
    printf "\n"
    eval "$1=$tmp"
}

function hash_password() {
    # $1 is the return result
    # $2 is the paramater
    # $3 is the password
    eval "$1=`printf $2 | openssl dgst -sha1 -hmac $3 -binary | openssl enc -base64 | head -c 8`"
}

nFlag= # New Flag
pFlag= # Print Flag
while getopts 'vhnp' OPTION
do
    case $OPTION in
    v) # Version
            output_version
            exit
            ;;
    h) # Help
            output_help
            exit
            ;;
    n) # New Password
            nFlag=1
            ;;
    p) # Print Password
            pFlag=1
            ;;
    esac
done
# Now all options are removed
shift $(($OPTIND - 1))


paramater=$1
hidden_read password "Password:"

if [ "$nFlag" ]
then
    hidden_read password_conf "Confirmation:"
    assert_matching $password $password_conf
fi

hash_password result $paramater $password

if [ "$pFlag" ]
then
    printf "%s\n" $result
else
    echo_off
    if [ `which pbcopy` ]
    then
      printf $result | pbcopy
    elif [ `which xsel` ]
    then
      printf $result | xsel
    else
      echo_on
      echo "xsel or pbcopy not found, can not copy to clipboard."
      echo "Use -p to print out the password, or modify the script"
      exit
    fi
    echo_on
    printf "Result copied to clipboard.\n"
fi