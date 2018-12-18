import sys

import eo_pron

if len(sys.argv) == 1:
    word = input('Word: ')
else:
    word = sys.argv[1]
print(eo_pron.pronunciation(word))
