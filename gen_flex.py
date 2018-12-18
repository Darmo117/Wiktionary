word = input('Word: ')
pron = input('Pron: ')

template = """
== {{{{langue|eo}}}} ==
=== {{{{S|{type}|eo|flexion}}}} ===
{{{{eo-rég|{pron}|ns={word}}}}}
'''{word}{ending}''' {{{{pron|{pron}{ending}|eo}}}}
# ''{case} {number} de'' {{{{lien|{word}|eo}}}}.
"""

endings = ['j', 'n', 'jn']
types = {
    'o': 'nom',
    'a': 'adjectif',
}
with open('out.txt', 'w', encoding='utf8') as f:
    for ending in endings:
        case = 'Accusatif' if 'n' in ending else 'Nominatif'
        number = 'pluriel' if 'j' in ending else 'singulier'
        f.write(template.format(word=word, pron=pron, ending=ending,
                                case=case, number=number,
                                type=types[word[-1]]))
