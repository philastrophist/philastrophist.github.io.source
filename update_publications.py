import ads
import requests
from string import ascii_letters
import re
import os

template = \
u"""---
title: "{p.title[0]}"
collection: publications
permalink: /publication/{title}
date: {date}
venue: '{p.pub}'
arxiv: {arxiv}
doi: {p.doi[0]}
---
{p.abstract}

[{p.pub}](https://dx.doi.org/{p.doi[0]})

[arXiv](https://arxiv.org/abs/{arxiv})
"""

ARXIV = r'arXiv:(\d{4}\.\d{5})'
DOI = r'(.*/.*/.*)'


def arxiv_id(paper):
    for id in paper.identifier:
        if 'arxiv:' in id.lower():
            return '{}'.format(re.search(ARXIV, id).groups()[0])
    else:
        return ''


def clean_title(paper):
    title = paper.title[0]
    return paper.pubdate + '-' + ''.join([i if i in ascii_letters else '-' for i in title.split(':')[0]])

def clean_date(paper):
    return paper.pubdate.replace('00', '01')

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--overwrite', action='store_true')
    args = parser.parse_args()

    papers = ads.SearchQuery(author='Read, S.C.', sort="year", aff="*Hertfordshire*", database='astronomy', 
                             fl=['title', 'pubdate', 'pub', 'abstract', 'bibtex', 'identifier', 'bibcode', 'doi'])

    for paper in papers:
        title = clean_title(paper)
        arxiv = arxiv_id(paper)
        date = clean_date(paper)
        page = template.format(p=paper, arxiv=arxiv, title=title, date=date)
        fname = '_publications/{}.md'.format(title)
        if (args.overwrite) or (not os.path.exists(fname)):
            with open(fname, 'w') as f:
                f.write(page)