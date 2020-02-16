import re

import pywikibot as pwb

site = pwb.Site()
category = pwb.Category(site, 'Alphabet gotique')
for page in category.articles():
    if len(page.title()) == 1:
        page.text = re.sub(r"\n'''(.)''' ''(.+)''", '\n' + r"'''\1''' {{romanisation|\2|got}}", page.text)
        page.save(summary='Déploiment modèle {{romanisation}}', watch='nochange', botflag=True)
