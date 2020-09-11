/*
 * International conventions "language" definition.
 * ----
 * [[Catégorie:Sous-page de CreerNouveauMot|conv]]
 */
(function () {
  var cnm = wikt.gadgets.creerNouveauMot;

  cnm.addLanguage(new cnm.Language(
      "conv",
      null,
      "conventions internationales",
      [],
      [
        new cnm.GrammaticalItem(cnm.grammaticalClasses.SCIENTIFIC_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.SYMBOL, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
        new cnm.GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
      ]
  ));
})();
