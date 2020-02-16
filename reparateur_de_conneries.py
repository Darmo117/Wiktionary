import re

import pywikibot

site = pywikibot.Site()
page = pywikibot.Page(site, 'Utilisateur:Unsui/eo_ntf')

words = page.text.splitlines(keepends=False)[10:47]
suffixes = ['j', 'n', 'jn']

for word in words:
    m = re.fullmatch(r'#\s*\[\[(.+)]]\s*\((.+)\)', word)
    if m is not None:
        word = m.group(1)
        flexions = [w + s for s in suffixes for w in word.split()]
        for suffix, flexion in zip(suffixes, flexions):
            length = len(suffix)
            p = pywikibot.Page(site, flexion)
            m = re.search(r'{{pron\|(.+)\|eo}}', p.text)
            pron = m.group(0)
            pron1 = m.group(1)
            pron_list = pron1.split()
            if len(pron_list) > 1:
                pron_list = [pr[:-length] if pr[-length - 1] not in 'ao' and pr[-1] in 'jn' else pr
                             for i, pr in enumerate(pron_list)]
                pron2 = ' '.join(pron_list)
                if pron1 != pron2:
                    p.text = p.text.replace(pron, f'{{{{pron|{pron2}|eo}}}}')
                    p.save(summary='Correction de mes bêtises', minor=True, botflag=True)
                else:
                    print(f'{flexion} already corrected')
            else:
                print(f'{flexion} skipped')
