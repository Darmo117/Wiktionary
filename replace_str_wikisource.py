import re

import pywikibot as pwb

pages_name = 'Parépou - Atipa, 1885'
substitions = [
    (re.compile(' ([:;?!»])'), r' \1'),
    (re.compile('« '), '« '),
]

site = pwb.Site(code='fr', fam='wikisource', user='Darmo117')

indices = range(1, 239)
for i, p in enumerate(indices):
    page = pwb.Page(site, title=f'Page:{pages_name}.djvu/{p}')
    if page.exists():
        print(f'Page {p} ({i + 1}/{len(indices)})…')
        text = page.text
        for pattern, repl in substitions:
            page.text = re.sub(pattern, repl, page.text)
        if text != page.text:
            page.save(summary='(Automatique) Ajout d’espaces insécables')
        else:
            print('Nothing changed, skipped.')
