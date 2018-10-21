#!/bin/bash
exec 1>&2


### Check if tests are failing ###

STASH_NAME="pre-commit-$(date +%s)"
git stash save -q --keep-index $STASH_NAME

./scripts/run-tests.sh
RESULT=$?

STASHES=$(git stash list)
echo $STASHES
if [[ "${STASHES#*$STASH_NAME}" != "$STASHES" ]]; then
  git stash pop -q
fi

if [ $RESULT != 0 ]
then
	echo -e "\033[0;31mGit commit aborted due to failing tests\033[0m"
	exit 1
fi


### Check if linter is concerned ###

STASH_NAME="pre-commit-$(date +%s)"
git stash save -q --keep-index $STASH_NAME

./scripts/run-linter.sh
RESULT=$?

STASHES=$(git stash list)
echo $STASHES
if [[ "${STASHES#*$STASH_NAME}" != "$STASHES" ]]; then
  git stash pop -q
fi

if [ $RESULT != 0 ]
then
	echo -e "\033[1;33mGit commit aborted due to unhappy linter\033[0m"
	exit 1
fi
