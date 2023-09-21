#!/bin/bash

# Check if argument is given
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path> --tags"
    exit 1
fi

# check if 1st argument is given
if [ -z "$1" ]; then
    echo "Error: No source url supplied"
    exit 1
fi

# check if 2nd argument is given
if [ -z "$2" ]; then
    echo "Error: No target url supplied"
    exit 1
fi

# check if git is installed
if ! [ -x "$(command -v git)" ]; then
    echo "Error: git is not installed." >&2
    exit 1
fi

# check if 1st argument is a valid git repo
if ! git ls-remote $1 &> /dev/null; then
    echo "Error: $1 is not a valid git repo." >&2
    exit 1
fi

# check if 2st argument is a valid git repo
if ! git ls-remote $2 &> /dev/null; then
    echo "Error: $2 is not a valid git repo." >&2
    exit 1
fi

# Checking options
TAGS=false

# while (( "$#" )); do
#   case "$3" in
#     -t|--tags)
#       echo "Tags cloning enabled"
#       TAGS=true
#       shift
#       ;;
#     --)
#       shift
#       break
#       ;;
#     -*|--*=) # unsupported flags
#       echo "Error: Unsupported flag $1" >&2
#       exit 1
#       ;;
#     *)
#       shift
#       ;;
#   esac
# done

while getopts ":t" option; do
  case "$option" in
    t) 
        echo "Option -t provided"
        TAGS=true
        ;;
    \?) 
        echo "Invalid option: -$OPTARG" >&2; 
        exit 1
        ;;
  esac
done

if [ "$TAGS" = false ] ; then
    echo "Tags cloning disabled. Exiting..."
    exit 0
fi
