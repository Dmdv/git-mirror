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
TASG=false

while (( "$#" )); do
  case "$1" in
    -a|--option-a)
      echo "Tags cloning enabled"
      TAGS=true
      shift
      ;;
    --)
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      shift
      ;;
  esac
done


GIT_SOURCE_REPO=$1
GIT_TARGET_REPO=$2

echo "Cloning $GIT_SOURCE_REPO"
git clone $GIT_SOURCE_REPO

folder=${GIT_SOURCE_REPO##*/}
foldername=${folder%.git}

echo "Cloned to $foldername"
cd $foldername

echo "Adding remote $GIT_TARGET_REPO as push origin"
git remote add destination $GIT_TARGET_REPO

for branch in $(git branch -r | grep origin | grep -v "HEAD" | sed 's/origin\///'); do
    echo "Processing branch: $branch"
    git checkout $branch
    # Create a new commit that adds all files as they are on this branch
    git checkout --orphan temp_branch
    git add -A
    git commit -m "Create $branch"
    git branch -M temp_branch $branch
    git push destination $branch
done


if [ "$TAGS" = false ] ; then
    exit 0
fi

# Now push the tags
for tag in $(git tag); do
    echo "Processing tag: $tag"
    git checkout $tag
    # Create a new commit that adds all files as they are on this tag
    git checkout --orphan temp_tag
    git add -A
    git commit -m "Create tag $tag"
    git tag -d $tag  # delete the old tag
    git tag $tag  # recreate the tag on the new commit
    git push destination $tag
done
