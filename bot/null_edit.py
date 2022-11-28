import pywikibot as pwb
from pywikibot import config as pwb_config

pwb_config.put_throttle = 0
is_category = True
page_name = 'Catégorie:Wiktionnaire:Prononciations employant des caractères inconnus en italien'

site = pwb.Site()
if page_name.startswith('Catégorie:'):
    iterator = pwb.Category(site, title=page_name).articles()
else:
    iterator = pwb.Page(site, title=page_name).embeddedin()

for page in iterator:
    print(page.title())
    try:
        page.save()
    except (pwb.exceptions.LockedPageError, pwb.exceptions.OtherPageSaveError) as e:
        print(e)
        print('Page protégée, ignorée.')
