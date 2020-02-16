import pywikibot as pwb

site = pwb.Site()
c = pwb.Category(site, 'Catégorie:syllabaires autochtones canadiens')

for p in c.articles():
    print(p.text)
    print()
