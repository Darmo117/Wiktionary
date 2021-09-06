import re

import pywikibot as pwb

pwb.config.put_throttle = 0
page_name = 'Modèle:recons'

site = pwb.Site()
namespaces = [0, 1, 4, 5, 10, 11, 12, 13, 14, 15, 100, 101, 104, 105, 106, 107,
              108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119]
if page_name.startswith('Catégorie:'):
    iterator = pwb.Category(site, title=page_name).articles()
else:
    iterator = pwb.Page(site, title=page_name).embeddedin()

with open('sc.txt', mode='w', encoding='UTF-8') as f:
    for page in iterator:
        print(page.title())
        try:
            if '{{recons' in page.text and re.search(r'\bsc\s*=', page.text):
                print('sc param detected')
                f.write(page.title() + '\n')
                f.flush()
        except pwb.exceptions.LockedPage:
            print('Page protégée, ignorée.')
