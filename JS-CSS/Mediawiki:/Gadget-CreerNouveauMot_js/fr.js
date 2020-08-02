/*
 * French language definition.
 * ----
 * [[Catégorie:Sous-page de CreerNouveauMot|fr]]
 */
(function () {
  var cnm = wikt.gadgets.creerNouveauMot;

  function getModel(word, grammarClass, gender, number, pron, simple) {
    if (number === cnm.numbers.INVARIABLE.label) {
      return "{{fr-inv|{0}|inv_titre={1}}}".format(pron, grammarClass);
    }
    if (number === cnm.numbers.SAME_SINGULAR_PLURAL.label) {
      return "{{fr-inv|{0}|sp=oui}}".format(pron, grammarClass);
    }
    if (number === cnm.numbers.SINGULAR_ONLY.label) {
      return "{{fr-inv|{0}|inv_titre=Singulier}}".format(pron);
    }
    if (number === cnm.numbers.PLURAL_ONLY.label) {
      return "{{fr-inv|{0}|inv_titre=Pluriel}}".format(pron);
    }

    if (gender === cnm.genders.FEMININE_MASCULINE.label) {
      return "{{fr-rég|{0}|mf=oui}}".format(pron);
    }

    if (simple) {
      return "{{fr-rég|{0}}}".format(pron);
    }
    else {
      return "{{fr-accord-rég|{0}}}".format(pron);
    }
  }

  cnm.addLanguage(new cnm.Language(
      "fr",
      "français",
      [
        ["a", "ɑ", "ɑ̃", "ə", "œ", "ø", "e", "ɛ", "i", "ɛ̃", "œ̃", "o", "ɔ", "ɔ̃", "y", "u"],
        ["b", "d", "f", "ɡ", "k", "l", "m", "n", "ɲ", "ŋ", "p", "ʁ", "s", "ʃ", "t", "v", "z", "ʒ"],
        ["j", "w", "ɥ"],
        [".", "‿"],
      ],
      [
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NUMERAL_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.DEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTITIVE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.COORDINATION_CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.LAST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSTPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREFIX, [cnm.genders.NO_GENDER]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.DEMONSTRATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PERSONAL_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.RELATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(word, grammarClass, gender, number, pron, true);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.SUFFIX, [cnm.genders.NO_GENDER]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.VERB_GROUP1, cnm.genders.VERB_GROUP2, cnm.genders.VERB_GROUP3]),
      ]
  ));
})();
