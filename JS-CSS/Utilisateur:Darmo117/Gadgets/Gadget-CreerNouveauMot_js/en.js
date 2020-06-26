(function () {
  var cnm = wikt.gadgets.creerNouveauMot;

  function getModel(grammarClass, number, pron) {
    if (number === cnm.numbers.SAME_SINGULAR_PLURAL.label) {
      return "{{en-inv|{0}|sp=oui}}".format(pron);
    }
    if (number === cnm.numbers.SINGULAR_ONLY.label) {
      return "{{en-inv|{0}|inv_titre=Singulier}}".format(pron);
    }
    if (number === cnm.numbers.PLURAL_ONLY.label) {
      return "{{en-inv|{0}|inv_titre=Pluriel}}".format(pron);
    }

    return "{{en-inv|{0}|inv_titre={1}}}".format(pron, grammarClass);
  }

  cnm.addLanguage(new cnm.Language(
      "en",
      "anglais",
      [
        ["i", "iː", "ɪ", "ɛ", "æ", "ə", "ɚ", "ɜː", "ɝ", "uː", "u", "ʊ", "ʌ", "ɔː", "ɑː", "ɒ"],
        ["aɪ", "aʊ", "ɔɪ", "eɪ", "əʊ", "oʊ", "ɪə", "eə", "ʊə", "uə", "ɔə"],
        ["b", "d", "f", "ɡ", "h", "k", "l", "m", "n", "ŋ", "ɲ", "p", "ɹ", "ɻ", "s", "ʃ", "t", "θ", "ð", "v", "w", "j", "z", "ʒ"],
        ["ˌ", "ˈ", "ː"],
      ],
      [
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NUMERAL_ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.DEFINITE_ARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_ARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTITIVE_ARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.COORDINATION_CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          if (number !== cnm.numbers.DIFF_SINGULAR_PLURAL.label) {
            return getModel(grammarClass, number, pron);
          }
          return "{{en-nom-rég|{0}}}".format(pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.LAST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSTPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREFIX, [cnm.genders.NO_GENDER]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.DEMONSTRATIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PERSONAL_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.RELATIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.SUFFIX, [cnm.genders.NO_GENDER]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.REGULAR_VERB, cnm.genders.IRREGULAR_VERB], [], function (word, grammarClass, gender, number, pron) {
          return gender.label === cnm.genders.REGULAR_VERB.label
              ? "{{en-conj-rég|inf.pron={0}}}".format(pron)
              : "{{en-conj-irrég|inf={0}|inf.pron={1}|<!-- Compléter -->}}".format(word, pron);
        }),
      ]
  ));
})();
