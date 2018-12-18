_PHONEMS = {
    'a': 'a',
    'b': 'b',
    'c': 'c',
    'ĉ': 't͡ʃ',
    'd': 'd',
    'e': 'e',
    'f': 'f',
    'g': 'ɡ',
    'ĝ': 'd͡ʒ',
    'h': 'h',
    'ĥ': 'x',
    'i': 'i',
    'j': 'j',
    'ĵ': 'ʒ',
    'k': 'k',
    'l': 'l',
    'm': 'm',
    'n': 'n',
    'o': 'o',
    'p': 'p',
    'r': 'r',
    's': 's',
    'ŝ': 'ʃ',
    't': 't',
    'u': 'u',
    'ŭ': 'w',
    'v': 'v',
    'z': 'z',
}


def pronunciation(word: str) -> str:
    res = ''
    for c in word:
        if c in _PHONEMS:
            res += _PHONEMS[c]
        elif c == ' ':
            res += ' '
    return res
