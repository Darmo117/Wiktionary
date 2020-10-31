/*******************************************************************************************
 * (en)
 * Lets the users create the page for a translation just by clicking its (red) link in the
 * French entry.
 *******************************************************************************************
 * (fr)
 * Permet aux utilisateurs de créer la page d’une traduction en cliquant juste sur son lien
 * (rouge) dans l’entrée en français.
 *******************************************************************************************
 * v1.0 2013-06-13
 * v2.0 2020-11-01 Full rewrite.
 *******************************************************************************************
 * [[Catégorie:JavaScript du Wiktionnaire|CreerTrad-dev]]
 *******************************************************************************************/

$(function () {
  console.log("Chargement de Gadget-CreerTrad-dev.js…");

  if (wikt.page.hasNamespaceIn([""]) && mw.config.get("wgAction") === "view") {
    window.wikt.gadgets.createTranslation = {
      NAME: "Créer traduction",

      VERSION: "2.0",

      /** @type {string} */
      _word: "",
      /** @type {string} */
      _translation: "",
      /** @type {string} */
      _langCode: "",
      /** @type {string} */
      _generatedWikicode: "",
      /**
       * Map that associates a language code to a
       * function that generates the code for it.
       * @type {Object<string, Function>}
       */
      _generators: {},

      /**
       * Initializes this gadget by hooking a callback to
       * every red links in the infoboxes with "translations" class.
       */
      init: function () {
        var self = this;

        $(".translations").find(".new").filter(function () {
          // On évite la colorisation des liens rouges pour les écritures traditionnelles (chinois et coréen)
          // ainsi que pour les liens interwikis en exposants qui utilisent des codes langue redirigés
          // (cf. [[Discussion_module:traduction#Liens en exposant et codes wikimédia]])
          var children = $(this).children();
          // noinspection JSUnresolvedFunction
          return children.length > 0 && !children.first().hasClass("ecrit_tradi") &&
              !children.first().hasClass("trad-inconnu");
        }).each(function () {
          var $link = $(this);
          var translation = /^(.*?) \(page inexistante\)$/.exec($link.attr("title"));

          if (translation) {
            translation = translation[1];

            // noinspection JSUnresolvedFunction
            var langCode = $link.children().first().attr("lang");
            $link.css("background-color", "#77B5FE");
            $link.attr("title", "Cliquez pour créer «\u00a0{0}\u00a0» avec le gadget".format(translation));
            $link.click(function (event) {
              event.preventDefault();
              self.createTrans(translation, langCode);
            });
          }
        });
      },

      /**
       * Register a generator for the given language.
       * @param langCode {string} Language’s code.
       * @param generator {Function} The generator function.
       */
      registerGeneratorForLanguage: function (langCode, generator) {
        this._generators[langCode] = generator;
      },

      /**
       * Makes a GET request to get the wikicode for the current page.
       * Stores the word, translation and language code for use further down the line.
       * @param translation {string} The word to create.
       * @param lang {string} The word’s language code.
       */
      createTrans: function (translation, lang) {
        this._word = mw.config.get("wgTitle");
        this._translation = translation;
        this._langCode = lang;

        // Get current article’s wikicode
        $.get(
            mw.config.get("wgServer") + mw.config.get("wgScript"),
            {
              "title": this._word,
              "action": "raw",
            },
            this._generateWikicode.bind(this)
        );
      },

      /**
       * Extracts relevent data to generate translation’s wikicode from the given wikicode.
       * @param wikicode {string} Current article’s wikicode.
       * @private
       */
      _generateWikicode: function (wikicode) {
        var wikicodeLines = wikicode.split("\n");

        var abort = false;

        var translationLineIndex = 0;
        var translationLine = "";
        var definitionsCounter = 0;
        var definitionLine = "";

        this._generatedWikicode = "";

        // Fetch line where the translation is.
        for (var i = 0; i < wikicodeLines.length && !abort && !translationLine; i++) {
          if (wikicodeLines[i].includes(this._langCode + "|" + this._translation)) {
            if (translationLine) {
              alert("Le gadget ne prend pas en charge le fait\n" +
                  "qu’une traduction apparaisse deux fois dans la même page.");
              abort = true;
            } else {
              translationLineIndex = i;
              translationLine = wikicodeLines[translationLineIndex];
            }
          }
        }

        if (!abort) {
          // Get transcription if there is one.
          var transcription = "";
          var transcriptionMatch = new RegExp(
              "{{trad[+-]{0,2}\\|" + this._langCode +
              "\\|" + this._translation + "\\|(?:[^}]*?\\|)?(?:R|tr)=([^=|}]*?)[|}]"
          ).exec(wikicodeLines[translationLineIndex]);
          if (transcriptionMatch) {
            transcription = transcriptionMatch[1];
          }

          // Get dif parameter if it is defined.
          // Example : <nowiki>* {{T|he}} : {{trad+|he|מכלב|R=makhlev|dif=מַכְלֵב}}</nowiki>
          var dif = "";
          var difMatch = new RegExp(this._langCode + "\\|" + this._translation + "[^}]*?dif=([^|}]*?)[|}]")
              .exec(wikicodeLines[translationLineIndex]);
          if (difMatch) {
            dif = difMatch[1];
          }

          // Get gender if there is one.
          var gender = "";
          var genderMatch = new RegExp(
              "\\{\\{trad[+-]{0,2}\\|" + this._langCode +
              "\\|" + this._translation + "\\|(?:[^}]*?\\|)?([^=|}]*?)[|}]"
          )
              .exec(wikicodeLines[translationLineIndex]);
          if (genderMatch) {
            gender = genderMatch[1];
          }

          // We go through each line from the translation until
          // we encounter one of the defined level-2 sections.
          // This section is the nature of the word.

          var natures = [
            [/S\|adjectif\|/, "adjectif"],
            [/S\|adverbe\|/, "adverbe"],
            [/S\|nom\|/, "nom"],
            [/S\|verbe\|/, "verbe"],
            [/S\|conjonction\|/, "conjonction"],
            [/S\|nom propre\|/, "nom propre"],
            [/S\|préposition\|/, "préposition"],
            [/S\|phrases\|/, "locution-phrase"],
            [/S\|onomatopée\|/, "onomatopée"],
            [/S\|interj(?:ection)?\|/, "interjection"],
          ];

          var nature = "";

          for (var j = translationLineIndex; j >= 0; j--) {
            var line = wikicodeLines[j];

            for (var k = 0; k < natures.length; k++) {
              if (natures[k][0].test(line)) {
                nature = natures[k][1];
              }
            }

            if (line.charAt(0) === "#" && line.charAt(1) !== "*") {
              definitionsCounter++;
              definitionLine = line;
            }
          }

          var domain = "";

          // If there is only one definition, we look for a domain-template.
          if (definitionsCounter === 1) {
            // We first look for a template of the form <nowiki>{{lexique|boulangerie|fr}}</nowiki>.
            var domainMatch = /{{lexique\|([^}]+?)\|[^|}]+?}}/.exec(definitionLine);

            if (domainMatch) {
              domain = domainMatch[1];
            } else {
              // Otherwise we look for old domain templates (e.g.: <nowiki>{{boulangerie|fr}}</nowiki>)
              domainMatch = /{{([^|}]+?)\|[^|}]+?}}/.exec(definitionLine);
              if (domainMatch) {
                domain = domainMatch[1];
              }
            }
          }

          // Wikicode generation.
          var newWikicode = "== {" + "{langue|{0}}} ==\n".format(this._langCode);
          newWikicode += "{" + "{ébauche|{0}}}\n".format(this._langCode);
          newWikicode += "=== {" + "{S|étymologie}} ===\n";
          newWikicode += ": {" + "{ébauche-étym|{0}}}\n\n".format(this._langCode);
          newWikicode += "=== {" + "{S|{0}|{1}}} ===\n".format(nature, this._langCode);

          var generator = this._generators[this._langCode];
          if (generator) {
            newWikicode += generator(this._translation, nature, gender, transcription, dif).trim();
          } else {
            newWikicode += this._genericGenerator(nature, gender, transcription, dif).trim();
          }

          newWikicode += "\n# ";
          if (domain) {
            newWikicode += "{" + "{lexique|{0}|{1}}} ".format(domain, this._langCode);
          }
          newWikicode += "[[{0}#fr|{1}]].\n".format(this._word, this._word.charAt(0).toUpperCase() + this._word.substring(1));
          newWikicode += "#* {" + "{exemple|lang={0}}}\n\n".format(this._langCode);

          this._generatedWikicode = newWikicode;
        }

        // Get HTML code of translation’s page.
        $.get(
            mw.config.get("wgServer") + mw.config.get("wgScript"),
            {
              "title": this._translation,
              "action": "edit",
            },
            this._replacePageContent.bind(this)
        );
      },

      /**
       * Replaces the content of the current page by that of the translation’s page in edit mode then loads the
       * generated wikicode in the edit field.
       * @param data {string} Translation’s page HTML code.
       * @private
       */
      _replacePageContent: function (data) {
        while (document.body.firstChild) {
          document.body.removeChild(document.body.firstChild);
        }
        document.body.innerHTML = data;
        document.getElementById("wpTextbox1").value = this._generatedWikicode;
        document.getElementById("wpSummary").value = "Création avec [[Aide:Gadget-CreerTrad-dev|Gadget-CreerTrad-dev]].";
      },

      /**
       * Fallback wikicode generator for languages not explicitly supported by the gadget.
       * @param nature {string} Word’s grammatical nature.
       * @param gender {string?} Word’s gender if any.
       * @param transcription {string?} Word’s latin transcription if any.
       * @param dif {string?} Text to show on the in place of the translation.
       * @return {string} The content of the main section.
       * @private
       */
      _genericGenerator: function (nature, gender, transcription, dif) {
        var wikicode = "";

        if (dif) {
          wikicode += "'''{0}'''".format(dif);
        } else {
          wikicode += "'''{0}'''".format(this._translation);
        }

        if (transcription) {
          wikicode += ", ''{0}''".format(transcription);
        }

        wikicode += (" {" + "{pron||{0}}}").format(this._langCode);

        if (nature === "nom" && gender) {
          wikicode += " {{{0}}}".format(gender);
        }

        return wikicode;
      }
    };

    // Catalan/Catalan
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "ca",
        function (translation, nature, gender) {
          var wikicode = "";

          if (nature === "nom") {
            wikicode += "{" + "{ca-rég|<!-- Compléter -->}}\n";
          }

          wikicode += ("'''{0}''' {" + "{pron||ca}}").format(translation);
          if (nature === "nom" && gender) {
            wikicode += " {{{0}}}".format(gender);
          }

          return wikicode;
        }
    );
    // Esperanto/Espéranto
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "eo",
        function (translation, nature) {
          var wikicode = "";

          if (nature === "adjectif" || nature === "nom") {
            wikicode += "{" + "{eo-flexions|<!-- Compléter -->}}\n";
          } else if (nature === "verbe") {
            wikicode += "{" + "{eo-verbe}}\n";
          }

          wikicode += ("'''{0}''' {" + "{pron||eo}}").format(translation);
          if (nature === "verbe") {
            wikicode += " {" + "{valence ?|eo}} {" + "{conjugaison|eo}}";
          }

          return wikicode;
        }
    );
    // Spanish/Espagnol
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "es",
        function (translation, nature, gender) {
          var wikicode = "";

          if (nature === "nom") {
            wikicode += "{" + "{es-rég|<!-- Compléter -->}}\n";
          }

          wikicode += ("'''{0}''' {" + "{pron||es}}").format(translation);
          if (nature === "nom" && gender) {
            wikicode += " {{{0}}}".format(gender);
          }

          return wikicode;
        }
    );
    // Italian/Italien
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "it",
        function (translation, nature, gender) {
          var wikicode = "";

          if (nature === "nom") {
            wikicode += "{" + "{it-flexion|<!-- Compléter -->}}\n";
          }

          wikicode += ("'''{0}''' {" + "{pron||it}}").format(translation);
          if (nature === "nom" && gender) {
            wikicode += " {{{0}}}".format(gender);
          } else {
            wikicode += " {" + "{genre ?|it}}";
          }

          return wikicode;
        }
    );
    // Occitan/Occitan
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "oc",
        function (translation, nature, gender) {
          var wikicode = "";

          if (nature === "adjectif") {
            wikicode += "{" + "{oc-accord-mixte|<!-- Compléter -->}}\n";
          } else if (nature === "nom") {
            wikicode += "{" + "{oc-rég|<!-- Compléter -->}}\n";
          }

          wikicode += ("'''{0}''' {" + "{pron||oc}}").format(translation);
          if (nature === "nom" && gender) {
            wikicode += " {{{0}}}".format(gender);
          }

          return wikicode;
        }
    );
    // Russian/Russe
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "ru",
        function (translation, nature, gender) {
          var wikicode = "";

          if (nature === "nom" && gender) {
            wikicode += "{" + "{ru-décl{0}|<!-- Compléter -->}}\n".format(gender);
          }

          wikicode += ("'''{0}''', ''{" + "{transliterator|ru|{0}}}'' {" + "{pron||ru}}").format(translation);
          if (nature === "nom" && gender) {
            wikicode += " {{{0}}}".format(gender);
          }

          return wikicode;
        }
    );
    // Swedish/Suédois
    wikt.gadgets.createTranslation.registerGeneratorForLanguage(
        "sv",
        function (translation, nature, gender) {
          var wikicode = "";

          if (nature === "adjectif") {
            wikicode += "{" + "{sv-adj}}\n";
          } else if (nature === "nom") {
            if (translation.endsWith("a")) {
              wikicode += "{" + "{sv-nom-c-or}}\n";
            } else if (translation.endsWith("ing")) {
              wikicode += "{" + "{sv-nom-c-ar}}\n";
            } else if (translation.endsWith("are")) {
              wikicode += "{" + "{sv-nom-c-ar|are=}}\n";
            } else if (translation.endsWith("ande")) {
              wikicode += "{" + "{sv-nom-n-n}}\n";
            } else if (translation.endsWith("ende")) {
              wikicode += "{" + "{sv-nom-n-n}}\n";
            } else if (translation.endsWith("um")) {
              wikicode += "{" + "{sv-nom-n-er|um=}}\n";
            } else if (translation.endsWith("tion")) {
              wikicode += "{" + "{sv-nom-c-er}}\n";
            } else if (translation.endsWith("tör")) {
              wikicode += "{" + "{sv-nom-c-er}}\n";
            } else if (translation.endsWith("ier")) {
              wikicode += "{" + "{sv-nom-c-er|r=}}\n";
            } else if (translation.endsWith("iker")) {
              wikicode += "{" + "{sv-nom-c-er|r=}}\n";
            } else if (translation.endsWith("else")) {
              wikicode += "{" + "{sv-nom-c-er|e=}}\n";
            } else {
              wikicode += "{" + "{sv-nom-c-er}}\n";
            }
          } else if (nature === "verbe") {
            wikicode += "{" + "{sv-conj-ar}}\n";
          }

          wikicode += ("'''{0}''' {" + "{pron||sv}}").format(translation);
          if (nature === "nom") {
            if (gender) {
              wikicode += " {{{0}}}".format(gender);
            } else if (translation.endsWith("ande") || translation.endsWith("ende") || translation.endsWith("um")) {
              wikicode += " {" + "{n|sv}}";
            } else {
              wikicode += " {" + "{c|sv}}";
            }
          }

          return wikicode;
        }
    );

    wikt.gadgets.createTranslation.init();
  }
});
