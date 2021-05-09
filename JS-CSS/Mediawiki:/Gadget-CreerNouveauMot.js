/**
 * (fr)
 * Ce gadget permet de facilement créer une entrée dans une langue donnée en
 * remplissant quelques champs de texte.
 * ------------------------------------------------------------------------------------
 * (en)
 * This gadget helps create new entries for a given language by filling out some
 * text fields.
 * ------------------------------------------------------------------------------------
 * v2.0 2012-12-10
 * v2.1 2012-12-26
 * v2.2 2013-01-01
 * v2.3 2013-01-04 dialog box functions restructuration
 * v2.4 2013-01-29 cookies to store preferences
 * v3.0 2013-02-28 tool integration into pages
 * v4.0 2014-01-22 support for new editable sections syntax
 * v5.0 2020-07-29 full rewrite, migration to OOUI
 * v5.0.1 2020-08-01 using {{lien}} for links, reworked toolbar
 * v5.0.2 2020-08-02 added missing sections
 * v5.0.3 2020-08-05 added date template in etymology section
 * v5.0.4 2020-08-05 reordering level 4 sections
 * v5.0.5 2020-08-10 sister projects search links now update on language selection
 * v5.0.6 2020-08-11 inserting : and # if missing
 * v5.0.7 2020-08-20 added default grammatical classes for undefined languages
 * v5.0.8 2020-08-25 added {{type}} template to verbs, fields to insert an image,
 *                   field to add categories; removed lang parameter for some
 *                   interwiki templates
 * v5.1 2020-09-20 added pronunciation section field; added ISO 639-3 code to Language
 *                 class; removed sources section; added help bubbles to some fields
 * v5.1.1 2021-05-08 Edit notice is no longer overwritten by the button
 * ------------------------------------------------------------------------------------
 * [[Catégorie:JavaScript du Wiktionnaire|CreerNouveauMot.js]]
 */

