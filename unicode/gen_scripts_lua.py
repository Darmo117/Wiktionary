import datetime

import lxml.etree as etree
import requests

unicode_scripts = {}
with open('scripts.txt', encoding='UTF-8') as f:
    for script in f.readlines():
        script = script.strip()
        if '#' in script:
            script = script[:script.index('#')]
        if ';' in script:
            codes, script = [v.strip().replace(' ', '_') for v in script.split(';')]
            if script not in unicode_scripts:
                unicode_scripts[script] = []

            # Fusion des plages contigües
            if '..' in codes:
                lower, upper = [int(v, 16) for v in codes.split('..')]
            else:
                lower = upper = int(codes, 16)
            if len(unicode_scripts[script]) > 0 and unicode_scripts[script][-1][1] + 1 == lower:
                unicode_scripts[script][-1][1] = upper
            else:
                unicode_scripts[script].append([lower, upper])
unicode_scripts = dict(sorted(unicode_scripts.items()))

answer = requests.get('https://en.wikipedia.org/wiki/Template:ISO_15924_script_codes_and_related_Unicode_data')
root = etree.fromstring(answer.text)

directions = {
    'l-to-r': 'lr',
    'r-to-l': 'rl',
    't-to-b': 'tb',
    'mixed': 'm',
    'inherited': 'i',
}
script_to_direction = {}
for element in root.xpath('//div[@class="mw-parser-output"]/table[position()=1]/tbody/tr'):
    children = element.getchildren()
    if len(children) == 8 and children[0].tag == 'td':
        iso_code, unicode_code, direction = children[0].text.strip(), children[3].text, children[4].text
        if direction is not None:
            script_to_direction[iso_code] = directions[direction.strip().lower().replace('varies', 'mixed')]

iso_scripts = {}
with open('iso15924-utf8-20190819.txt', encoding='UTF-8') as f:
    for script in f.readlines():
        script = script.strip()
        if script != '' and script[0] != '#':
            iso_code, number, name, f_name, alias, _, _ = script.rstrip().split(';')
            if iso_code in ['Geok', 'Geor']:
                name = name[:name.index(' ')]
                f_name = f_name[:f_name.index(' ')]
            iso_scripts[alias] = (iso_code, name, f_name)

with open('../models-modules/données_Unicode/data/scripts.lua', mode='w', encoding='UTF-8') as f_out:
    f_out.write(f"""-- Liste des scripts Unicode/ISO 15924.
-- Do not edit this page manually as it is automatically generated.
-- Last generation: {datetime.datetime.now()}

-- Sources:
-- https://unicode.org/iso15924/iso15924-text.html
-- https://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt
-- https://en.wikipedia.org/w/index.php?title=Template:ISO_15924_script_codes_and_related_Unicode_data&oldid=945489720

-- Values: code, writing direction, {{english name, french name}}
-- Writing direction:
-- lr: left to right
-- rl: right to left
-- tb: top to bottom
-- m: mixed
-- i: inherited (diacritics)

return {{""")
    for unicode_script, unicode_script_data in unicode_scripts.items():
        iso_code, name, f_name = iso_scripts[unicode_script]
        f_out.write(
            f'\n  ["{unicode_script}"] = {{ code = "{unicode_script}", direction = "{script_to_direction[iso_code]}", '
            f'name = {{ en = "{name}", fr = "{f_name}" }} }},'
        )
    f_out.write(
        f'\n  -- Pour tous les caractères qui n’ont pas de script associé.'
    )
    f_out.write(
        f'\n  ["Unknown"] = {{ code = "Unknown", direction = nil, name = {{ en = "Unknown", fr = "Inconnu" }} }},'
    )
    f_out.write("""
}
""")

with open('../models-modules/données_Unicode/data/script_ranges.lua', mode='w', encoding='UTF-8') as f_out:
    f_out.write(f"""-- This page defines the code point ranges of all writing systems.
-- Do not edit this page manually as it is automatically generated.
-- Last generation: {datetime.datetime.now()}

-- Sources:
-- https://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt

return {{""")
    lines = {}
    for unicode_script, unicode_script_data in unicode_scripts.items():
        for range_ in unicode_script_data:
            lower, upper = range_
            lines[lower] = f'\n  [{{ 0x{lower:04X}, 0x{upper:04X} }}] = "{unicode_script}",'
    lines = dict(sorted(lines.items()))
    for line in lines.values():
        f_out.write(line)
    f_out.write("""
}
""")
