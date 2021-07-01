import pywikibot as pwb

pwb.config.put_throttle = 0
category_name = 'Wiktionnaire:Liens avec code de langue inconnu'

site = pwb.Site()
for page in pwb.Category(site, 'Catégorie:' + category_name).articles(
        namespaces=[0, 1, 4, 5, 10, 11, 12, 13, 14, 15, 100, 101, 104, 105, 106, 107, 108, 109, 110, 111, 112,
                    113, 114, 115, 116, 117, 118, 119]):
    print(page.title())
    try:
        page.save()
    except pwb.exceptions.LockedPage:
        print('Page protégée, ignorée.')
