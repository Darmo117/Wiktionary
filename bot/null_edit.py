import pywikibot as pwb

pwb.config.put_throttle = 0
is_category = True
page_name = 'Modèle:Arab'

site = pwb.Site()
if page_name.startswith('Catégorie:'):
    iterator = pwb.Category(site, title=page_name).articles()
else:
    iterator = pwb.Page(site, title=page_name).embeddedin()

for page in iterator:
    print(page.title())
    try:
        page.save()
    except (pwb.exceptions.LockedPage, pwb.exceptions.OtherPageSaveError) as e:
        print(e)
        print('Page protégée, ignorée.')
