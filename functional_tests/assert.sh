#!/usr/bin/env bash
# assert.sh

# Pulled from the "Advanced Bash-Scripting Guide".
# http://tldp.org/LDP/abs/html/debugging.html#ASSERT

#######################################################################
assert ()                 #  If condition false,
{                         #+ exit from script
                          #+ with appropriate error message.
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  if [ -z "$2" ]          #  Not enough parameters passed
  then                    #+ to assert() function.
    return $E_PARAM_ERR   #  No damage done.
  fi

  lineno=$2

  if [ ! $1 ] 
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"    # Give name of file and line number.
    exit $E_ASSERT_FAILED
  # else
  #   return
  #   and continue executing the script.
  fi  
} # Insert a similar assert() function into a script you need to debug.    
#######################################################################
