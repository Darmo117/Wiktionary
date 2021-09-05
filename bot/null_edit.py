import pywikibot as pwb

pwb.config.put_throttle = 0
is_category = True
page_name = 'Modèle:Thaa'

site = pwb.Site()
namespaces = [0, 1, 4, 5, 10, 11, 12, 13, 14, 15, 100, 101, 104, 105, 106, 107,
              108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119]
if page_name.startswith('Catégorie:'):
    iterator = pwb.Category(site, title=page_name).articles()
else:
    iterator = pwb.Page(site, title=page_name).embeddedin()

for page in iterator:
    print(page.title())
    try:
        page.save()
    except pwb.exceptions.LockedPage:
        print('Page protégée, ignorée.')
