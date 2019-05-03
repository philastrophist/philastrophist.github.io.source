#!/bin/bash -x
# update the site from UPDATE_BRANCH. Adds a new commit to LIVE_BRANCH after every new commit on UPDATE_BRANCH.
# set a cron job to run on LIVE_BRANCH
set -e

UPDATE_BRANCH="test-develop"
LIVE_BRANCH="test-master"

git flow init -d
git config gitflow.branch.develop $UPDATE_BRANCH
git config gitflow.branch.master $LIVE_BRANCH
git config gitflow.prefix.hotfix cron

TYPE='INVALID'
if [[ $TRAVIS_EVENT_TYPE == 'cron' && $TRAVIS_BRANCH == "$LIVE_BRANCH" ]]; then
  TYPE='CRON'
elif [[ $TRAVIS_BRANCH == "$UPDATE_BRANCH" ]]; then
  TYPE='USER'
fi

if [[ ($TYPE == 'CRON') || ( $TYPE == 'USER' ) ]]; then
  wget https://github.com/jgm/pandoc/releases/download/2.7.2/pandoc-2.7.2-1-amd64.deb
  sudo dpkg -i pandoc-2.7.2-1-amd64.deb
  pip3 install pypandoc pyyaml requests ads
  python3 generator/update.py

  cd latex
  ../latexdockercmd.sh xelatex -interaction nonstopmode cv-shauncread.tex

  # Push to GitHub
  cd ..

  if [[ $TYPE == 'CRON' ]]; then
    git flow hotfix start travis
  elif [[ $TYPE == 'USER' ]]; then
    git flow release start travis
  fi

  git add _publications/ latex/ files/
  git -c user.name='travis' -c user.email='travis' commit -m "updating live version"


  if [[ $TYPE == 'CRON' ]]; then
    git flow hotfix finish travis
  elif [[ $TYPE == 'USER' ]]; then
    git flow release finish travis
  fi


  git push https://"$GITHUB_USER":"$GITHUB_API_KEY"@github.com/"$TRAVIS_REPO_SLUG" $UPDATE_BRANCH
  git push https://"$GITHUB_USER":"$GITHUB_API_KEY"@github.com/"$TRAVIS_REPO_SLUG" $LIVE_BRANCH
fi
  