$(function () {
  "use strict";

  // Activate only in main namespace when in edit/submit mode.
  if (wikt.page.hasNamespaceIn([""]) && ["edit", "submit"].includes(mw.config.get("wgAction"))) {
    console.log("Chargement de Gadget-CreerNouveauMot.js…");

    mw.loader.using(["oojs-ui-core", "oojs-ui-widgets", "oojs-ui-toolbars", "oojs-ui-windows"], function () {
      window.wikt.gadgets.creerNouveauMot = {
        NAME: "Créer nouveau mot",

        VERSION: "5.1.1",

        _COOKIE_NAME: "cnm_last_lang",
        /** Cookie duration in days. */
        _COOKIE_DURATION: 30,

        /**
         * List of sister projects and associated templates and domain names.
         * @type {Object<string, Object<string, string>>}
         */
        _OTHER_PROJECTS: {
          w: {label: "Wikipédia", templateName: "WP", urlDomain: "{0}.wikipedia.org"},
          s: {label: "Wikisource", templateName: "WS", urlDomain: "{0}.wikisource.org"},
          q: {label: "Wikiquote", templateName: "WQ", urlDomain: "{0}.wikiquote.org"},
          v: {label: "Wikiversité", templateName: "WV", urlDomain: "{0}.wikiversity.org"},
          l: {label: "Wikilivres", templateName: "WL", urlDomain: "{0}.wikibooks.org"},
          species: {label: "Wikispecies", templateName: "WSP", urlDomain: "wikispecies.org"},
          voy: {label: "Wikivoyage", templateName: "VOY", urlDomain: "{0}.wikivoyage.org"},
          n: {label: "Wikinews", templateName: "WN", urlDomain: "{0}.wikinews.org"},
          d: {label: "Data", templateName: "WD", urlDomain: "wikidata.org"},
          c: {label: "Commons", templateName: "Commons", urlDomain: "commons.wikimedia.org"},
          vikidia: {
            label: "Vikidia",
            templateName: "Vikidia",
            urlDomain: "{0}.vikidia.org",
            showOnlyForLangs: ["fr", "ca", "de", "el", "en", "es", "eu", "it", "ru", "scn", "hy"],
          },
          dicoado: {
            label: "Le Dico des Ados",
            templateName: "Dicoado",
            urlDomain: "dicoado.org",
            urlBase: "wiki/index.php?search=",
            showOnlyForLangs: ["fr"],
          },
        },

        /**
         * List of word type subsections.
         * @type {Array<Object<string, string|boolean>>}
         */
        _SECTIONS: [
          {
            label: "Autre alphabet ou système d’écriture",
            code: "écriture",
            help: "",
            level: 4,
          },
          {
            label: "Variantes orthographiques",
            code: "variantes orthographiques",
            help: "",
            level: 4,
          },
          {
            label: "Variantes",
            code: "variantes",
            help: "",
            level: 4,
          },
          {
            label: "Transcriptions",
            code: "transcriptions",
            help: "",
            level: 4,
          },
          {
            label: "Abréviations",
            code: "abréviations",
            help: "Aide:Abréviations, sigles et acronymes",
            level: 4,
          },
          {
            label: "Augmentatifs",
            code: "augmentatifs",
            help: "",
            level: 4,
          },
          {
            label: "Diminutifs",
            code: "diminutifs",
            help: "",
            level: 4,
          },
          {
            label: "Synonymes",
            code: "synonymes",
            help: "Aide:Synonymes et antonymes",
            level: 4,
          },
          {
            label: "Quasi-synonymes",
            code: "quasi-synonymes",
            help: "Aide:Synonymes et antonymes",
            level: 4,
          },
          {
            label: "Antonymes",
            code: "antonymes",
            help: "Aide:Synonymes et antonymes",
            level: 4,
          },
          {
            label: "Gentilés",
            code: "gentilés",
            help: "",
            level: 4,
          },
          {
            label: "Composés",
            code: "composés",
            help: "",
            level: 4,
          },
          {
            label: "Dérivés",
            code: "dérivés",
            help: "Aide:Mots et locutions dérivés",
            level: 4,
          },
          {
            label: "Apparentés étymologiques",
            code: "apparentés",
            help: "Aide:Mots apparentés",
            level: 4,
          },
          {
            label: "Vocabulaire",
            code: "vocabulaire",
            help: "Aide:Vocabulaire apparenté",
            level: 4,
          },
          {
            label: "Phrases et expressions",
            code: "phrases",
            help: "Aide:Expressions du mot vedette",
            level: 4,
          },
          {
            label: "Variantes dialectales",
            code: "variantes dialectales",
            help: "",
            level: 4,
          },
          {
            label: "Hyperonymes",
            code: "hyperonymes",
            help: "Aide:Hyperonymes et hyponymes",
            level: 4,
          },
          {
            label: "Hyponymes",
            code: "hyponymes",
            help: "Aide:Hyperonymes et hyponymes",
            level: 4,
          },
          {
            label: "Holonymes",
            code: "holonymes",
            help: "Aide:Méronymes et holonymes",
            level: 4,
          },
          {
            label: "Méronymes",
            code: "méronymes",
            help: "Aide:Méronymes et holonymes",
            level: 4,
          },
          {
            label: "Hyper-verbes",
            code: "hyper-verbes",
            help: "",
            level: 4,
          },
          {
            label: "Troponymes",
            code: "troponymes",
            help: "",
            level: 4,
          },
          {
            label: "Traductions",
            code: "traductions",
            level: 4,
            hidden: true,
          },
          {
            label: "Dérivés dans d’autres langues",
            code: "dérivés autres langues",
            help: "",
            level: 4,
          },
          {
            label: "Faux-amis",
            code: "faux-amis",
            help: "",
            level: 4,
          },
          {
            label: "Anagrammes",
            code: "anagrammes",
            help: "Aide:Anagrammes",
            level: 3,
          },
        ],

        /**
         * Main word.
         * @type {string}
         * @private
         */
        _word: mw.config.get("wgTitle").replace("_", " "),

        /**
         * Currently selected language.
         * @type {wikt.gadgets.creerNouveauMot.Language}
         * @private
         */
        _selectedLanguage: null,

        /**
         * List of available languages.
         * @type {Array<wikt.gadgets.creerNouveauMot.Language>}
         * @private
         */
        _languages: [],

        /**
         * Start up GUI.
         * @type {wikt.gadgets.creerNouveauMot.StartGui}
         * @private
         */
        _startGui: null,

        /**
         * Main GUI.
         * @type {wikt.gadgets.creerNouveauMot.MainGui}
         * @private
         */
        _gui: null,

        /*
         * Public functions
         */

        /**
         * Initializes this gadget.
         */
        init: function () {
          // Sorting languages: french first,
          // then all remaining in lexicographical order.
          this._languages.sort(function (a, b) {
            if (a.code === "fr") {
              return -1;
            } else if (b.code === "fr") {
              return 1;
            } else {
              return a.name.localeCompare(b.name);
            }
          });

          if ($(this.Gui.prototype.TARGET_ELEMENT)) {
            this._generateStartUi();
          }
        },

        /**
         * Adds a language to the list of available languages.
         * @param language {wikt.gadgets.creerNouveauMot.Language} The language to add.
         */
        addLanguage: function (language) {
          this._languages.push(language);
        },

        /**
         * Fecthes the language with the given code.
         * @param languageCode {string} Language code.
         * @returns {wikt.gadgets.creerNouveauMot.Language|null} The language object or null if none were found.
         */
        getLanguage: function (languageCode) {
          for (var i = 0; i < this._languages.length; i++) {
            var lang = this._languages[i];
            if (lang.code === languageCode) {
              return lang;
            }
          }
          return null;
        },

        /*
         * Private functions
         */

        /**
         * Generates the start up GUI.
         * @private
         */
        _generateStartUi: function () {
          this._startGui = new this.StartGui(this.NAME, this._generateMainUi.bind(this));
        },

        /**
         * Generates the main GUI.
         * @private
         */
        _generateMainUi: function () {
          this._gui = new this.MainGui(
              this._word,
              this._languages,
              this._SECTIONS,
              this._onLanguageSelect.bind(this),
              this._onClassSelect.bind(this),
              this._insertWikicode.bind(this),
              this._OTHER_PROJECTS
          );

          var previousLang = wikt.cookie.read(this._COOKIE_NAME);
          this._onLanguageSelect(previousLang || this._languages[0].code);
          this._gui.sortingKey = wikt.page.getSortingKey(this._word);
          this._gui.isDraft = false;
        },

        /**
         * Generates the wikicode then inserts it into the edit box.
         * @private
         */
        _insertWikicode: function () {
          var word = this._word;
          var langCode = this._selectedLanguage.code;
          var isDraft = this._gui.isDraft;
          var etymology = this._gui.etymology || ": {{date|lang={0}}} {{ébauche-étym|{0}}}".format(langCode);
          var pron = this._gui.pronunciation;
          var isConv = langCode === "conv";

          var grammarItem = this._selectedLanguage.getGrammarItem(this._gui.grammarClass);
          var gender = grammarItem.getGender(this._gui.gender);
          var number = grammarItem.getNumber(this._gui.number);
          var grammarClass = grammarItem.grammaticalClass;
          var inflectionsTemplate = grammarItem.getInflectionsTemplate(word, gender.label, number.label, pron);
          var imageName = this._gui.imageName;
          var imageDescription = this._gui.imageDescription;

          var definition = this._gui.definition || "# {{ébauche-déf|{0}}}".format(langCode);

          var references = this._gui.references;
          var bibliography = this._gui.bibliography;
          var sortingKey = this._gui.sortingKey;

          function parseDefinition(definition) {
            var def = "";
            var defLines = definition.split("\n");

            for (var i = 0; i < defLines.length; i++) {
              var line = defLines[i];
              var defFound = false;

              if (line.charAt(0) !== "#") {
                def += "# " + line + "\n";
                defFound = true;
              } else {
                def += line + "\n";
                defFound = line.charAt(1) !== "*";
              }

              if (defFound && (i === defLines.length - 1 || defLines[i + 1].substr(0, 2) !== "#*")) {
                def += "#* {{ébauche-exe|{0}}}\n".format(langCode);
              }
            }

            return def.trim();
          }

          // Add : at the beginning of each line
          etymology = etymology.replace(/(^|\n)(?!:)/g, "$1: ");

          var wikicode = "== {{langue|{0}}} ==\n".format(langCode)
              + (isDraft ? "{{ébauche|{0}}}\n".format(langCode) : "")
              + "=== {{S|étymologie}} ===\n"
              + etymology + "\n\n"
              + "=== {{S|{0}|{1}}} ===\n".format(grammarClass.sectionCode, langCode)
              + (inflectionsTemplate ? inflectionsTemplate + "\n" : "");
          if (imageName) {
            wikicode += "[[Image:{0}|vignette|{1}]]\n".format(imageName, imageDescription);
          }
          wikicode += "'''{0}'''".format(word);
          if (isConv) {
            wikicode += "\n";
          } else {
            // trim() to remove trailing space(s) if no gender or number template.
            wikicode += " " + "{{pron|{0}|{1}}} {2} {3}".format(pron, langCode, gender.template.format(langCode), number.template.format(langCode))
                .replace(/\s+/g, " ").trim() + "\n";
          }
          wikicode += parseDefinition(definition) + "\n\n";

          function linkify(content) {
            var lines = content.split("\n");

            for (var i = 0; i < lines.length; i++) {
              var line = lines[i];

              if (/^[^=#:;\[{\s][^\s]*/.test(line)) {
                lines[i] = "* {{lien|{0}|{1}}}".format(line.trim(), langCode);
              } else if (/^\*\s*[^\s]+/.test(line)) {
                lines[i] = "* {{lien|{0}|{1}}}".format(line.substring(1).trim(), langCode);
              }
            }

            return lines.join("\n").trim();
          }

          var anagramsSection = "";

          for (var i = 0; i < this._SECTIONS.length; i++) {
            var section = this._SECTIONS[i];
            var sectionCode = section.code;
            var sectionLevel = section.level;

            if (sectionCode !== "traductions" || langCode === "fr") {
              var content = sectionCode !== "traductions"
                  ? this._gui.getSectionContent(sectionCode)
                  : "{{trad-début}}\n{{trad-fin}}\n\n";
              var upperSection = section.section;
              var titleLevel;

              if (content) {
                var temp = "";

                if (upperSection && !wikicode.includes("S|" + upperSection)) {
                  titleLevel = Array(sectionLevel).join("=");
                  temp += "{1} {{S|{0}}} {1}\n".format(upperSection, titleLevel);
                }
                titleLevel = Array(sectionLevel + 1).join("=");
                temp += "{1} {{S|{0}}} {1}\n".format(sectionCode, titleLevel)
                    + linkify(content) + "\n\n";

                if (sectionCode === "anagrammes") {
                  anagramsSection = temp;
                } else {
                  wikicode += temp;
                }
              }
            }
          }

          var pronSection = "";
          var pronunciationContent = this._gui.pronunciationSection;
          var homophones = this._gui.homophones;
          var paronyms = this._gui.paronyms;

          if (pronunciationContent || homophones || paronyms) {
            pronSection = "=== {{S|prononciation}} ===\n";
            if (pronunciationContent) {
              pronSection += "{0}\n\n".format(pronunciationContent);
            }
            if (homophones) {
              pronSection += "==== {{S|homophones|{0}}} ====\n{1}\n\n".format(langCode, linkify(homophones));
            }
            if (paronyms) {
              pronSection += "==== {{S|paronymes}} ====\n{0}\n\n".format(linkify(paronyms));
            }
          }
          wikicode += pronSection;

          wikicode += anagramsSection;

          var seeAlsoSection = "";
          for (var projectCode in this._OTHER_PROJECTS) {
            if (this._OTHER_PROJECTS.hasOwnProperty(projectCode)) {
              var addLink = this._gui.hasAddLinkToProject(projectCode);

              if (addLink) {
                var projectModelParams = this._gui.getProjectLinkParams(projectCode);
                var templateName = this._OTHER_PROJECTS[projectCode].templateName;

                if (seeAlsoSection === "") {
                  seeAlsoSection = "=== {{S|voir aussi}} ===\n";
                }
                var langParam = this._OTHER_PROJECTS[projectCode].urlDomain.includes("{0}") ? "|lang=" + langCode : "";
                seeAlsoSection += "* {{{0}{1}{2}}}\n".format(templateName, projectModelParams ? "|" + projectModelParams : "", langParam);
              }
            }
          }
          if (seeAlsoSection) {
            seeAlsoSection += "\n";
          }
          wikicode += seeAlsoSection;

          var containsRefTemplates = /{{(R|RÉF|réf)\||<ref>.+<\/ref>/gm.test(wikicode);

          if (containsRefTemplates || references || bibliography) {
            var insertSourcesSection = containsRefTemplates;

            if (references || insertSourcesSection || bibliography) {
              wikicode += "=== {{S|références}} ===\n";
              if (references) {
                wikicode += references + "\n\n";
              }
            }
            if (insertSourcesSection) {
              wikicode += "==== {{S|sources}} ====\n{{Références}}\n\n";
            }
            if (bibliography) {
              wikicode += "==== {{S|bibliographie}} ====\n" + bibliography + "\n\n";
            }
          }

          wikicode += (sortingKey !== word ? "{{clé de tri|{0}}}\n".format(sortingKey) : "");

          this._gui.categories.forEach(function (category) {
            wikicode += "[[Catégorie:{0}]]\n".format(category);
          });

          wikt.edit.insertText(wikt.edit.getCursorLocation(), wikicode);

          var $summaryFld = wikt.edit.getEditSummaryField();
          var summary = $summaryFld.val();
          var comment = this._editComment();

          if (!summary.includes(comment)) {
            $summaryFld.val(comment + " " + summary);
          }

          // Collapse gadget after inserting wikicode.
          // $(".oo-ui-tool-name-hide > a")[0].click(); // FIXME not triggered
        },

        /**
         * Function called whenever the user selects a language.
         * @param languageCode {string} Code of the selected language.
         * @private
         */
        _onLanguageSelect: function (languageCode) {
          languageCode = languageCode.trim();

          if (languageCode !== "") {
            var language = this.getLanguage(languageCode);

            if (!language) {
              language = new wikt.gadgets.creerNouveauMot.Language(languageCode, null, null, languageCode, [], [
                new wikt.gadgets.creerNouveauMot.GrammaticalItem(wikt.gadgets.creerNouveauMot.grammaticalClasses.ADJECTIVE),
                new wikt.gadgets.creerNouveauMot.GrammaticalItem(wikt.gadgets.creerNouveauMot.grammaticalClasses.ADVERB),
                new wikt.gadgets.creerNouveauMot.GrammaticalItem(wikt.gadgets.creerNouveauMot.grammaticalClasses.NOUN),
                new wikt.gadgets.creerNouveauMot.GrammaticalItem(wikt.gadgets.creerNouveauMot.grammaticalClasses.PROPER_NOUN),
                new wikt.gadgets.creerNouveauMot.GrammaticalItem(wikt.gadgets.creerNouveauMot.grammaticalClasses.VERB),
              ]);
            }
            this._selectedLanguage = language;
            wikt.cookie.create(this._COOKIE_NAME, language.code, this._COOKIE_DURATION);
            this._gui.selectLanguage(this._selectedLanguage);

            if (!this._gui.pronunciation) {
              this._gui.pronunciation = language.generatePronunciation(this._word);
            }
          }
        },

        /**
         * Function called whenever the user selects a grammatical class.
         * @param className {string} Code of the selected grammatical class.
         * @private
         */
        _onClassSelect: function (className) {
          var grammarItem = this._selectedLanguage.getGrammarItem(className);
          this._gui.setAvailableGenders(grammarItem.availableGenders);
          this._gui.setAvailableNumbers(grammarItem.availableNumbers);
        },

        /**
         * Returns the edit comment.
         * It is a function and not an attribute as “this.VERSION” would not be defined yet.
         * @return {string}
         * @private
         */
        _editComment: function () {
          return "Ajout d’un mot assisté par [[Aide:Gadget-CreerNouveauMot|{0}]] (v{1})".format(this.NAME, this.VERSION);
        },
      };

      /**
       * This class encapsulates data and behaviors specific to the given language.
       * @param code {string} Language code defined in [[Module:langues/data]].
       * @param wikimediaCode {string?} Language code used by WikiMedia projects.
       * @param iso6393Code {string?} ISO 639-3 language code.
       * @param name {string} Language’s name (in French).
       * @param ipaSymbols {Array<Array<string>>?} An optional list of common IPA symbols for the language.
       * @param grammarItems {Array<wikt.gadgets.creerNouveauMot.GrammaticalItem>?} An optional list of grammatical items.
       * @param pronGenerator {Function?} An optional function that generates an approximate pronunciation
       * based on the word.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.Language = function (code, wikimediaCode, iso6393Code, name, ipaSymbols, grammarItems, pronGenerator) {
        /** @type {string} */
        this._code = code;
        /** @type {string} */
        this._wikimediaCode = wikimediaCode;
        /** @type {string} */
        this._iso6393Code = iso6393Code;
        /** @type {string} */
        this._name = name;
        /** @type {Array<Array<string>>} */
        this._ipaSymbols = ipaSymbols || [];
        /** @type {Object<string, wikt.gadgets.creerNouveauMot.GrammaticalItem>} */
        this._grammarItems = {};
        /** @type {Function} */
        this._pronGenerator = pronGenerator || function () {
          return "";
        };

        grammarItems = grammarItems || [];
        for (var i = 0; i < grammarItems.length; i++) {
          var grammarItem = grammarItems[i];
          this._grammarItems[grammarItem.grammaticalClass.sectionCode] = grammarItem;
        }
      };

      // noinspection JSValidateTypes
      wikt.gadgets.creerNouveauMot.Language.prototype = {
        /**
         * @return {string} This language’s code.
         */
        get code() {
          return this._code;
        },

        /**
         * @return {string} This language’s WikiMedia code.
         */
        get wikimediaCode() {
          return this._wikimediaCode;
        },

        /**
         * @return {string} This language’s ISO 639-3 code.
         */
        get iso6393Code() {
          return this._iso6393Code;
        },

        /**
         * @return {string} This language’s name.
         */
        get name() {
          return this._name;
        },

        /**
         * @return {Array<Array<string>>} The IPA symbols for this language.
         */
        get ipaSymbols() {
          return this._ipaSymbols;
        },

        /**
         * @return {Object<string, wikt.gadgets.creerNouveauMot.GrammaticalItem>} The grammatical items for this language.
         */
        get grammarItems() {
          return this._grammarItems;
        },

        /**
         * Fetches the grammatical item that has the given section title.
         * @param sectionName {string} Section’s title.
         * @return {wikt.gadgets.creerNouveauMot.GrammaticalItem} The grammatical item if found or undefined otherwise.
         */
        getGrammarItem: function (sectionName) {
          return this._grammarItems[sectionName];
        },

        /**
         * Generates the pronunciation of the given word for this language.
         * @param word {string} The word.
         * @return {string} The pronunciation or an empty string if no function was defined in the constructor.
         */
        generatePronunciation: function (word) {
          return this._pronGenerator(word);
        }
      };

      /**
       * Wrapper class for OO.ui.TabPanelLayout.
       * @param name {string} Tab’s name.
       * @param options {Object} OOUI tab’s options.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.Tab = function (name, options) {
        OO.ui.TabPanelLayout.call(this, name, options);
      };

      // Inherit from OOUI TabPanelLayout’s prototype.
      wikt.gadgets.creerNouveauMot.Tab.prototype = Object.create(OO.ui.TabPanelLayout.prototype);

      /**
       * Sets this tab as active.
       */
      wikt.gadgets.creerNouveauMot.Tab.prototype.select = function () {
        // noinspection JSUnresolvedFunction
        this.setActive(true);
      };

      /**
       * Base class for GUIs.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.Gui = function () {
      };

      // noinspection JSValidateTypes
      wikt.gadgets.creerNouveauMot.Gui.prototype = {
        /** jQuery selector of the HTML element GUIs will be inserted into. */
        TARGET_ELEMENT: "#Editnotice-0",
      }

      /**
       * Inherits from wikt.gadgets.creerNouveauMot.Gui.
       * @param gadgetName {string}
       * @param onActivateGadget {function}
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.StartGui = function (gadgetName, onActivateGadget) {
        wikt.gadgets.creerNouveauMot.Gui.call(this);

        var $target = $(this.TARGET_ELEMENT);

        var headerText = '<div class="center" style="margin-bottom: 5px">' +
            '<span id="cnm-open-ui" class="mw-ui-button mw-ui-progressive">' +
            'Ouvrir le gadget {0}'.format(gadgetName) +
            '</span>' +
            '</div>';
        $target.append(headerText);
        $target.find("#cnm-open-ui").on("click", onActivateGadget);
      };

      // Inherit from gadget Gui’s prototype.
      wikt.gadgets.creerNouveauMot.StartGui.prototype = Object.create(wikt.gadgets.creerNouveauMot.Gui.prototype);

      /**
       * Inherits from wikt.gadgets.creerNouveauMot.Gui.
       * @param word {string} The word.
       * @param languages {Array<wikt.gadgets.creerNouveauMot.Language>} The language.
       * @param sections {Array<Object<string, string>>} The list of word type sub-sections.
       * @param onLanguageSelect {Function<string|null, void>} Callback function for when a language is selected.
       * @param onClassSelect {Function} Callback function for when a grammatical class is selected.
       * @param onInsertWikicode {Function} Callback function for when “insert wikicode” button is clicked.
       * @param otherProjects {Object<string, string>} Object containing data for sister projects.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.MainGui = function (word, languages, sections, onLanguageSelect, onClassSelect, onInsertWikicode, otherProjects) {
        wikt.gadgets.creerNouveauMot.Gui.call(this);

        this._word = word;
        /**
         * Tabs list.
         * @type {Array<wikt.gadgets.creerNouveauMot.Tab>}
         */
        this._tabs = [];
        this._languageFld = null;
        this._languageSelectFld = null;
        this._languageBnt = null;
        this._grammarClassSelectFld = null;
        this._gendersFld = null;
        this._numbersFld = null;
        this._imageFld = null;
        this._imageDescriptionFld = null;
        this._pronunciationFld = null;
        this._pronunciationPnl = null;
        this._definitionFld = null;
        this._categoriesWidget = null;
        this._etymologyFld = null;
        this._pronunciationSectionFld = null;
        this._homophonesFld = null;
        this._paronymsFld = null;
        this._referencesFld = null;
        this._bibliographyFld = null;
        /**
         * Word type sub-sections list.
         * @type {Object<string, Object>}
         */
        this._otherSectionFields = {};
        this._draftChk = null;
        this._seeOtherProjectsChk = {};
        this._sortKeyFld = null;
        this._otherProjects = otherProjects;

        // Deleting all content above edit box.
        $("#nouvel-article").parent().remove();

        var $tedit = $(this.TARGET_ELEMENT);

        var specialChars = "’àÀâÂæÆçÇéÉèÈêÊëËîÎïÏôÔœŒùÙûÛüÜÿŸ".split("");
        specialChars.push("«\u00a0");
        specialChars.push("\u00a0»");

        // Alias to avoid confusion inside nested functions.
        var self = this;

        /**
         * Returns the help link for the given help page name.
         * @param pageName {string} The page name.
         * @return {OO.ui.HtmlSnippet|string} The HtmlSnippet object
         * for the link or an empty string if the argument evaluates to false.
         */
        function getHelpPageLink(pageName) {
          if (pageName) {
            var title = pageName.includes("#") ? pageName.substring(0, pageName.indexOf("#")) : pageName;
            // noinspection HtmlUnknownTarget
            return new OO.ui.HtmlSnippet(
                '<a href="/wiki/{0}" target="_blank" title="{1} (s’ouvre dans un nouvel onglet)">Page d’aide</a>'
                    .format(encodeURIComponent(pageName), title)
            );
          }
          return "";
        }

        // Defining all tabs.
        var tabs = [
          {
            title: "Langue, type, définition",
            content: function () {
              self._languageFld = new OO.ui.TextInputWidget();
              self._languageBnt = new OO.ui.ButtonWidget({
                label: "Passer à cette langue",
              });
              self._languageBnt.on("click", function () {
                // noinspection JSCheckFunctionSignatures,JSValidateTypes
                onLanguageSelect(self._languageFld.getValue());
              });

              var languageOptions = [];
              for (var i = 0; i < languages.length; i++) {
                var lang = languages[i];

                languageOptions.push(new OO.ui.MenuOptionWidget({
                  data: lang.code,
                  label: lang.name,
                }));
              }
              self._languageSelectFld = new OO.ui.DropdownWidget({
                label: "Choisissez",
                menu: {
                  items: languageOptions,
                },
              });
              self._languageSelectFld.getMenu().on("select", function (e) {
                // noinspection JSCheckFunctionSignatures,JSValidateTypes
                onLanguageSelect(e.getData());
              });

              self._grammarClassSelectFld = new OO.ui.DropdownWidget({
                label: "Choisissez",
              });
              self._grammarClassSelectFld.getMenu().on("select", function (e) {
                // noinspection JSCheckFunctionSignatures
                onClassSelect(e.getData());
              });
              self._gendersFld = new OO.ui.DropdownWidget({
                label: "Choisissez",
              });
              self._numbersFld = new OO.ui.DropdownWidget({
                label: "Choisissez",
              });

              var imageSectionLabel = new OO.ui.HtmlSnippet(
                  'Image &mdash; <a href="https://commons.wikimedia.org/w/index.php?search={0}" '.format(word) +
                  'target="_blank" title="S’ouvre dans un nouvel onglet">Rechercher sur Commons</a>'
              );
              self._imageFld = new OO.ui.TextInputWidget({
                id: "cnm-image-field",
                placeholder: "Nom du fichier",
              });
              self._imageDescriptionFld = new OO.ui.TextInputWidget({
                id: "cnm-image-description-field",
                placeholder: "Légende",
              });

              self._pronunciationFld = new OO.ui.TextInputWidget({
                id: "cnm-pronunciation-field",
              });
              self._pronunciationPnl = new OO.ui.FieldLayout(self._pronunciationFld, {
                align: "inline",
                help: getHelpPageLink("Aide:Prononciation"),
              });

              self._definitionFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
              });

              self._categoriesWidget = new OO.ui.TagMultiselectWidget({
                inputPosition: 'inline',
                allowArbitrary: true,
              });

              return new OO.ui.FieldsetLayout({
                items: [
                  new OO.ui.FieldsetLayout({
                    label: "Langue",
                    items: [
                      new OO.ui.HorizontalLayout({
                        items: [
                          new OO.ui.ActionFieldLayout(self._languageFld, self._languageBnt),
                          new OO.ui.FieldLayout(self._languageSelectFld, {
                            expanded: false,
                          }),
                        ],
                      }),
                    ],
                    help: "Pour passer à une langue indisponible dans le menu déroulant, entrez son code dans le champ ci-dessous.",
                    helpInline: true,
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Informations grammaticales",
                    items: [
                      new OO.ui.HorizontalLayout({
                        items: [
                          new OO.ui.FieldLayout(self._grammarClassSelectFld, {
                            expanded: false,
                          }),
                          new OO.ui.FieldLayout(self._gendersFld, {
                            expanded: false,
                          }),
                          new OO.ui.FieldLayout(self._numbersFld, {
                            expanded: false,
                          }),
                        ],
                      }),
                    ],
                  }),
                  new OO.ui.FieldsetLayout({
                    label: imageSectionLabel,
                    items: [
                      self._imageFld,
                      self._imageDescriptionFld,
                    ],
                    help: "Indiquer seulement le nom de l’image, " +
                        "sans «\u00a0File:\u00a0», «\u00a0Fichier:\u00a0» ni «\u00a0Image:\u00a0».",
                    helpInline: true,
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Prononciation",
                    items: [
                      self._pronunciationPnl,
                    ],
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Définition",
                    items: [
                      new OO.ui.FieldLayout(self._definitionFld, {
                        label: self._createLinks(specialChars, self._definitionFld),
                        align: "inline",
                        help: getHelpPageLink("Aide:Définitions"),
                      }),
                    ],
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Catégories",
                    items: [
                      self._categoriesWidget,
                    ],
                    help: "Indiquer seulement les noms des catégories (sans «\u00a0Catégorie:\u00a0»), " +
                        "en respectant la casse (majuscules/minuscules).",
                    helpInline: true,
                  }),
                ],
              });
            },
          },
          {
            title: "Sections supplémentaires",
            content: function () {
              self._etymologyFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
                autofocus: true,
              });
              var pronSectionLabel = new OO.ui.HtmlSnippet(
                  'Prononciation (section)<span> &mdash; <a id="cnm-commons-audio-link" href="#" ' +
                  'target="_blank" title="S’ouvre dans un nouvel onglet">Rechercher des fichiers audio sur Commons</a></span>'
              );
              self._pronunciationSectionFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
              });
              self._homophonesFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
              });
              self._paronymsFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
              });
              self._referencesFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
              });
              self._bibliographyFld = new OO.ui.MultilineTextInputWidget({
                rows: 4,
              });

              var fields = [];
              for (var i = 0; i < sections.length; i++) {
                var section = sections[i];

                if (!section.hidden) {
                  var field = new OO.ui.MultilineTextInputWidget({
                    rows: 4,
                    columns: 20,
                  });
                  self._otherSectionFields[section.code] = field;
                  fields.push(new OO.ui.FieldLayout(field, {
                    label: section.label,
                    align: "inline",
                    help: getHelpPageLink(section.help),
                  }));
                }
              }

              return new OO.ui.FieldsetLayout({
                items: [
                  new OO.ui.FieldsetLayout({
                    label: "Étymologie",
                    items: [
                      new OO.ui.FieldLayout(self._etymologyFld, {
                        label: self._createLinks(specialChars, self._etymologyFld),
                        align: "inline",
                        help: getHelpPageLink("Aide:Étymologies"),
                      }),
                    ],
                    help: new OO.ui.HtmlSnippet(wikt.page.renderWikicode(
                        "Laisser le champ de texte vide ajoutera le modèle {{M|ébauche-étym}}.",
                        true
                    )),
                    helpInline: true,
                  }),
                  new OO.ui.FieldsetLayout({
                    label: pronSectionLabel,
                    items: [
                      new OO.ui.FieldLayout(self._pronunciationSectionFld, {
                        label: self._createLinks(specialChars, self._pronunciationSectionFld),
                        align: "inline",
                        help: getHelpPageLink("Aide:Prononciation"),
                      }),
                      new OO.ui.FieldLayout(self._homophonesFld, {
                        label: self._createLinks(specialChars, self._homophonesFld, "", "Homophones"),
                        align: "inline",
                        help: getHelpPageLink("Aide:Homophones et paronymes"),
                      }),
                      new OO.ui.FieldLayout(self._paronymsFld, {
                        label: self._createLinks(specialChars, self._paronymsFld, "", "Paronymes"),
                        align: "inline",
                        help: getHelpPageLink("Aide:Homophones et paronymes"),
                      }),
                    ],
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Références",
                    items: [
                      new OO.ui.FieldLayout(self._referencesFld, {
                        label: self._createLinks(specialChars, self._referencesFld),
                        align: "inline",
                        help: getHelpPageLink("Aide:Références#Le_format_développé"),
                      }),
                      new OO.ui.FieldLayout(self._bibliographyFld, {
                        label: self._createLinks(specialChars, self._bibliographyFld, "", "Bibliographie"),
                        align: "inline",
                        help: getHelpPageLink("Aide:Références#Le_format_développé"),
                      }),
                    ],
                    help: new OO.ui.HtmlSnippet(wikt.page.renderWikicode(
                        "La section «&nbsp;Sources&nbsp;» contenant le modèle {{M|Références}} " +
                        "est insérée automatiquement si le modèle {{M|R}}, {{M|RÉF}} ou {{M|réf}} ou la balise <code>&lt;ref></code> " +
                        "sont présentes dans les autres champs.",
                        true
                    )),
                    helpInline: true,
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Autres sections",
                    items: [
                      new OO.ui.HorizontalLayout({
                        items: fields,
                      }),
                    ],
                  }),
                ],
              });
            },
          },
          {
            title: "Options avancées",
            content: function () {
              var otherProjectsFields = [];
              var linksEnabled = false;

              for (var projectCode in self._otherProjects) {
                if (self._otherProjects.hasOwnProperty(projectCode)) {
                  // * DO NOT REMOVE FUNCTION *
                  // This function in necessary to avoid “textFld”
                  // changing value in checkbox.on() after each iteration.
                  (function () {
                    var projectName = self._otherProjects[projectCode].label;
                    var checkbox = new OO.ui.CheckboxInputWidget({
                      value: projectCode,
                      selected: linksEnabled,
                    });
                    var textFld = new OO.ui.TextInputWidget({
                      label: projectName,
                      disabled: !linksEnabled,
                    });

                    checkbox.on("change", function (selected) {
                      textFld.setDisabled(!selected);
                    });

                    self._seeOtherProjectsChk[projectCode] = {
                      "checkbox": checkbox,
                      "textfield": textFld,
                    };

                    otherProjectsFields.push(new OO.ui.ActionFieldLayout(
                        checkbox,
                        textFld,
                        {
                          align: "inline",
                          id: "cnm-sister-project-{0}".format(projectCode),
                          label: new OO.ui.HtmlSnippet('<a href="#" target="_blank">Rechercher</a>'),
                        }
                    ));
                  })();
                }
              }

              self._draftChk = new OO.ui.CheckboxInputWidget();
              self._sortKeyFld = new OO.ui.TextInputWidget();

              return new OO.ui.FieldsetLayout({
                items: [
                  new OO.ui.FieldsetLayout({
                    label: "Liens vers les autres projets",
                    items: otherProjectsFields,
                    help: "Les champs de texte permettent de renseigner des paramètres" +
                        " supplémentaire aux modèles de liens interwiki.",
                    helpInline: true,
                  }),
                  new OO.ui.FieldsetLayout({
                    label: "Autres options",
                    items: [
                      new OO.ui.FieldLayout(self._draftChk, {
                        label: "Ébauche",
                        align: "inline",
                      }),
                      new OO.ui.FieldLayout(self._sortKeyFld, {
                        label: "Clé de tri",
                        help: "Permet de trier les pages dans les catégories.",
                        align: "inline",
                        helpInline: true,
                      }),
                    ],
                  }),
                ],
              });
            },
          },
        ];

        /*
         * Inserting tabs
         */

        var tabsWidget = new OO.ui.IndexLayout({
          expanded: false,
          id: "cnm-tabs-widget",
        });
        for (var i = 0; i < tabs.length; i++) {
          var tab = new wikt.gadgets.creerNouveauMot.Tab("cnm-tab{0}".format(i), {
            label: tabs[i].title,
            expanded: false,
          });
          var content = tabs[i].content();
          tab.$element.append(typeof content === "string" ? content : content.$element);
          tabsWidget.addTabPanels([tab]);
          this._tabs.push(tab);
        }

        /*
         * Constructing GUI
         */

        // TODO afficher le texte quelque part
        // var popup = new OO.ui.PopupWidget({
        //   // $autoCloseIgnore: button.$element,
        //   $content: $("<p>Le code a été inséré dans la boite d’édition ci-dessous. " +
        //       "Vous devriez <strong>vérifier</strong> que le résultat est conforme à vos souhaits, " +
        //       "et en particulier utiliser le bouton «&nbsp;Prévisualer&nbsp;» avant de publier.</p>"),
        //   padded: true,
        //   width: 300,
        //   anchor: false,
        // });

        var toolFactory = new OO.ui.ToolFactory();
        var toolGroupFactory = new OO.ui.ToolGroupFactory();
        var toolbar = new OO.ui.Toolbar(toolFactory, toolGroupFactory, {actions: true});

        /**
         * Adds a custom button to the tool factory.
         * @param toolFactory The tool factory into which the tool will be registered.
         * @param name {string} Button’s name.
         * @param icon {string|null} Buttons’s icon name.
         * @param progressive {boolean} Wether the icon should be marked as progressive.
         * @param title {string} Button’s tooltip text.
         * @param onSelect {function} Callback for when the button is clicked.
         * @param onUpdateState {function?} Callback for when the button changes state (optional).
         * @param displayBothIconAndLabel {boolean} Whether both the icon and label should be displayed.
         */
        function generateButton(toolFactory, name, icon, progressive, title, onSelect, onUpdateState, displayBothIconAndLabel) {
          /** @constructor */
          function CustomTool() {
            CustomTool.super.apply(this, arguments);
          }

          OO.inheritClass(CustomTool, OO.ui.Tool);
          CustomTool.static.name = name;
          CustomTool.static.icon = icon;
          CustomTool.static.title = title;
          if (progressive) {
            CustomTool.static.flags = ["primary", "progressive"];
          }
          CustomTool.static.displayBothIconAndLabel = !!displayBothIconAndLabel;
          CustomTool.prototype.onSelect = onSelect;
          // noinspection JSUnusedGlobalSymbols
          CustomTool.prototype.onUpdateState = onUpdateState || function () {
            this.setActive(false);
          };

          toolFactory.register(CustomTool);
        }

        var hideBtn = "hide";
        generateButton(toolFactory, hideBtn, "eyeClosed", false, "Masquer", function () {
          // noinspection JSCheckFunctionSignatures
          tabsWidget.toggle();
          this.setTitle(tabsWidget.isVisible() ? "Masquer" : "Afficher");
          this.setIcon(tabsWidget.isVisible() ? "eyeClosed" : "eye");
        });

        var helpBtn = "help";
        generateButton(toolFactory, helpBtn, "help", false, "Aide (s’ouvre dans un nouvel onglet)", function () {
          window.open("/wiki/Aide:Gadget-CreerNouveauMot");
        });

        var actionsToolbar = new OO.ui.Toolbar(toolFactory, toolGroupFactory);

        var insertWikicodeBtn = "insert";
        generateButton(toolFactory, insertWikicodeBtn, null, true, "Insérer le code", onInsertWikicode, null, true);

        actionsToolbar.setup([
          {
            type: "bar",
            include: [insertWikicodeBtn],
          },
        ]);

        toolbar.setup([
          {
            type: "bar",
            include: [hideBtn, helpBtn],
          },
        ]);
        toolbar.$actions.append(actionsToolbar.$element);

        var gadgetBox = new OO.ui.PanelLayout({
          expanded: false,
          framed: true,
        });
        var contentFrame = new OO.ui.PanelLayout({
          expanded: false,
        });

        gadgetBox.$element.append(
            toolbar.$element,
            contentFrame.$element.append(tabsWidget.$element)
        );

        toolbar.initialize();
        toolbar.emit("updateState");

        $tedit.html(gadgetBox.$element);

        for (var projectCode in self._otherProjects) {
          if (self._otherProjects.hasOwnProperty(projectCode)) {
            $("#cnm-sister-project-{0} span.oo-ui-actionFieldLayout-button".format(projectCode)).attr("style", "width: 100%");
            $("#cnm-sister-project-{0} span.oo-ui-fieldLayout-field".format(projectCode)).attr("style", "width: 100%");
          }
        }

        // Enforce fonts for pronunciation text input.
        $("#cnm-pronunciation-field > input").attr("style",
            'font-family:' +
            '"Segoe UI","Calibri","DejaVu Sans","Charis SIL","Doulos SIL",' +
            '"Gentium Plus","Gentium","GentiumAlt","Lucida Grande",' +
            '"Arial Unicode MS",sans-serif !important');
      };

      wikt.gadgets.creerNouveauMot.MainGui.prototype = Object.create(wikt.gadgets.creerNouveauMot.Gui.prototype);

      /*
       * Public methods
       */

      /**
       * Selects the tab at the given index.
       * @param index {number} The index.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.selectTab = function (index) {
        this._tabs[index].select();
      };

      /**
       * Selects the given language. All external links are modified appropriatly.
       * If the language is not in the dropdown menu, it is added to it.
       * @param language {wikt.gadgets.creerNouveauMot.Language} The language object.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.selectLanguage = function (language) {
        if (!this._languageSelectFld.getMenu().findItemFromData(language.code)) {
          this._languageSelectFld.getMenu().addItems([new OO.ui.MenuOptionWidget({
            data: language.code,
            label: language.name,
          })], 0);
        }
        this._updateFields(language);
        this._updateSisterProjectsLinks(language);
        var $link = $("#cnm-commons-audio-link");
        var $span = $link.parent();
        var commonsAudioUrl = "#";
        if (language.iso6393Code) {
          commonsAudioUrl = 'https://commons.wikimedia.org/w/index.php?search={0}.wav+incategory:"Lingua+Libre+pronunciation-{1}"'
              .format(this._word.replace(" ", "_"), language.iso6393Code);
          $span.show();
        } else {
          $span.hide();
        }
        $link.attr("href", commonsAudioUrl);
        this._languageSelectFld.getMenu().selectItemByData(language.code);
        this._pronunciationPnl.setLabel(this._formatApi(language.ipaSymbols));
      };

      /**
       * Sets the available genders widget.
       * @param genders {Array<wikt.gadgets.creerNouveauMot.Gender>} The list of genders.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.setAvailableGenders = function (genders) {
        this._setListValues(genders, this._gendersFld);
      };

      /**
       * Sets the available grammatical numbers widget.
       * @param numbers {Array<wikt.gadgets.creerNouveauMot.Number>} The list of grammatical numbers.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.setAvailableNumbers = function (numbers) {
        this._setListValues(numbers, this._numbersFld);
      };

      /*
       * Private methods
       */

      /**
       * Updates all language-related fields.
       * @param language {wikt.gadgets.creerNouveauMot.Language} The selected language.
       * @private
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype._updateFields = function (language) {
        this._grammarClassSelectFld.getMenu().clearItems();
        var grammarItems = language.grammarItems;
        var items = [];

        for (var key in grammarItems) {
          if (grammarItems.hasOwnProperty(key)) {
            var grammarItem = grammarItems[key];
            items.push(new OO.ui.MenuOptionWidget({
              data: key,
              label: new OO.ui.HtmlSnippet(grammarItem.grammaticalClass.label),
            }));
          }
        }

        this._grammarClassSelectFld.getMenu().addItems(items);
        this._grammarClassSelectFld.getMenu().selectItem(items[0]);

        this._pronunciationFld.setDisabled(language.code === "conv");
      };

      /**
       * Updates the link search links to sister projects based on the selected language.
       * @param language {wikt.gadgets.creerNouveauMot.Language} The selected language.
       * @private
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype._updateSisterProjectsLinks = function (language) {
        for (var projectCode in this._otherProjects) {
          if (this._otherProjects.hasOwnProperty(projectCode)) {
            var forLangs = this._otherProjects[projectCode].showOnlyForLangs || [];
            var disabled = forLangs.length !== 0 && !forLangs.includes(language.code);
            var checkbox = this._seeOtherProjectsChk[projectCode]["checkbox"];

            var projectDomain = this._otherProjects[projectCode].urlDomain;
            var urlBase = this._otherProjects[projectCode].urlBase || "w/index.php?search=";

            var $link = $("#cnm-sister-project-{0} a".format(projectCode));
            var url = this._generateProjectLink(projectDomain, urlBase, language.wikimediaCode, this._word);

            checkbox.setDisabled(disabled);
            // Unselect if disabled
            checkbox.setSelected(checkbox.isSelected() && !disabled);
            $link.attr("href", url);
            if (url === "#" || disabled) {
              $link.hide();
            } else {
              $link.show();
            }
          }
        }
      }

      /**
       * Sets the values of the given OOUI dropdown widget.
       * @param values {Array<wikt.gadgets.creerNouveauMot.Gender|wikt.gadgets.creerNouveauMot.Number>} The list of values.
       * @param field {OO.ui.DropdownWidget} The OOUI widget.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype._setListValues = function (values, field) {
        // noinspection JSUnresolvedFunction
        field.getMenu().clearItems();
        var items = [];
        for (var i = 0; i < values.length; i++) {
          var value = values[i];
          items.push(new OO.ui.MenuOptionWidget({
            data: value.label,
            label: new OO.ui.HtmlSnippet(value.label),
          }));
        }
        // noinspection JSUnresolvedFunction
        field.getMenu().addItems(items);
        // noinspection JSUnresolvedFunction
        field.getMenu().selectItem(items[0]);
      };

      /**
       * Creates an HTML list of IPA symbols from a array of symbols.
       * @param ipaSymbols {Array<Array<string>>} The list of IPA symbols.
       * @return {object} A jQuery object.
       * @private
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype._formatApi = function (ipaSymbols) {
        var $label = $("<span>");

        for (var i = 0; i < ipaSymbols.length; i++) {
          $label.append(this._createLinks(ipaSymbols[i], this._pronunciationFld, "API"));
          if (i < ipaSymbols.length - 1) {
            $label.append(" &mdash; ");
          }
        }

        return $label;
      };

      /**
       * Creates an HTML links sequence that will insert text into a text field when clicked.
       * @param list {Array<string>} The list of strings to convert into links.
       * @param textField {object} The text field to insert the text into.
       * @param cssClass {string?} Optional additonnal CSS classes.
       * @param text {string?} Some text that will be appended before the links.
       * @return {Object} A jQuery object.
       * @private
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype._createLinks = function (list, textField, cssClass, text) {
        var $links = $("<span>");

        if (text) {
          $links.append(text + " &mdash; ");
        }

        for (var i = 0; i < list.length; i++) {
          var item = list[i];
          var $link = $('<a href="#" class="{0}" data-value="{1}">{2}</a>'
              .format(cssClass, item.replace("&", "&amp;"), item.trim()));
          // noinspection JSCheckFunctionSignatures
          $link.click(function (e) {
            textField.insertContent($(e.target).data("value"));
            textField.focus();
            // Return false to disable default event from triggering.
            return false;
          });
          $links.append($link);
          if (i < list.length - 1) {
            $links.append("\u00a0");
          }
        }

        return $links;
      };

      /**
       * Generates the URL to the given sister project’s search page.
       * @param projectDomain {string} Project’s domain name.
       * @param urlBase {string} The base URL (usually wiki).
       * @param langCode {string} Project’s domain language code.
       * @param word {string} The word to search for.
       * @return {string} The search URL.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype._generateProjectLink = function (projectDomain, urlBase, langCode, word) {
        if (langCode) {
          projectDomain = projectDomain.format(langCode);
          return "https://{0}/{1}{2}".format(projectDomain, urlBase, encodeURI(word));
        }
        return "#";
      }

      /*
       * Getters & setters
       */

      /**
       * Returns the contents of the given section.
       * @param sectionCode {string} Sections’s code.
       * @return {string} The section’s contents.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.getSectionContent = function (sectionCode) {
        // noinspection JSCheckFunctionSignatures
        return this._otherSectionFields[sectionCode].getValue().trim();
      };

      // noinspection JSUnusedGlobalSymbols
      /**
       * Sets the contents of the given section.
       * @param sectionCode {string} Sections’s code.
       * @param content {string} The section’s contents.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.setSectionContent = function (sectionCode, content) {
        this._otherSectionFields[sectionCode].setValue(content.trim());
      };

      /**
       * Indicates whether a link to the given sister project has to be inserted.
       * @param projectCode {string} Project’s code.
       * @return {boolean} True if a link has to be inserted.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.hasAddLinkToProject = function (projectCode) {
        return this._seeOtherProjectsChk[projectCode]["checkbox"].isSelected();
      };

      /**
       * Sets whether a link to the given sister project has to be inserted.
       * @param projectCode {string} Project’s code.
       * @param link {boolean} True if a link has to be inserted.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.setAddLinkToProject = function (projectCode, link) {
        this._seeOtherProjectsChk[projectCode]["checkbox"].setSelected(link);
      };

      /**
       * Returns the template parameters for the given sister project link.
       * @param projectCode {string} Project’s code.
       * @return {string} Template’s parameters.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.getProjectLinkParams = function (projectCode) {
        // noinspection JSCheckFunctionSignatures
        return this._seeOtherProjectsChk[projectCode]["textfield"].getValue().trim();
      };

      /**
       * Sets template parameters for the given sister project link.
       * @param projectCode {string} Project’s code.
       * @param params {string} Template’s parameters.
       */
      wikt.gadgets.creerNouveauMot.MainGui.prototype.setProjectLinkParams = function (projectCode, params) {
        this._seeOtherProjectsChk[projectCode]["textfield"].setValue(params.trim());
      };

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "tabsNumber", {
        /**
         * @return {number} The number of tabs.
         */
        get: function () {
          return this._tabs.length;
        }
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "selectedLanguage", {
        /**
         * @return {string} Selected language’s code.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._languageSelectFld.getMenu().findSelectedItem().getData();
        }
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "gender", {
        /**
         * @return {string} Selected gender’s code.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._gendersFld.getMenu().findSelectedItem().getData();
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "number", {
        /**
         * @return {string} Selected grammatical number’s code.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._numbersFld.getMenu().findSelectedItem().getData();
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "grammarClass", {
        /**
         * @return {string} Selected grammatical class.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._grammarClassSelectFld.getMenu().findSelectedItem().getData();
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "imageName", {
        /**
         * @return {string} The image name.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._imageFld.getValue().trim();
        },

        /**
         * Sets the image name.
         * @param imageName {string} The image name.
         */
        set: function (imageName) {
          this._imageFld.setValue(imageName.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "imageDescription", {
        /**
         * @return {string} The image description.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._imageDescriptionFld.getValue().trim();
        },

        /**
         * Sets the image description.
         * @param imageDesc {string} The image description.
         */
        set: function (imageDesc) {
          this._imageDescriptionFld.setValue(imageDesc.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "pronunciation", {
        /**
         * @return {string} The pronunciation.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._pronunciationFld.getValue().trim();
        },

        /**
         * Sets the pronunciation.
         * @param pron {string} The pronunciation.
         */
        set: function (pron) {
          this._pronunciationFld.setValue(pron.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "definition", {
        /**
         * @return {string} The definition.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._definitionFld.getValue().trim();
        },

        /**
         * Sets the definition.
         * @param def {string} The definition.
         */
        set: function (def) {
          this._definitionFld.setValue(def.trim());
        }
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "categories", {
        /**
         * @return {Array<string>} The categories.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._categoriesWidget.getValue();
        },

        /**
         * Sets the categories.
         * @param categories {Array<string>} The image categories.
         */
        set: function (categories) {
          this._categoriesWidget.setValue(categories);
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "etymology", {
        /**
         * @return {string} The etymology.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._etymologyFld.getValue().trim();
        },

        /**
         * Sets the etymology.
         * @param etym {string} The etymology.
         */
        set: function (etym) {
          this._etymologyFld.setValue(etym.trim());
        }
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "pronunciationSection", {
        /**
         * @return {string} The pronunciation section.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._pronunciationSectionFld.getValue().trim();
        },

        /**
         * Sets the pronunciation section content.
         * @param pronunciationSection {string} The pronunciation section content.
         */
        set: function (pronunciationSection) {
          this._pronunciationSectionFld.setValue(pronunciationSection.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "homophones", {
        /**
         * @return {string} The homophones.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._homophonesFld.getValue().trim();
        },

        /**
         * Sets the homophones.
         * @param homophones {string} The homophones.
         */
        set: function (homophones) {
          this._homophonesFld.setValue(homophones.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "paronyms", {
        /**
         * @return {string} The paronyms.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._paronymsFld.getValue().trim();
        },

        /**
         * Sets the paronyms.
         * @param paronyms {string} The paronyms.
         */
        set: function (paronyms) {
          this._paronymsFld.setValue(paronyms.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "references", {
        /**
         * @return {string} The references.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._referencesFld.getValue().trim();
        },

        /**
         * Sets the references.
         * @param references {string} The references.
         */
        set: function (references) {
          this._referencesFld.setValue(references.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "bibliography", {
        /**
         * @return {string} The bibliography.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._bibliographyFld.getValue().trim();
        },

        /**
         * Sets the bibliography.
         * @param bibliography {string} The bibliography.
         */
        set: function (bibliography) {
          this._bibliographyFld.setValue(bibliography.trim());
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "isDraft", {
        /**
         * Indicates whether the article is a draft.
         * @return {boolean} True if it is a draft.
         */
        get: function () {
          return this._draftChk.isSelected();
        },

        /**
         * Sets whether the article is a draft.
         * @param draft {boolean} True if it is a draf
         */
        set: function (draft) {
          this._draftChk.setSelected(draft);
        },
      });

      Object.defineProperty(wikt.gadgets.creerNouveauMot.MainGui.prototype, "sortingKey", {
        /**
         * @return {string} The sorting key.
         */
        get: function () {
          // noinspection JSCheckFunctionSignatures
          return this._sortKeyFld.getValue().trim();
        },

        /**
         * Defines the sorting key.
         * @param key {string} The sorting key.
         */
        set: function (key) {
          this._sortKeyFld.setValue(key.trim());
        },
      });

      /**
       * This class represents a grammatical number (singular, plural, etc.).
       * @param label {string} Number’s label.
       * @param template {string?} Number’s template if any.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.Number = function (label, template) {
        this._label = label;
        this._template = template || "";
      }

      // noinspection JSValidateTypes
      wikt.gadgets.creerNouveauMot.Number.prototype = {
        /**
         * @return {string} The label.
         */
        get label() {
          return this._label;
        },

        /**
         * @return {string} The template if any.
         */
        get template() {
          return this._template;
        },
      }

      /**
       * Defines all available grammatical numbers.
       * @type {Object<string, wikt.gadgets.creerNouveauMot.Number>}
       */
      wikt.gadgets.creerNouveauMot.numbers = {
        DIFF_SINGULAR_PLURAL: new wikt.gadgets.creerNouveauMot.Number("sing. et plur. différents"),
        SAME_SINGULAR_PLURAL: new wikt.gadgets.creerNouveauMot.Number("sing. et plur. identiques", "{{sp}}"),
        SINGULAR_ONLY: new wikt.gadgets.creerNouveauMot.Number("singulier uniquement", "{{au singulier uniquement|{0}}}"),
        PLURAL_ONLY: new wikt.gadgets.creerNouveauMot.Number("pluriel uniquement", "{{au pluriel uniquement|{0}}}"),
        INVARIABLE: new wikt.gadgets.creerNouveauMot.Number("invariable", "{{invariable}}"),
      };

      /**
       * This class represents a grammatical gender (feminine, masculine, etc.).
       * @param label {string} Gender’s label.
       * @param template {string?} Gender’s template if any.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.Gender = function (label, template) {
        this._label = label;
        this._template = template || "";
      }

      // noinspection JSValidateTypes
      wikt.gadgets.creerNouveauMot.Gender.prototype = {
        /**
         * @return {string} Gender’s label.
         */
        get label() {
          return this._label;
        },

        /**
         * @return {string} Gender’s template if any.
         */
        get template() {
          return this._template;
        },
      }

      /**
       * Defines all available grammatical genders/verb groups.
       * @type {Object<string, wikt.gadgets.creerNouveauMot.Gender>}
       */
      wikt.gadgets.creerNouveauMot.genders = {
        MASCULINE: new wikt.gadgets.creerNouveauMot.Gender("masculin", "{{m}}"),
        FEMININE: new wikt.gadgets.creerNouveauMot.Gender("féminin", "{{f}}"),
        FEMININE_MASCULINE_DIFF: new wikt.gadgets.creerNouveauMot.Gender("masc. et fém. différents"),
        FEMININE_MASCULINE: new wikt.gadgets.creerNouveauMot.Gender("masc. et fém. identiques", "{{mf}}"),
        NO_GENDER: new wikt.gadgets.creerNouveauMot.Gender("pas de genre"),
        VERB_GROUP1: new wikt.gadgets.creerNouveauMot.Gender("1<sup>er</sup> groupe", "{{type|{0}}} {{conjugaison|fr|groupe=1}}"),
        VERB_GROUP2: new wikt.gadgets.creerNouveauMot.Gender("2<sup>ème</sup> groupe", "{{type|{0}}} {{conjugaison|fr|groupe=2}}"),
        VERB_GROUP3: new wikt.gadgets.creerNouveauMot.Gender("3<sup>ème</sup> groupe", "{{type|{0}}} {{conjugaison|fr|groupe=3}}"),
        VERB: new wikt.gadgets.creerNouveauMot.Gender("verbe", "{{type|{0}}} {{conjugaison|{0}}}"),
        VERB_NO_TEMPLATE: new wikt.gadgets.creerNouveauMot.Gender("verbe", "{{type|{0}}}"),
        REGULAR_VERB: new wikt.gadgets.creerNouveauMot.Gender("régulier", "{{type|{0}}}"),
        IRREGULAR_VERB: new wikt.gadgets.creerNouveauMot.Gender("irrégulier", "{{type|{0}}}"),
      };

      /**
       * This class represents a grammatical class.
       * @param label {string} Class’ label.
       * @param sectionCode {string} Class’ section code.
       * (as defined in [[Wiktionnaire:Structure_des_pages#Résumé_des_sections]] 2,1 onwards).
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.GrammaticalClass = function (label, sectionCode) {
        this._label = label;
        this._sectionCode = sectionCode;
      }

      // noinspection JSValidateTypes
      wikt.gadgets.creerNouveauMot.GrammaticalClass.prototype = {
        /**
         * @return {string} Class’ label.
         */
        get label() {
          return this._label;
        },

        /**
         * @return {string} Class’ section code.
         */
        get sectionCode() {
          return this._sectionCode;
        },
      }

      /**
       * Defines all available grammatical classes.
       * @type {Object<string, wikt.gadgets.creerNouveauMot.GrammaticalClass>}
       */
      wikt.gadgets.creerNouveauMot.grammaticalClasses = {
        SYMBOL: new wikt.gadgets.creerNouveauMot.GrammaticalClass("symbole", "symbole"),
        LETTER: new wikt.gadgets.creerNouveauMot.GrammaticalClass("lettre", "lettre"),

        SCIENTIFIC_NAME: new wikt.gadgets.creerNouveauMot.GrammaticalClass("nom scientifique", "nom scientifique"),

        // Nouns
        NOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("nom commun", "nom"),
        PROPER_NOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("nom propre", "nom propre"),
        FIRST_NAME: new wikt.gadgets.creerNouveauMot.GrammaticalClass("prénom", "prénom"),
        LAST_NAME: new wikt.gadgets.creerNouveauMot.GrammaticalClass("nom de famille", "nom de famille"),

        // Adjectives
        ADJECTIVE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("adjectif", "adjectif"),
        INTERROGATIVE_ADJECTIVE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("adjectif interrogatif", "adjectif interrogatif"),
        NUMERAL_ADJECTIVE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("adjectif numéral", "adjectif numéral"),
        POSSESSIVE_ADJECTIVE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("adjectif possessif", "adjectif possessif"),

        // Adverbs
        ADVERB: new wikt.gadgets.creerNouveauMot.GrammaticalClass("adverbe", "adverbe"),
        INTERROGATIVE_ADVERB: new wikt.gadgets.creerNouveauMot.GrammaticalClass("adverbe interrogatif", "adverbe interrogatif"),

        // Pronouns
        PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom", "pronom"),
        DEMONSTRATIVE_PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom démonstratif", "pronom démonstratif"),
        INDEFINITE_PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom indéfini", "pronom indéfini"),
        INTERROGATIVE_PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom interrogatif", "pronom interrogatif"),
        PERSONAL_PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom personnel", "pronom personnel"),
        POSSESSIVE_PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom possessif", "pronom possessif"),
        RELATIVE_PRONOUN: new wikt.gadgets.creerNouveauMot.GrammaticalClass("pronom relatif", "pronom relatif"),

        // Conjunctions
        CONJUNCTION: new wikt.gadgets.creerNouveauMot.GrammaticalClass("conjonction", "conjonction"),
        COORDINATION_CONJUNCTION: new wikt.gadgets.creerNouveauMot.GrammaticalClass("conjonction de coordination", "conjonction de coordination"),

        // Articles
        ARTICLE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("article", "article"),
        INDEFINITE_ARTICLE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("article indéfini", "article indéfini"),
        DEFINITE_ARTICLE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("article défini", "article défini"),
        PARTITIVE_ARTICLE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("article partitif", "article partitif"),

        // Affixes
        PREFIX: new wikt.gadgets.creerNouveauMot.GrammaticalClass("préfixe", "préfixe"),
        SUFFIX: new wikt.gadgets.creerNouveauMot.GrammaticalClass("suffixe", "suffixe"),
        CIRCUMFIX: new wikt.gadgets.creerNouveauMot.GrammaticalClass("circonfixe", "circonfixe"),
        INFIX: new wikt.gadgets.creerNouveauMot.GrammaticalClass("infixe", "infixe"),

        VERB: new wikt.gadgets.creerNouveauMot.GrammaticalClass("verbe", "verbe"),
        PREPOSITION: new wikt.gadgets.creerNouveauMot.GrammaticalClass("préposition", "préposition"),
        POSTPOSITION: new wikt.gadgets.creerNouveauMot.GrammaticalClass("postposition", "postposition"),
        PARTICLE: new wikt.gadgets.creerNouveauMot.GrammaticalClass("particule", "particule"),
        INTERJECTION: new wikt.gadgets.creerNouveauMot.GrammaticalClass("interjection", "interjection"),
      };

      /**
       * A grammatical item associates a grammatical class to genders and numbers.
       * @param grammaticalClass {wikt.gadgets.creerNouveauMot.GrammaticalClass} The grammatical class.
       * @param availableGenders {Array<wikt.gadgets.creerNouveauMot.Gender>?} Associated genders.
       * @param availableNumbers {Array<wikt.gadgets.creerNouveauMot.Number>?} Associated numbers.
       * @param generateInflections {Function?} Optional function that generates inflections template.
       * @constructor
       */
      wikt.gadgets.creerNouveauMot.GrammaticalItem = function (grammaticalClass, availableGenders, availableNumbers, generateInflections) {
        this._grammaticalClass = grammaticalClass;
        /** @type {Array<wikt.gadgets.creerNouveauMot.Gender>} */
        this._availableGenders = availableGenders || [new wikt.gadgets.creerNouveauMot.Gender("<em>indisponible</em>")];
        /** @type {Array<wikt.gadgets.creerNouveauMot.Number>} */
        this._availableNumbers = availableNumbers || [new wikt.gadgets.creerNouveauMot.Number("<em>indisponible</em>")];
        this._generateInflections = generateInflections || function () {
          return "";
        };
      };

      // noinspection JSValidateTypes
      wikt.gadgets.creerNouveauMot.GrammaticalItem.prototype = {
        /**
         * @return {wikt.gadgets.creerNouveauMot.GrammaticalClass} The grammatical class.
         */
        get grammaticalClass() {
          return this._grammaticalClass;
        },

        /**
         * @return {Array<wikt.gadgets.creerNouveauMot.Gender>} Associated genders.
         */
        get availableGenders() {
          return this._availableGenders;
        },

        /**
         * @return {Array<wikt.gadgets.creerNouveauMot.Number>} Associated numbers.
         */
        get availableNumbers() {
          return this._availableNumbers;
        },
      };

      /**
       * Fetches the gender with the given label.
       * @param genderLabel {string} Gender’s label.
       * @return {wikt.gadgets.creerNouveauMot.Gender|null} The gender object or null if none were found.
       */
      wikt.gadgets.creerNouveauMot.GrammaticalItem.prototype.getGender = function (genderLabel) {
        for (var i = 0; i < this._availableGenders.length; i++) {
          var gender = this._availableGenders[i];
          if (gender.label === genderLabel) {
            return gender;
          }
        }

        return null;
      };

      /**
       * Fetches the number with the given label.
       * @param numberLabel {string} Number’s label
       * @return {wikt.gadgets.creerNouveauMot.Number|null} The number object or null if none were found.
       */
      wikt.gadgets.creerNouveauMot.GrammaticalItem.prototype.getNumber = function (numberLabel) {
        for (var i = 0; i < this._availableNumbers.length; i++) {
          var number = this._availableNumbers[i];
          if (number.label === numberLabel) {
            return number;
          }
        }

        return null;
      };

      /**
       * Generates inflections template.
       * @param word {string} The base word.
       * @param genderLabel {string} Gender’s label.
       * @param numberLabel {string} Number’s label.
       * @param pronunciation {string} IPA pronunciation.
       * @return {string} Template’s wikicode.
       */
      wikt.gadgets.creerNouveauMot.GrammaticalItem.prototype.getInflectionsTemplate = function (word, genderLabel, numberLabel, pronunciation) {
        var grammarClass = this._grammaticalClass.label;
        grammarClass = grammarClass.charAt(0).toUpperCase() + grammarClass.substring(1);
        return this._generateInflections(word, grammarClass, genderLabel, numberLabel, pronunciation);
      };

      var namespaceId = mw.config.get("wgNamespaceIds")["mediawiki"];
      var basePage = "Gadget-CreerNouveauMot.js";

      wikt.page.getSubpages(namespaceId, basePage, "[a-zA-Z]*\\.js", function (response) {
        var modules = $.map(response.query.search, function (e) {
          return "https://fr.wiktionary.org/wiki/{0}?action=raw&ctype=text/javascript".format(e.title);
        });
        wikt.loadScripts(modules).done(function () {
          wikt.gadgets.creerNouveauMot.init();
        });
      });
    });
  }
});
