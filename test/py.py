import pywikibot as pwb

site = pwb.Site()

affixes = [
    'bo', 'dis', 'ek', 'eks', 'fi', 'ge', 'mal', 'mis', 'pra', 're', 'aĉ',
    'ad', 'aĵ', 'an', 'ar', 'ĉj', 'ebl', 'ec', 'eg', 'ej', 'em', 'end',
    'er', 'estr', 'et', 'id', 'ig', 'iĝ', 'il', 'ind', 'ing', 'in', 'ism',
    'ist', 'nj', 'obl', 'on', 'op', 'uj', 'ul', 'um',
]
for affix in affixes:
    page = pwb.Page(site, f'Utilisateur:Darmo117/Étymologies manquantes/{affix}')
    page.text = '{{colonnes|\n'

    ctg = pwb.Category(site, title='espéranto')
    articles = ctg.articles()
    i = 1
    for article in articles:
        if affix in article.title():
            tps = article.raw_extracted_templates
            if 'ébauche-étym' in [t[0] for t in tps]:
                title = article.title()
                print(title)
                page.text += f'* [[{title}]]\n'
                i += 1
        if i == 25:
            page.text = page.text.replace('}}', '')
            page.text += '}}'
            page.save()
            i = 1
    page.text = page.text.replace('}}', '')
    page.text += '}}'
    page.save()
