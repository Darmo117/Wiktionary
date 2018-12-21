import pywikibot

import xh_systems as xs

site = pywikibot.Site()


def _get_page(page_name, flexion, prononciation, gram_class):
    klass = 'Accustif' if 'n' in flexion else 'Nominatif'
    number = 'pluriel' if 'j' in flexion else 'singulier'
    return f"""== {{{{langue|eo}}}} ==
=== {{{{S|{gram_class}|eo|flexion}}}} ===
{{{{eo-rég|{prononciation}|ns={page_name}}}}}
'''{page_name}{flexion}''' {{{{pron|{prononciation}{flexion}|eo}}}}
# ''{klass} {number} de'' {{{{lien|{page_name}|eo}}}}.
"""


def _create_flexion(page_name, flexion, prononciation):
    page = pywikibot.Page(site, f'{page_name}{flexion}')
    if page.text == '':
        gram_class = 'nom' if page_name[-1] == 'o' else 'adjectif'
        page.text = _get_page(page_name, flexion, prononciation, gram_class)
        x_system = xs.to_x_system(page_name)
        if page_name != x_system:
            page.text += f'\n{{{{clé de tri|{x_system}{flexion}}}}}\n'
        page.save('Flexion créée automatiquement.')
    else:
        print(f'Skipped {page_name}.')


def is_missing_flexions(word):
    page = pywikibot.Page(site, word)
    eo_reg = [t[0] for t in page.raw_extracted_templates if t[0] in ['eo-rég', 'eo-rég-v']]
    if len(eo_reg) == 0:
        return False
    page_j = pywikibot.Page(site, f'{word}j').text == ''
    page_jn = pywikibot.Page(site, f'{word}jn').text == ''
    page_n = pywikibot.Page(site, f'{word}n').text == ''
    return eo_reg[0] == 'eo-rég' and (page_j or page_jn or page_n)


def create_flexions(word, ask_pron=False):
    page = pywikibot.Page(site, word)
    pron = [t[1] for t in page.raw_extracted_templates if t[0] == 'pron']
    prononciation = pron[0]['1'].strip() if len(pron) and pron[0]['1'].strip() != '' else ''
    if prononciation == '' and ask_pron:
        prononciation = input('Prononciation: ')
    _create_flexion(word, 'j', prononciation)
    _create_flexion(word, 'n', prononciation)
    _create_flexion(word, 'jn', prononciation)


if __name__ == '__main__':
    word = input('Word: ')
    if is_missing_flexions(word):
        create_flexions(word, ask_pron=True)
