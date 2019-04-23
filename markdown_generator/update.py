import pypandoc

EDUCATION = r"""**{qualification}**
{location}
{start} - {end}
{notes}"""

EXPERIENCE = r""""""

def education(config):
	for edu in config['education']:
		