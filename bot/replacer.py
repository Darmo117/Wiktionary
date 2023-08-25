import re

import pywikibot as pwb
from pywikibot import config as pwb_config


def replacer(match: re.Match) -> str:
    return match[0] \
        .replace("'", 'ˈ') \
        .replace('g', 'ɡ') \
        .replace('ʤ', 'd͡ʒ') \
        .replace('ʦ', 't͡s') \
        .replace('ʧ', 't͡ʃ')


pwb_config.put_throttle = 0
is_category = True
page_name = 'Modèle:trad--'
summary = 'Remplacement du modèle trad-- par trad ' \
          '(cf. [[Wiktionnaire:Gestion des modèles/2022#Suppression de Modèle:trad--]])'

site = pwb.Site()
if page_name.startswith('Catégorie:'):
    iterator = pwb.Category(site, title=page_name).articles()
else:
    iterator = pwb.Page(site, title=page_name).embeddedin()

for page in iterator:
    print(f'Editing page "{page.title()}"…')

    old_text = page.text
    page.text = re.sub(r'{{trad--\|', '{{trad|', page.text)
    # page.text = page.text.replace('.pron|', '.pron=')
    # page.text = re.sub(r'\.pron=([^|{}]+)(?:\n|\||}})', replacer, page.text)
    # page.text = re.sub(r'{{it-inv\|([^{}|]+?)(?:\|inv=.+?|\|mf=oui)?}}', replacer, page.text)
    # page.text = re.sub(r'{{pron\|([^{}|]+?)\|it}}', replacer, page.text)
    if old_text != page.text:
        try:
            page.save(summary=summary)
            print('Done.')
        except pwb.exceptions.PageSaveRelatedError as e:
            print('Protected page, skipped:', e)
    else:
        print('No changes, skipped.')
