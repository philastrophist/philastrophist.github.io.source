#!/bin/bash -x
# update the site from UPDATE_BRANCH. Adds a new commit to LIVE_BRANCH after every new commit on UPDATE_BRANCH.
# set a cron job to run on LIVE_BRANCH
set -e

UPDATE_BRANCH="develop"
LIVE_BRANCH="master"

git checkout $TRAVIS_BRANCH
git pull

TYPE='INVALID'
if [[ $TRAVIS_EVENT_TYPE == 'cron' && $TRAVIS_BRANCH == "$LIVE_BRANCH" ]]; then
  TYPE='CRON'
elif [[ $TRAVIS_BRANCH == "$UPDATE_BRANCH" ]]; then
  TYPE='USER'
fi

if ! [[ "$(git rev-parse "$TRAVIS_COMMIT")" == "$(git rev-parse HEAD)" ]]; then
  echo this is not the most recent commit in the branch, no work necessary
  exit 0 
fi

if [[ ($TYPE == 'CRON') || ( $TYPE == 'USER' ) ]]; then
  # if on a tracked branch
  wget https://github.com/jgm/pandoc/releases/download/2.7.2/pandoc-2.7.2-1-amd64.deb
  sudo dpkg -i pandoc-2.7.2-1-amd64.deb
  rm pandoc-2.7.2-1-amd64.deb
  pip3 install pypandoc pyyaml requests ads
  python3 generator/update.py

  if git status --porcelain | grep latex/ | grep -v "*.pdf"; then 
    # do latex stuff
	  cd latex
	  ../latexdockercmd.sh xelatex -interaction nonstopmode cv-shauncread.tex
	  cd ..
  fi


  # Push to GitHub
  if [[ $TYPE == 'CRON' ]]; then
    git checkout -b update/cron
  elif [[ $TYPE == 'USER' ]]; then
    git checkout -b update/user
  fi

  git add _publications/ latex/ files/
  if ! git -c user.name='travis' -c user.email='travis' commit -m "updating live version"; then
    echo "no update necessary"
    exit 0
  fi


  if [[ $TYPE == 'CRON' ]]; then
    git checkout -t "origin/$UPDATE_BRANCH"
    git merge update/cron  # this script is activated again to push to $LIVE_BRANCH
  elif [[ $TYPE == 'USER' ]]; then
    git checkout -t "origin/$LIVE_BRANCH"
    git merge update/user
  fi

  if ! [[ "$(git rev-parse "$TRAVIS_COMMIT")" == "$(git rev-parse HEAD)" ]]; then
    echo this is now not the most recent commit in the branch, not pushing
    exit 0 
  fi
  git --dry-run push https://"$GITHUB_USER":"$GITHUB_API_KEY"@github.com/"$TRAVIS_REPO_SLUG" $UPDATE_BRANCH
  git --dry-run push https://"$GITHUB_USER":"$GITHUB_API_KEY"@github.com/"$TRAVIS_REPO_SLUG" $LIVE_BRANCH
fi
  
