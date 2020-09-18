/*
 * Esperanto language definition.
 * ----
 * [[Catégorie:Sous-page de CreerNouveauMot|eo]]
 */
(function () {
  var cnm = wikt.gadgets.creerNouveauMot;

  function getModel(word, grammarClass, gender, number, pron) {
    if (number === cnm.numbers.DIFF_SINGULAR_PLURAL.label) {
      return "{{eo-flexions|{0}}}".format(pron);
    }

    if (grammarClass.toLowerCase() === cnm.grammaticalClasses.VERB.label) {
      return "{{eo-verbe}}";
    }

    return "";
  }

  cnm.addLanguage(new cnm.Language(
      "eo",
      "eo",
      "epo",
      "espéranto",
      [
        ["a", "e", "i", "o", "u"],
        ["b", "d", "d͡ʒ", "f", "ɡ", "h", "k", "l", "m", "n", "p", "r", "s", "t", "t͡s", "t͡ʃ", "v", "x", "z", "ʃ", "ʒ"],
        ["j", "w"],
        [".", "ˈ"],
      ],
      [
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getModel),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.VERB_NO_TEMPLATE], null, getModel),
      ],
      function (word) {
        return word.toLowerCase()
            .replace(/c/g, "t͡s")
            .replace(/ĉ/g, "t͡ʃ")
            .replace(/g/g, "ɡ")
            .replace(/ĝ/g, "d͡ʒ")
            .replace(/ĥ/g, "x")
            .replace(/ĵ/g, "ʒ")
            .replace(/ŝ/g, "ʃ")
            .replace(/ŭ/g, "w");
      }
  ));
})();
