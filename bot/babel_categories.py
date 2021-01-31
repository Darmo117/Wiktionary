import re

import lupa
import pywikibot as pwb

with open('../models-modules/langues/data.lua', encoding='UTF-8') as f:
    languages = lupa.LuaRuntime().execute(''.join(f.readlines()))

level_categories_names = {
    '0': 'Personnes ne parlant pas {} mais s’y intéressant',
    '1': 'Personnes ayant un niveau débutant en {}',
    '2': 'Personnes ayant un niveau intermédiaire en {}',
    '3': 'Personnes ayant un niveau avancé en {}',
    '4': 'Personnes ayant un niveau très avancé en {}',
    'M': 'Personnes parlant nativement en {}',
}

top_category_name = ''  # TODO À définir

refreshed_users = set()

site = pwb.Site()

out = open('babel_categories_skipped.txt', mode='w', encoding='UTF-8')

for category in pwb.Category(site, title='Wiktionnaristes par langue').subcategories():
    title = category.title()
    if m := re.fullmatch(r'Catégorie:Utilisateurs ([a-z][\w-]+)', title):
        code = m.group(1)
        print(code)

        for subcategory in category.subcategories():
            sub_title = subcategory.title()
            if m := re.fullmatch(fr'Catégorie:Utilisateurs {code}-([01234M])', sub_title):
                level = m.group(1)
                print(f'{code}-{level}')

                lang_name = languages.get(code, {}).get('nom')
                if lang_name:
                    new_category = pwb.Category(site, title=level_categories_names[level].format(lang_name))
                    if new_category.exists():
                        new_category.text += f'[[{top_category_name}|{lang_name}]]'
                        new_category.save(summary='(Automatique) Catégorisation')
                else:
                    out.writelines([f'{code} : pas de langue\n'])

                for page in subcategory.articles():
                    title = page.title()
                    if title not in refreshed_users:
                        page.save()
                        refreshed_users.add(title)

out.close()
