import re

import pywikibot as pwb

site = pwb.Site()

i = 0
regex = '^[aeiou]?([^aeiou][aeiou])*?j?n?$'
cat = pwb.Category(site, 'Catégorie:Wiktionnaire:Prononciations manquantes en espéranto')
for article in cat.articles():
    title = article.title()
    if re.match(regex, title.lower()):
        i += 1
print(i)
