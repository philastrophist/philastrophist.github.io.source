import ads
import requests
from string import ascii_letters
import re
import os
from collections import namedtuple


class Paper:
    def __init__(self, title, year, authors, pub='in prep', abstract=''):
        self.title = [title]
        self.year = year
        self.pub = pub
        self.abstract = abstract
        self.author = authors
        self.bibcode = ''


markdown_template = \
u"""---
title: "{p.title[0]}"
collection: publications
permalink: /publication/{title}
date: {date}
venue: '{p.pub}'
arxiv: {arxiv}
doi: {p.doi[0]}
---
{authors}

{p.abstract}

[{p.pub}](https://dx.doi.org/{p.doi[0]})

[arXiv](https://arxiv.org/abs/{arxiv})
"""

latex_template = \
r"""
\item \textit{{{p.title[0]}}}, {authors}, {p.bibcode}
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

def clean_authors(paper, start='**', end='**'):
    return '; '.join(['{}{}{}'.format(start, i, end) if 'Read, S' in i else i for i in paper.author])

def write_to_markdown(paper, overwrite=False):
        title = clean_title(paper)
        arxiv = arxiv_id(paper)
        date = clean_date(paper)
        authors = clean_authors(paper)

        page = markdown_template.format(p=paper, arxiv=arxiv, title=title, date=date, authors=authors)
        fname = '_publications/{}.md'.format(title)
        if (overwrite) or (not os.path.exists(fname)):
            with open(fname, 'w') as f:
                f.write(page)

def write_to_latex(papers, text, substitute, overwrite=False):
    items = []
    for paper in papers:
        authors = clean_authors(paper, r'\textbf{', '}')
        items.append(latex_template.format(p=paper, authors=authors))

    return text.replace('% {{{}}} %'.format(substitute), '\n'.join(items))


if __name__ == '__main__':
    import argparse
    import yaml

    parser = argparse.ArgumentParser()
    parser.add_argument('--overwrite', action='store_true')
    parser.add_argument('--cvin', default='latex/template.tex')
    parser.add_argument('--cvout', default='latex/cv-shauncread.tex')
    parser.add_argument('--config', default='data.yml')
    args = parser.parse_args()

    with open('data.yml', 'r') as f:
        data = yaml.load(f)
    unpublished = [Paper(**p) for p in data['unpublished']]


    published = list(ads.SearchQuery(author='Read, S.C.', sort="year", aff="*Hertfordshire*", database='astronomy', 
                             fl=['title', 'pubdate', 'pub', 'abstract', 'bibtex', 'identifier', 'bibcode', 'doi',
                             'author', 'year']))

    with open(args.cvin, 'r') as f:
        text = f.read()
    with open(args.cvout, 'w') as f:
        text = write_to_latex(published, text, 'published', overwrite=args.overwrite)
        text = write_to_latex(unpublished, text, 'unpublished', overwrite=args.overwrite)
        f.write(text)

    for paper in published:
        write_to_markdown(paper, args.overwrite)