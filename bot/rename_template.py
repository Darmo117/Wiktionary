import pywikibot as pwb

template_name = 'Modèle:voir autre alphabet'

site = pwb.Site()
# with open('pages.txt', encoding='UTF-8') as f:
#     for title in f.readlines():
#         page = pwb.Page(site, title='Modèle:' + title.strip())
#         if not page.isRedirectPage():
#             page.move('Modèle:voir autres scripts/' + title.strip().split('/')[1], reason='Renommage du modèle de base')
for page in pwb.Page(site, title=template_name).embeddedin():
    if page.namespace() in [0]:
        prev = page.text
        page.text = page.text.replace('{{voir autre alphabet', '{{voir autres scripts')
        if page.text != prev:
            page.save(summary="Renommage de ''voir autre alphabet'' en ''voir autres scripts''.")
