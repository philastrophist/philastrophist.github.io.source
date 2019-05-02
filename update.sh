#!/bin/bash -x
set -e

UPDATE_BRANCH="autocompile"
LIVE_BRANCH="test"


if [[ $TRAVIS_BRANCH  == $UPDATE_BRANCH ]]; then

	wget https://github.com/jgm/pandoc/releases/download/2.7.2/pandoc-2.7.2-1-amd64.deb
	sudo dpkg -i pandoc-2.7.2-1-amd64.deb
	pip3 install pypandoc pyyaml requests ads
	python3 generator/update.py

	if git diff --name-only $TRAVIS_COMMIT_RANGE | grep 'latex/' | grep -v "*.pdf"; then  # if pdf needs generating
		sudo tlmgr init-usertree
		sudo tlmgr update --all
		sudo tlmgr install fontawesome
		cd latex
		cp cv-shauncread.pdf cv-shauncread.pdf.bkp
		./latexdockercmd.sh xelatex -interaction nonstopmode cv-shauncread.tex

	fi

	# Force push to GitHub
	cd $TRAVIS_BUILD_DIR
	git checkout $LIVE_BRANCH
  git add --all
	git -c user.name='travis' -c user.email='travis' commit -m "updating live version"
	git push -q -f https://$GITHUB_USER:$GITHUB_API_KEY@github.com/$TRAVIS_REPO_SLUG $LIVE_BRANCH

fi
