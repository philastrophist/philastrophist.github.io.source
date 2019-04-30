#!/bin/bash -x
set -e

wget https://github.com/jgm/pandoc/releases/download/2.7.2/pandoc-2.7.2-1-amd64.deb
sudo dpkg -i pandoc-2.7.2-1-amd64.deb
pip3 install pypandoc pyyaml requests ads
python3 generator/update.py

# if git diff --name-only $TRAVIS_COMMIT_RANGE | grep 'latex/' | grep -v "*.pdf
curl -sL http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar zxf - && mv install-tl-20* install-tl
cd install-tl
echo "selected_scheme scheme-full" > profile \
  && sudo ./install-tl -repository http://mirror.ctan.org/systems/texlive/tlnet -profile profile
export PATH=/usr/local/texlive/2017/bin/x86_64-linux:$PATH
sudo tlmgr init-usertree
sudo tlmgr update --all
sudo tlmgr install fontawesome

# Install tectonic using conda
# wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
# bash miniconda.sh -b -p $HOME/miniconda
# export PATH="$HOME/miniconda/bin:$PATH"
# hash -r
# conda config --set always_yes yes --set changeps1 no
# conda update -q conda
# conda info -a
# conda create --yes -n latex
# source activate latex
# conda install -c conda-forge -c pkgw-forge tectonic

# Build the paper using tectonic
cd latex
# tectonic cv-shauncread.tex --print
cp cv-shauncread.pdf cv-shauncread.pdf.bkp
xelatex -interaction nonstopmode cv-shauncread.tex

# Force push the paper to GitHub
cd $TRAVIS_BUILD_DIR
git checkout --orphan $TRAVIS_BRANCH-pdf
git rm -rf .
git add -f latex/cv-shauncread.pdf
git -c user.name='travis' -c user.email='travis' commit -m "building latex"
git push -q -f https://$GITHUB_USER:$GITHUB_API_KEY@github.com/$TRAVIS_REPO_SLUG $TRAVIS_BRANCH-pdf
# fi
