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
      "zh",
      "chinois",
      "", // TODO
      [
        // TODO
      ],
      [
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          if (number !== cnm.numbers.DIFF_SINGULAR_PLURAL.label) {
            return getModel(grammarClass, number, pron);
          }
          return "{{en-nom-rég|{0}}}".format(pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return getModel(grammarClass, number, pron);
        }),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.VERB, [], [cnm.numbers.INVARIABLE], function (word, grammarClass, gender, number, pron) {
          return gender.label === cnm.genders.REGULAR_VERB.label
              ? "{{en-conj-rég|inf.pron={0}}}".format(pron)
              : "{{en-conj-irrég|inf={0}|inf.pron={1}|<!-- Compléter -->}}".format(word, pron);
        }),
      ]
  ));
})();
