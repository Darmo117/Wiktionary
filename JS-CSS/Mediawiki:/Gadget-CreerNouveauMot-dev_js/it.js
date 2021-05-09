/*
 * Italian language definition.
 * ----
 * [[Catégorie:Sous-page de CreerNouveauMot-dev|it]]
 */
(function () {
  var cnm = wikt.gadgets.creerNouveauMot;

  function getModel(word, grammarClass, gender, number, pron) {
    if (number === cnm.numbers.INVARIABLE.label) {
      return "{{it-inv|{0}|inv_titre={1}}}".format(pron, grammarClass);
    }
    if (number === cnm.numbers.SAME_SINGULAR_PLURAL.label) {
      return "{{it-inv|{0}|sp=oui}}".format(pron, grammarClass);
    }
    if (number === cnm.numbers.SINGULAR_ONLY.label) {
      return "{{it-inv|{0}|inv_titre=Singulier}}".format(pron);
    }
    if (number === cnm.numbers.PLURAL_ONLY.label) {
      return "{{it-inv|{0}|inv_titre=Pluriel}}".format(pron);
    }

    if (gender === cnm.genders.FEMININE_MASCULINE.label) {
      return "{{it-flexion|{0}|mf=oui}}".format(pron);
    }

    return "{{it-flexion|{0}}}".format(pron);
  }

  cnm.addLanguage(new cnm.Language(
      "it",
      "it",
      "ita",
      "italien",
      [
        ["a", "e", "ɛ", "i", "o", "ɔ", "u"],
        ["b", "d", "d͡z", "d͡ʒ", "f", "ɡ", "k", "l", "ʎ", "m", "ɱ", "n", "ŋ", "ɲ", "p", "r", "s", "ʃ", "t", "t͡s", "t͡ʃ", "v", "z"],
        ["j", "w"],
        [".", "ˈ", "ː"],
      ],
      [
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.FEMININE_MASCULINE_DIFF, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.VERB_GROUP1, cnm.genders.VERB_GROUP2, cnm.genders.VERB_GROUP3]),

        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NUMERAL_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.DEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTITIVE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.COORDINATION_CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.LAST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSTPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREFIX, [cnm.genders.NO_GENDER]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.DEMONSTRATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PERSONAL_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.RELATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.SUFFIX, [cnm.genders.NO_GENDER]),
      ]
  ));
})();
