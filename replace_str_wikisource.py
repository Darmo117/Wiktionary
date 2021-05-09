import re

import pywikibot as pwb

pages_name = 'Peletier - Dialogue de l\'ortografe e prononciation françoese'
pattern = re.compile(r'\s?([:;?!])(?!\w)')
repl = r'&nbsp;\1'

site = pwb.Site(code='fr', fam='wikisource', user='Darmo117')

indices = [*range(2, 177), *range(179, 236)]
for i, p in enumerate(indices):
    page = pwb.Page(site, title=f'Page:{pages_name}.djvu/{p}')
    if page.exists():
        print(f'Page {p} ({i}/{len(indices)})…')
        text = page.text
        page.text = re.sub(pattern, repl, page.text)
        if text != page.text:
            page.save(summary=f'(Automatique) Insertion d’une espace insécable devant [:;?!].')
