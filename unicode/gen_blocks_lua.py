with open('blocks.csv', encoding='UTF-8') as f_in:
    with open('../models-modules/fr/données_Unicode/blocs.lua', mode='w', encoding='UTF-8') as f_out:
        f_out.write("""--- Liste des blocs Unicode.
--- Valeurs : borne inférieure, borne supérieure, nom anglais, nom français, URL du PDF, version d’Unicode, année de \
publication
local blocks = {""")
        for line in f_in.readlines()[1:]:
            lower, upper, name, f_name, url, version, year = line.rstrip().split(',')
            f_out.write(
                f'\n  [0x{int(lower, 16):06X}] = {{ lower = 0x{int(lower, 16):06X}, upper = 0x{int(upper, 16):06X}, '
                f'name = {{en = "{name}", fr = "{f_name}"}}, url = "{url}", version = "{version}", year = "{year}" }},'
            )
        f_out.write("""
}

blocks.length = #blocks

return blocks
""")
