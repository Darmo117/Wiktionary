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
 * v5.1.2 2021-06-15 Merged language definitions into main file
 * v5.1.3 2021-06-28 Moved dependencies to [[MediaWiki:Gadgets-definition]]
 * v5.2 2021-07-07 Non-predefined languages now show actual name instead of code if
 *                 defined in [[MediaWiki:Gadget-translation editor.js/langues.json]].
 *                 Clearer indication of currently selected language.
 *                 Not using wikt.gadgets object that was causing bugs.
 * v5.3 2021-07-07 Prevent code from being inserted if definition field is empty.
 *                 Word type, gender and number are not selected by default anymore
 *                 (except if there is only one choice).
 * v5.4 2022-11-26 Separate fields for each definition and their associated examples.
 * v5.4.1 2022-11-28 Convert to ES6.
 * ------------------------------------------------------------------------------------
 * [[Catégorie:JavaScript du Wiktionnaire|CreerNouveauMot-dev.js]]
 * <nowiki>
 */

$(function () {
  // Activate only in main namespace when in edit/submit mode.
  if (wikt.page.hasNamespaceIn([""]) && ["edit", "submit"].includes(mw.config.get("wgAction"))) {
    console.log("Chargement de Gadget-CreerNouveauMot-dev.js…");
    console.log("yap"); // DEBUG

    /**
     * Wrapper object for a single definition and its examples.
     */
    class Definition {
      /**
       * @param definition {string} The definition.
       * @param examples {Example[]} The examples.
       */
      constructor(definition, examples) {
        this.definition = definition;
        this.examples = examples;
      }
    }

    /**
     * An definition example features some text, a translation, a transcription and a language.
     */
    class Example {
      /**
       * @param text {string} Example’s text.
       * @param translation {string|null} Example’s translation.
       * @param transcription {string|null} Example’s transcription.
       * @param source {string|null} Example’s source.
       */
      constructor(text, translation, transcription, source) {
        this.text = text;
        this.translation = translation;
        this.transcription = transcription;
        this.source = source;
      }
    }

    // TODO refactor GNumber & GGender
    /**
     * This class represents a grammatical number (singular, plural, etc.).
     */
    class GrammaticalNumber {
      /** @type {string} */
      #label;
      /** @type {string} */
      #template;

      /**
       * @param label {string} Number’s label.
       * @param template {string?} Number’s template if any.
       */
      constructor(label, template) {
        this.#label = label;
        this.#template = template || "";
      }

      /**
       * @return {string} The label.
       */
      get label() {
        return this.#label;
      }

      /**
       * @return {string} The template if any.
       */
      get template() {
        return this.#template;
      }
    }

    /**
     * This class represents a grammatical gender (feminine, masculine, etc.).
     */
    class GrammaticalGender {
      /** @type {string} */
      #label;
      /** @type {string} */
      #template;

      /**
       * @param label {string} Gender’s label.
       * @param template {string?} Gender’s template if any.
       */
      constructor(label, template) {
        this.#label = label;
        this.#template = template || "";
      }

      /**
       * @return {string} Gender’s label.
       */
      get label() {
        return this.#label;
      }

      /**
       * @return {string} Gender’s template if any.
       */
      get template() {
        return this.#template;
      }
    }

    /**
     * This class represents a grammatical class.
     */
    class GrammaticalClass {
      /** @type {string} */
      #label;
      /** @type {string} */
      #sectionCode;

      /**
       * @param label {string} Class’ label.
       * @param sectionCode {string} Class’ section code.
       * (as defined in [[Wiktionnaire:Structure_des_pages#Résumé_des_sections]] 2,1 onwards).
       */
      constructor(label, sectionCode) {
        this.#label = label;
        this.#sectionCode = sectionCode;
      }

      /**
       * @return {string} Class’ label.
       */
      get label() {
        return this.#label;
      }

      /**
       * @return {string} Class’ section code.
       */
      get sectionCode() {
        return this.#sectionCode;
      }
    }

    /**
     * A grammatical item associates a grammatical class to genders and numbers.
     */
    class GrammaticalItem {
      /** @type {GrammaticalClass} */
      #grammaticalClass;
      /** @type {GrammaticalGender[]} */
      #availableGenders;
      /** @type {GrammaticalNumber[]} */
      #availableNumbers;
      /** @type {Function} */
      #generateInflections;

      /**
       * @param grammaticalClass {GrammaticalClass} The grammatical class.
       * @param availableGenders {GrammaticalGender[]?} Associated genders.
       * @param availableNumbers {GrammaticalNumber[]?} Associated numbers.
       * @param generateInflections {Function?} Optional function that generates inflections template.
       */
      constructor(grammaticalClass, availableGenders, availableNumbers, generateInflections) {
        this.#grammaticalClass = grammaticalClass;
        this.#availableGenders = availableGenders || [];
        this.#availableNumbers = availableNumbers || [];
        this.#generateInflections = generateInflections || (() => "");
      }

      /**
       * @return {GrammaticalClass} The grammatical class.
       */
      get grammaticalClass() {
        return this.#grammaticalClass;
      }

      /**
       * @return {GrammaticalGender[]} Associated genders.
       */
      get availableGenders() {
        return this.#availableGenders;
      }

      /**
       * @return {GrammaticalNumber[]} Associated numbers.
       */
      get availableNumbers() {
        return this.#availableNumbers;
      }

      /**
       * Fetches the gender with the given label.
       * @param genderLabel {string} Gender’s label.
       * @return {GrammaticalGender|null} The gender object or null if none were found.
       */
      getGender(genderLabel) {
        for (const gender of this.#availableGenders) {
          if (gender.label === genderLabel) {
            return gender;
          }
        }
        return null;
      }

      /**
       * Fetches the number with the given label.
       * @param numberLabel {string} Number’s label
       * @return {GrammaticalNumber|null} The number object or null if none were found.
       */
      getNumber(numberLabel) {
        for (const number of this.#availableNumbers) {
          if (number.label === numberLabel) {
            return number;
          }
        }
        return null;
      }

      /**
       * Generates the inflections template.
       * @param word {string} The base word.
       * @param genderLabel {string} Gender’s label.
       * @param numberLabel {string} Number’s label.
       * @param pronunciation {string} IPA pronunciation.
       * @return {string} Template’s wikicode.
       */
      getInflectionsTemplate(word, genderLabel, numberLabel, pronunciation) {
        let grammarClass = this.#grammaticalClass.label;
        grammarClass = grammarClass.charAt(0).toUpperCase() + grammarClass.substring(1);
        return this.#generateInflections(word, grammarClass, genderLabel, numberLabel, pronunciation);
      }
    }

    /**
     * This class encapsulates data and behaviors specific to a specific language.
     */
    class Language {
      /** @type {string} */
      #code;
      /** @type {string} */
      #wikimediaCode;
      /** @type {string} */
      #iso6393Code;
      /** @type {string} */
      #name;
      /** @type {string[][]} */
      #ipaSymbols;
      /** @type {Object<string, GrammaticalItem>} */
      #grammarItems = {};
      /** @type {function} */
      #pronGenerator;

      /**
       * @param code {string} Language code defined in [[Module:langues/data]].
       * @param wikimediaCode {string|null} Language code used by WikiMedia projects.
       * @param iso6393Code {string|null} ISO 639-3 language code.
       * @param name {string} Language’s name (in French).
       * @param ipaSymbols {string[][]?} An optional list of common IPA symbols for the language.
       * @param grammarItems {GrammaticalItem[]?} An optional list of grammatical items.
       * @param pronGenerator {function?} An optional function that generates an approximate pronunciation based on the word.
       */
      constructor(code, wikimediaCode, iso6393Code, name, ipaSymbols, grammarItems, pronGenerator) {
        this.#code = code;
        this.#wikimediaCode = wikimediaCode;
        this.#iso6393Code = iso6393Code;
        this.#name = name;
        this.#ipaSymbols = ipaSymbols || [];
        this.#pronGenerator = pronGenerator || (() => "");
        for (const grammarItem of (grammarItems || [])) {
          this.#grammarItems[grammarItem.grammaticalClass.sectionCode] = grammarItem;
        }
      }

      /**
       * @return {string} This language’s code.
       */
      get code() {
        return this.#code;
      }

      /**
       * @return {string} This language’s WikiMedia code.
       */
      get wikimediaCode() {
        return this.#wikimediaCode;
      }

      /**
       * @return {string} This language’s ISO 639-3 code.
       */
      get iso6393Code() {
        return this.#iso6393Code;
      }

      /**
       * @return {string} This language’s name.
       */
      get name() {
        return this.#name;
      }

      /**
       * @return {string[][]} The IPA symbols for this language.
       */
      get ipaSymbols() {
        return this.#ipaSymbols;
      }

      /**
       * @return {Object<string, GrammaticalItem>} The grammatical items for this language.
       */
      get grammarItems() {
        return this.#grammarItems;
      }

      /**
       * Fetches the grammatical item that has the given section title.
       * @param sectionName {string} Section’s title.
       * @return {GrammaticalItem} The grammatical item if found or undefined otherwise.
       */
      getGrammarItem(sectionName) {
        return this.#grammarItems[sectionName];
      }

      /**
       * Generates the pronunciation of the given word for this language.
       * @param word {string} The word.
       * @return {string} The pronunciation or an empty string if no function was defined in the constructor.
       */
      generatePronunciation(word) {
        return this.#pronGenerator(word);
      }
    }

    // TODO convert to ES6 class
    window.gadget_creerNouveauMot = {
      NAME: "Créer nouveau mot",

      VERSION: "5.4.1",

      _COOKIE_NAME: "cnm_last_lang",
      /** Cookie duration in days. */
      _COOKIE_DURATION: 30,

      /**
       * List of sister projects and associated templates and domain names.
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
       * Language span tag in gadget’s title.
       * @type {Object}
       * @private
       */
      _$TITLE_LANG: null,

      /**
       * Main word.
       * @type {string}
       * @private
       */
      _word: mw.config.get("wgTitle").replace("_", " "),

      /**
       * Currently selected language.
       * @type {Language}
       * @private
       */
      _selectedLanguage: null,

      /**
       * List of available languages.
       * @type {Language[]}
       * @private
       */
      _languages: [],

      /**
       * Object mapping language codes to their respective names.
       * @type {Object<string, string>}
       * @private
       */
      _languageNames: {},

      /**
       * Start up GUI.
       * @type {gadget_creerNouveauMot.StartGui}
       * @private
       */
      _startGui: null,

      /**
       * Main GUI.
       * @type {gadget_creerNouveauMot.MainGui}
       * @private
       */
      _gui: null,

      /**
       * API hook.
       * @type {mw.Api}
       * @private
       */
      _api: new mw.Api(),

      /*
       * Public functions
       */

      /**
       * Initializes this gadget.
       */
      init: function () {
        // Sorting languages: french first,
        // then all remaining in lexicographical order.
        this._languages.sort((a, b) => {
          if (a.code === "fr") {
            return -1;
          } else if (b.code === "fr") {
            return 1;
          } else {
            return a.name.localeCompare(b.name);
          }
        });

        this._api.get({
          action: "query",
          format: "json",
          titles: "MediaWiki:Gadget-translation editor.js/langues.json",
          prop: "revisions",
          rvprop: "content",
          rvslots: "main",
        }).then(data => {
          for (const page of Object.values(data.query.pages)) { // Get first entry
            // noinspection JSUnresolvedVariable
            this._languageNames = JSON.parse(page.revisions[0].slots.main["*"]);
          }
          if ($(this.Gui.prototype.TARGET_ELEMENT)) {
            this._generateStartUi();
          }
        });
      },

      /**
       * Adds a language to the list of available languages.
       * @param language {Language} The language to add.
       */
      addLanguage: function (language) {
        this._languages.push(language);
      },

      /**
       * Fecthes the language with the given code.
       * @param languageCode {string} Language code.
       * @returns {Language|null} The language object or null if none were found.
       */
      getLanguage: function (languageCode) {
        for (const lang of this._languages) {
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
        this._startGui.remove();
        this._startGui = null;
        const $title = $('<h1 id="cnm-title">Ajout d’un mot en <span id="cnm-title-lang">…</span></h1>');
        $(this.Gui.prototype.TARGET_ELEMENT).append($title);
        this._$TITLE_LANG = $("#cnm-title-lang");

        this._gui = new this.MainGui(
            this._word,
            this._languages,
            this._SECTIONS,
            this._onLanguageSelect.bind(this),
            this._onClassSelect.bind(this),
            this._insertWikicode.bind(this),
            this._OTHER_PROJECTS
        );

        const previousLang = wikt.cookie.read(this._COOKIE_NAME);
        this._onLanguageSelect(previousLang || this._languages[0].code);
        this._gui.sortingKey = wikt.page.getSortingKey(this._word);
        this._gui.isDraft = false;
        // Display alert if the page does not exist yet and its title starts with an upper case letter
        if (this._word && this._word[0].toUpperCase() === this._word[0] && $(".mw-newarticletext").length) {
          alert("Êtes-vous certain·e que la majuscule fait partie du mot\u00a0?\n" +
              "Si tel n’est pas le cas, merci de corriger cela.");
        }
      },

      /**
       * Generates the wikicode then inserts it into the edit box.
       * @private
       */
      _insertWikicode: function () {
        const word = this._word;
        const langCode = this._selectedLanguage.code;
        const isDraft = this._gui.isDraft;
        const pron = this._gui.pronunciation;
        const isConv = langCode === "conv";
        let etymology = this._gui.etymology || `: {{date|lang=${langCode}}} {{ébauche-étym|${langCode}}}`;

        if (!this._gui.grammarClass) {
          alert("Veuillez sélectionner une classe grammaticale (adjectif, nom, etc.).");
          return;
        }
        if (!this._gui.gender) {
          alert("Veuillez sélectionner un genre grammatical (masculin, féminin, etc.).");
          return;
        }
        if (!this._gui.number) {
          alert("Veuillez sélectionner un nombre grammatical (singulier, pluriel, etc.).");
          return;
        }
        const grammarItem = this._selectedLanguage.getGrammarItem(this._gui.grammarClass);
        const gender = grammarItem.getGender(this._gui.gender) || new GrammaticalGender("");
        const number = grammarItem.getNumber(this._gui.number) || new GrammaticalNumber("");
        const grammarClass = grammarItem.grammaticalClass;
        const inflectionsTemplate = grammarItem.getInflectionsTemplate(word, gender.label, number.label, pron);
        const imageName = this._gui.imageName;
        const imageDescription = this._gui.imageDescription;

        if (!this._gui.definitions_number) {
          alert("Définition manquante\u00a0! Veuillez en renseigner au moins une avant de charger le wikicode.");
          return;
        }

        let definitions = [];
        for (let i = 0; i < this._gui.definitions_number; i++) {
          definitions.push(this._gui.getDefinition(i))
        }

        const references = this._gui.references;
        const bibliography = this._gui.bibliography;
        const sortingKey = this._gui.sortingKey;

        // Add : at the beginning of each line
        etymology = etymology.replace(/(^|\n)(?!:)/g, "$1: ");

        let wikicode = `== {{langue|${langCode}}} ==\n`
            + (isDraft ? `{{ébauche|${langCode}}}\n` : "")
            + "=== {{S|étymologie}} ===\n"
            + etymology + "\n\n"
            + `=== {{S|${grammarClass.sectionCode}|${langCode}}} ===\n`
            + (inflectionsTemplate ? inflectionsTemplate + "\n" : "");
        if (imageName) {
          wikicode += `[[Image:${imageName}|vignette|${imageDescription}]]\n`;
        }
        wikicode += `'''${word}'''`;
        if (isConv) {
          wikicode += "\n";
        } else {
          // trim() to remove trailing space(s) if no gender or number template.
          wikicode += " " + `{{pron|${pron}|${langCode}}} ${gender.template.format(langCode)} ${number.template.format(langCode)}`
              .replace(/\s+/g, " ").trim() + "\n";
        }

        /**
         * @param example {Example}
         * @return {string}
         */
        function formatExample(example) {
          var template = "#* {{exemple|" + example.text;
          if (example.translation) {
            template += "|" + example.translation;
          }
          if (example.transcription) {
            template += "|tr=" + example.transcription;
          }
          if (example.source) {
            template += "|source=" + example.source;
          }
          return template + `|lang=${langCode}}}`;
        }

        for (const [i, definition] of definitions.entries()) {
          if (!definition.definition) {
            let message = `Définition n°${i + 1} vide\u00a0! Veuillez la renseigner `;
            if (i > 0) {
              message += "ou la supprimer ";
            }
            message += "avant de charger le wikicode.";
            alert(message);
            return;
          }
          wikicode += `# ${definition.definition}\n`;
          for (const [j, example] of definition.examples.entries()) {
            if (!example.text) {
              alert(`Exemple n°${j + 1} vide pour la définition ${i + 1}\u00a0!`
                  + " Veuillez le renseigner ou supprimer l’exemple avant d’insérer le wikicode.");
              return;
            }
            wikicode += formatExample(example) + "\n";
          }
          if (!definition.examples.length) {
            wikicode += formatExample(new Example("", null, null, null)) + "\n";
          }
        }
        wikicode += "\n"

        function linkify(content) {
          const lines = content.split("\n");

          for (const [i, line] of lines.entries()) {
            if (/^[^=#:;\[{\s][^\s]*/.test(line)) {
              lines[i] = `* {{lien|${line.trim()}|${langCode}}}`;
            } else if (/^\*\s*[^\s]+/.test(line)) {
              lines[i] = `* {{lien|${line.substring(1).trim()}|${langCode}}}`;
            }
          }

          return lines.join("\n").trim();
        }

        let anagramsSection = "";

        for (const section of this._SECTIONS) {
          const sectionCode = section.code;
          const sectionLevel = section.level;

          if (sectionCode !== "traductions" || langCode === "fr") {
            const content = sectionCode !== "traductions"
                ? this._gui.getSectionContent(sectionCode)
                : "{{trad-début}}\n{{trad-fin}}\n\n";

            if (content) {
              const upperSection = section.section;
              let temp = "";

              if (upperSection && !wikicode.includes("S|" + upperSection)) {
                let titleLevel = Array(sectionLevel).join("=");
                temp += `${titleLevel} {{S|${upperSection}}} ${titleLevel}\n`;
              }
              let titleLevel = Array(sectionLevel + 1).join("=");
              temp += `${titleLevel} {{S|${sectionCode}}} ${titleLevel}\n${linkify(content)}\n\n`;

              if (sectionCode === "anagrammes") {
                anagramsSection = temp;
              } else {
                wikicode += temp;
              }
            }
          }
        }

        let pronSection = "";
        const pronunciationContent = this._gui.pronunciationSection || `{{ébauche-pron-audio|${langCode}}}`;
        const homophones = this._gui.homophones;
        const paronyms = this._gui.paronyms;

        if (pronunciationContent || homophones || paronyms) {
          pronSection = "=== {{S|prononciation}} ===\n";
          if (pronunciationContent) {
            pronSection += pronunciationContent + "\n\n";
          }
          if (homophones) {
            pronSection += `==== {{S|homophones|${langCode}}} ====\n${linkify(homophones)}\n\n`;
          }
          if (paronyms) {
            pronSection += `==== {{S|paronymes}} ====\n${linkify(paronyms)}\n\n`;
          }
        }
        wikicode += pronSection;

        wikicode += anagramsSection;

        let seeAlsoSection = "";
        for (const [projectCode, projectData] of Object.entries(this._OTHER_PROJECTS)) {
          if (this._gui.hasAddLinkToProject(projectCode)) {
            let projectModelParams = this._gui.getProjectLinkParams(projectCode);
            projectModelParams = projectModelParams ? "|" + projectModelParams : "";
            const templateName = projectData.templateName;
            if (seeAlsoSection === "") {
              seeAlsoSection = "=== {{S|voir aussi}} ===\n";
            }
            const langParam = projectData.urlDomain.includes("{0}") ? "|lang=" + langCode : "";
            seeAlsoSection += `* {{${templateName}${projectModelParams}${langParam}}}\n`;
          }
        }
        if (seeAlsoSection) {
          seeAlsoSection += "\n";
        }
        wikicode += seeAlsoSection;

        const containsRefTemplates = /{{(R|RÉF|réf)\||<ref>.+<\/ref>/gm.test(wikicode);

        if (containsRefTemplates || references || bibliography) {
          const insertSourcesSection = containsRefTemplates;

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
            wikicode += `==== {{S|bibliographie}} ====\n${bibliography}\n\n`;
          }
        }

        wikicode += sortingKey !== word ? `{{clé de tri|${sortingKey}}}\n` : "";

        this._gui.categories.forEach(category => wikicode += `[[Catégorie:${category}]]\n`);

        wikt.edit.insertText(wikt.edit.getCursorLocation(), wikicode);

        const $summaryFld = wikt.edit.getEditSummaryField();
        const summary = $summaryFld.val();
        const comment = this._editComment();
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

        if (languageCode) {
          let language = this.getLanguage(languageCode);

          if (!language) {
            const languageName = this._languageNames[languageCode];
            if (!languageName) {
              alert("Code de langue invalide\u00a0!");
              return;
            }
            // TODO ajouter tous les types de mots
            language = new Language(languageCode, null, null, this._languageNames[languageCode], [], [
              new GrammaticalItem(this.grammaticalClasses.ADJECTIVE),
              new GrammaticalItem(this.grammaticalClasses.ADVERB),
              new GrammaticalItem(this.grammaticalClasses.NOUN),
              new GrammaticalItem(this.grammaticalClasses.VERB),
              new GrammaticalItem(this.grammaticalClasses.PRONOUN),
              new GrammaticalItem(this.grammaticalClasses.PROPER_NOUN),
              new GrammaticalItem(this.grammaticalClasses.INTERJECTION),
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
        if (className) {
          const grammarItem = this._selectedLanguage.getGrammarItem(className);
          this._gui.setAvailableGenders(grammarItem.availableGenders);
          this._gui.setAvailableNumbers(grammarItem.availableNumbers);
        } else {
          this._gui.setAvailableGenders([]);
          this._gui.setAvailableNumbers([]);
        }
      },

      /**
       * Returns the edit comment.
       * It is a function and not an attribute as “this.VERSION” would not be defined yet.
       * @return {string}
       * @private
       */
      _editComment: function () {
        return `Ajout d’un mot assisté par [[Aide:Gadget-CreerNouveauMot-dev|${this.NAME}]] (v${this.VERSION})`;
      },
    };

    /**
     * Wrapper class for OO.ui.TabPanelLayout.
     * @param name {string} Tab’s name.
     * @param options {Object} OOUI tab’s options.
     * @constructor
     */
    gadget_creerNouveauMot.Tab = function (name, options) {
      OO.ui.TabPanelLayout.call(this, name, options);
    };

    // Inherit from OOUI TabPanelLayout’s prototype.
    gadget_creerNouveauMot.Tab.prototype = Object.create(OO.ui.TabPanelLayout.prototype);

    /**
     * Sets this tab as active.
     */
    gadget_creerNouveauMot.Tab.prototype.select = function () {
      // noinspection JSUnresolvedFunction
      this.setActive(true);
    };

    /**
     * Base class for GUIs.
     * @constructor
     */
    gadget_creerNouveauMot.Gui = function () {
    };

    // noinspection JSValidateTypes
    gadget_creerNouveauMot.Gui.prototype = {
      /** jQuery selector of the HTML element GUIs will be inserted into. */
      TARGET_ELEMENT: "#Editnotice-0",
    }

    /**
     * Inherits from gadget_creerNouveauMot.Gui.
     * @param gadgetName {string}
     * @param onActivateGadget {function}
     * @constructor
     */
    gadget_creerNouveauMot.StartGui = function (gadgetName, onActivateGadget) {
      gadget_creerNouveauMot.Gui.call(this);
      const $target = $(this.TARGET_ELEMENT);
      const headerText = `
<div class="center" style="margin-bottom: 5px">
  <span id="${this.ELEMENT_ID}" class="mw-ui-button mw-ui-progressive">Ouvrir le gadget ${gadgetName}</span>
</div>`.trim();
      $target.append(headerText);
      $target.find("#" + this.ELEMENT_ID).on("click", onActivateGadget);
    };

    // Inherit from gadget Gui’s prototype.
    gadget_creerNouveauMot.StartGui.prototype = Object.create(gadget_creerNouveauMot.Gui.prototype);

    gadget_creerNouveauMot.StartGui.prototype.ELEMENT_ID = "cnm-open-ui";

    gadget_creerNouveauMot.StartGui.prototype.remove = function () {
      $("#" + this.ELEMENT_ID).remove();
    }

    /**
     * Inherits from gadget_creerNouveauMot.Gui.
     * @param word {string} The word.
     * @param languages {Language[]} The language.
     * @param sections {Object<string, string>[]} The list of word type sub-sections.
     * @param onLanguageSelect {Function<string|null, void>} Callback function for when a language is selected.
     * @param onClassSelect {Function} Callback function for when a grammatical class is selected.
     * @param onInsertWikicode {Function} Callback function for when “insert wikicode” button is clicked.
     * @param otherProjects {Object<string, string>} Object containing data for sister projects.
     * @constructor
     */
    gadget_creerNouveauMot.MainGui = function (word, languages, sections, onLanguageSelect, onClassSelect, onInsertWikicode, otherProjects) {
      gadget_creerNouveauMot.Gui.call(this);

      this._word = word;
      /**
       * Tabs list.
       * @type {gadget_creerNouveauMot.Tab[]}
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
      this._definitionFlds = [];
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

      const $tedit = $(this.TARGET_ELEMENT);


      // Alias to avoid confusion inside nested functions.
      const self = this;

      const specialChars = "’àÀâÂæÆçÇéÉèÈêÊëËîÎïÏôÔœŒùÙûÛüÜÿŸ".split("");
      specialChars.push("«\u00a0");
      specialChars.push("\u00a0»");

      /**
       * Returns the help link for the given help page name.
       * @param pageName {string} The page name.
       * @return {OO.ui.HtmlSnippet|string} The HtmlSnippet object
       * for the link or an empty string if the argument evaluates to false.
       */
      function getHelpPageLink(pageName) {
        if (pageName) {
          const title = pageName.includes("#") ? pageName.substring(0, pageName.indexOf("#")) : pageName;
          // noinspection HtmlUnknownTarget
          return new OO.ui.HtmlSnippet(
              `<a href="/wiki/${encodeURIComponent(pageName)}" target="_blank" title="${title} (s’ouvre dans un nouvel onglet)">Page d’aide</a>`
          );
        }
        return "";
      }

      /**
       * Create a definition form.
       * @param definitionID ID of the definition.
       * @constructor
       */
      function DefinitionForm(definitionID) {
        this._definitionFld = new OO.ui.TextInputWidget();
        this._examplesFlds = [];
        this._addExampleBtn = new OO.ui.ButtonWidget({
          label: "Ajouter un exemple",
        });
        this._addExampleBtn.on("click", () => this.addExample());
        this._removeExampleBtn = new OO.ui.ButtonWidget({
          label: "Retirer le dernier exemple",
        });
        this._removeExampleBtn.on("click", () => this.removeExample(this.examples_number - 1));
        this._removeExampleBtn.toggle(false); // Hide by default

        OO.ui.FieldsetLayout.call(this, {
          label: "Définition n°" + definitionID,
          items: [
            new OO.ui.FieldLayout(this._definitionFld, {
              label: self._createLinks(specialChars, this._definitionFld),
              align: "inline",
              help: getHelpPageLink("Aide:Définitions"),
            }),
            new OO.ui.HorizontalLayout({
              items: [
                this._addExampleBtn,
                this._removeExampleBtn,
              ],
            }),
          ],
        })
      }

      this.DefinitionForm = DefinitionForm; // Expose to methods

      DefinitionForm.prototype = Object.create(OO.ui.FieldsetLayout.prototype);

      /**
       * Adds an example form.
       */
      DefinitionForm.prototype.addExample = function () {
        var exampleForm = new ExampleForm(this.examples_number + 1);
        this._examplesFlds.push(exampleForm);
        // noinspection JSUnresolvedFunction,JSUnresolvedVariable
        this.addItems([exampleForm], this.items.length - 1);
        this._removeExampleBtn.toggle(this.examples_number !== 0);
      };

      /**
       * Removes an example form.
       * @param index {number} Example form’s index.
       */
      DefinitionForm.prototype.removeExample = function (index) {
        var exampleForm = this._examplesFlds[index];
        this._examplesFlds.splice(index, 1);
        // noinspection JSUnresolvedFunction
        this.removeItems([exampleForm]);
        this._removeExampleBtn.toggle(this.examples_number !== 0);
      };

      /**
       * @return {string} Definition’s text.
       */
      DefinitionForm.prototype.getText = function () {
        return this._definitionFld.getValue().trim();
      };

      Object.defineProperty(DefinitionForm.prototype, "examples_number", {
        /**
         * @return {number} The number of examples.
         */
        get: function () {
          return this._examplesFlds.length;
        },
      });

      /**
       * @param index {number} Example’s index.
       * @return {Example}
       */
      DefinitionForm.prototype.getExample = function (index) {
        var exampleForm = this._examplesFlds[index];
        return new Example(
            exampleForm.getText(),
            exampleForm.getTranslation(),
            exampleForm.getTranscription(),
            exampleForm.getSource()
        );
      };

      /**
       * Create a definition example form.
       * @param exampleID {number}
       * @constructor
       */
      function ExampleForm(exampleID) {
        this._textFld = new OO.ui.TextInputWidget();
        this._translationFld = new OO.ui.TextInputWidget();
        this._transcriptionFld = new OO.ui.TextInputWidget();
        this._sourceFld = new OO.ui.TextInputWidget();

        OO.ui.FieldsetLayout.call(this, {
          label: "Exemple n°" + exampleID,
          items: [
            new OO.ui.FieldLayout(this._textFld, {
              label: self._createLinks(specialChars, this._textFld),
              align: "inline",
              help: getHelpPageLink("Aide:Exemples"),
            }),
            new OO.ui.FieldLayout(this._translationFld, {
              label: self._createLinks(specialChars, this._translationFld, null, "Traduction en français"),
              align: "inline",
            }),
            new OO.ui.FieldLayout(this._transcriptionFld, {
              label: self._createLinks(specialChars, this._transcriptionFld, null, "Transcription latine"),
              align: "inline",
            }),
            new OO.ui.FieldLayout(this._sourceFld, {
              label: self._createLinks(specialChars, this._sourceFld, null, "Source"),
              align: "inline",
            }),
          ],
        })
      }

      ExampleForm.prototype = Object.create(OO.ui.FieldsetLayout.prototype);

      /**
       * @return {string} Example’s text.
       */
      ExampleForm.prototype.getText = function () {
        return this._textFld.getValue().trim();
      };

      /**
       * @return {string|null} Example’s French translation.
       */
      ExampleForm.prototype.getTranslation = function () {
        return this._translationFld.getValue().trim() || null;
      };

      /**
       * @return {string|null} Example’s latin transcription.
       */
      ExampleForm.prototype.getTranscription = function () {
        return this._transcriptionFld.getValue().trim() || null;
      };

      /**
       * @return {string|null} Example’s source.
       */
      ExampleForm.prototype.getSource = function () {
        return this._sourceFld.getValue().trim() || null;
      };

      // Defining all tabs.
      const tabs = [
        {
          title: "Langue, type, définitions",
          content: () => {
            this._languageFld = new OO.ui.TextInputWidget({
              placeholder: "Code de langue",
            });
            this._languageBnt = new OO.ui.ButtonWidget({
              label: "Passer à cette langue",
            });
            // noinspection JSValidateTypes
            this._languageBnt.on("click", () => onLanguageSelect(this._languageFld.getValue()));

            let languageOptions = [];
            for (const lang of languages) {
              languageOptions.push(new OO.ui.MenuOptionWidget({
                data: lang.code,
                label: lang.name,
              }));
            }
            this._languageSelectFld = new OO.ui.DropdownWidget({
              label: "— Veuillez choisir —",
              menu: {
                items: languageOptions,
              },
            });
            // noinspection JSCheckFunctionSignatures,JSValidateTypes
            this._languageSelectFld.getMenu().on("select", e => onLanguageSelect(e.getData()));

            this._grammarClassSelectFld = new OO.ui.DropdownWidget({
              label: "— Veuillez choisir —",
            });
            // noinspection JSCheckFunctionSignatures
            this._grammarClassSelectFld.getMenu().on("select", e => onClassSelect(e.getData()));
            this._gendersFld = new OO.ui.DropdownWidget({
              label: "— Veuillez choisir —",
            });
            this._numbersFld = new OO.ui.DropdownWidget({
              label: "— Veuillez choisir —",
            });

            const imageSectionLabel = new OO.ui.HtmlSnippet(
                `Image &mdash; <a href="https://commons.wikimedia.org/w/index.php?search=${word}" ` +
                'target="_blank" title="S’ouvre dans un nouvel onglet">Rechercher sur Commons</a>'
            );
            this._imageFld = new OO.ui.TextInputWidget({
              id: "cnm-image-field",
              placeholder: "Nom du fichier",
            });
            this._imageDescriptionFld = new OO.ui.TextInputWidget({
              id: "cnm-image-description-field",
              placeholder: "Légende",
            });

            this._pronunciationFld = new OO.ui.TextInputWidget({
              id: "cnm-pronunciation-field",
            });
            this._pronunciationPnl = new OO.ui.FieldLayout(self._pronunciationFld, {
              align: "inline",
              help: getHelpPageLink("Aide:Prononciation"),
            });

            this._addDefinitionBtn = new OO.ui.ButtonWidget({
              label: "Ajouter une définition",
            });
            this._addDefinitionBtn.on("click", () => this.addDefinition());
            this._removeDefinitionBtn = new OO.ui.ButtonWidget({
              label: "Retirer la dernière définition",
            });
            this._removeDefinitionBtn.on("click", () => this.removeDefinition(this.definitions_number - 1));
            this._removeDefinitionBtn.toggle(false); // Hide by default

            this._definitionsLayout = new OO.ui.FieldsetLayout({
              label: "Définition(s)",
              items: [
                new OO.ui.HorizontalLayout({
                  items: [
                    this._addDefinitionBtn,
                    this._removeDefinitionBtn,
                  ],
                }),
              ],
            });

            this._categoriesWidget = new OO.ui.TagMultiselectWidget({
              inputPosition: "inline",
              allowArbitrary: true,
            });

            return new OO.ui.FieldsetLayout({
              items: [
                new OO.ui.FieldsetLayout({
                  label: "Langue",
                  items: [
                    new OO.ui.HorizontalLayout({
                      items: [
                        new OO.ui.FieldLayout(this._languageSelectFld, {
                          align: "inline",
                        }),
                        new OO.ui.ActionFieldLayout(this._languageFld, this._languageBnt, {
                          align: "inline",
                        }),
                      ],
                    }),
                  ],
                  help: "Pour passer à une langue indisponible dans le menu déroulant, "
                      + "entrez son code dans le champ ci-dessous puis appuyez sur le bouton «\u00a0Passer à cette langue\u00a0».",
                  helpInline: true,
                }),
                new OO.ui.FieldsetLayout({
                  label: "Informations grammaticales",
                  items: [
                    new OO.ui.HorizontalLayout({
                      items: [
                        new OO.ui.FieldLayout(this._grammarClassSelectFld, {
                          align: "inline",
                        }),
                        new OO.ui.FieldLayout(this._gendersFld, {
                          align: "inline",
                        }),
                        new OO.ui.FieldLayout(this._numbersFld, {
                          align: "inline",
                        }),
                      ],
                    }),
                  ],
                }),
                new OO.ui.FieldsetLayout({
                  label: imageSectionLabel,
                  items: [
                    this._imageFld,
                    this._imageDescriptionFld,
                  ],
                  help: "Indiquer seulement le nom de l’image, " +
                      "sans «\u00a0File:\u00a0», «\u00a0Fichier:\u00a0» ni «\u00a0Image:\u00a0».",
                  helpInline: true,
                }),
                new OO.ui.FieldsetLayout({
                  label: "Prononciation",
                  items: [
                    this._pronunciationPnl,
                  ],
                }),
                this._definitionsLayout,
                new OO.ui.FieldsetLayout({
                  label: "Catégories",
                  items: [
                    this._categoriesWidget,
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
          content: () => {
            this._etymologyFld = new OO.ui.MultilineTextInputWidget({
              rows: 4,
              autofocus: true,
            });
            const pronSectionLabel = new OO.ui.HtmlSnippet(
                'Prononciation (section)<span> &mdash; <a id="cnm-commons-audio-link" href="#" ' +
                'target="_blank" title="S’ouvre dans un nouvel onglet">Rechercher des fichiers audio sur Commons</a></span>'
            );
            this._pronunciationSectionFld = new OO.ui.MultilineTextInputWidget({
              rows: 4,
            });
            this._homophonesFld = new OO.ui.MultilineTextInputWidget({
              rows: 4,
            });
            this._paronymsFld = new OO.ui.MultilineTextInputWidget({
              rows: 4,
            });
            this._referencesFld = new OO.ui.MultilineTextInputWidget({
              rows: 4,
            });
            this._bibliographyFld = new OO.ui.MultilineTextInputWidget({
              rows: 4,
            });

            const fields = [];
            for (const section of sections) {
              if (!section.hidden) {
                const field = new OO.ui.MultilineTextInputWidget({
                  rows: 4,
                  columns: 20,
                });
                this._otherSectionFields[section.code] = field;
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
                    new OO.ui.FieldLayout(this._etymologyFld, {
                      label: this._createLinks(specialChars, this._etymologyFld),
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
                    new OO.ui.FieldLayout(this._pronunciationSectionFld, {
                      label: this._createLinks(specialChars, this._pronunciationSectionFld),
                      align: "inline",
                      help: getHelpPageLink("Aide:Prononciation"),
                    }),
                    new OO.ui.FieldLayout(this._homophonesFld, {
                      label: this._createLinks(specialChars, this._homophonesFld, "", "Homophones"),
                      align: "inline",
                      help: getHelpPageLink("Aide:Homophones et paronymes"),
                    }),
                    new OO.ui.FieldLayout(this._paronymsFld, {
                      label: this._createLinks(specialChars, this._paronymsFld, "", "Paronymes"),
                      align: "inline",
                      help: getHelpPageLink("Aide:Homophones et paronymes"),
                    }),
                  ],
                }),
                new OO.ui.FieldsetLayout({
                  label: "Références",
                  items: [
                    new OO.ui.FieldLayout(this._referencesFld, {
                      label: this._createLinks(specialChars, this._referencesFld),
                      align: "inline",
                      help: getHelpPageLink("Aide:Références#Le_format_développé"),
                    }),
                    new OO.ui.FieldLayout(this._bibliographyFld, {
                      label: this._createLinks(specialChars, this._bibliographyFld, "", "Bibliographie"),
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
          content: () => {
            const otherProjectsFields = [];
            const linksEnabled = false;

            for (const [projectCode, projectData] of Object.entries(this._otherProjects)) {
              // * DO NOT REMOVE FUNCTION *
              // This function in necessary to avoid “textFld”
              // changing value in checkbox.on() after each iteration.
              (function () {
                const projectName = projectData.label;
                const checkbox = new OO.ui.CheckboxInputWidget({
                  value: projectCode,
                  selected: linksEnabled,
                });
                const textFld = new OO.ui.TextInputWidget({
                  label: projectName,
                  disabled: !linksEnabled,
                });

                checkbox.on("change", function (selected) {
                  textFld.setDisabled(!selected);
                });

                self._seeOtherProjectsChk[projectCode] = {
                  checkbox: checkbox,
                  textfield: textFld,
                };

                otherProjectsFields.push(new OO.ui.ActionFieldLayout(
                    checkbox,
                    textFld,
                    {
                      align: "inline",
                      id: `cnm-sister-project-${projectCode}`,
                      label: new OO.ui.HtmlSnippet('<a href="#" target="_blank">Rechercher</a>'),
                    }
                ));
              })();
            }

            this._draftChk = new OO.ui.CheckboxInputWidget();
            this._sortKeyFld = new OO.ui.TextInputWidget();

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
                    new OO.ui.FieldLayout(this._draftChk, {
                      label: "Ébauche",
                      align: "inline",
                    }),
                    new OO.ui.FieldLayout(this._sortKeyFld, {
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

      const tabsWidget = new OO.ui.IndexLayout({
        expanded: false,
        id: "cnm-tabs-widget",
      });
      for (const [i, tabData] of tabs.entries()) {
        var tab = new gadget_creerNouveauMot.Tab(`cnm-tab${i}`, {
          label: tabData.title,
          expanded: false,
        });
        const content = tabData.content();
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

      const toolFactory = new OO.ui.ToolFactory();
      const toolGroupFactory = new OO.ui.ToolGroupFactory();
      const toolbar = new OO.ui.Toolbar(toolFactory, toolGroupFactory, {actions: true});

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

      const hideBtn = "hide";
      generateButton(toolFactory, hideBtn, "collapse", false, "Masquer", function () {
        // noinspection JSCheckFunctionSignatures
        tabsWidget.toggle();
        this.setTitle(tabsWidget.isVisible() ? "Masquer" : "Afficher");
        this.setIcon(tabsWidget.isVisible() ? "collapse" : "expand");
      });

      const helpBtn = "help";
      generateButton(toolFactory, helpBtn, "help", false, "Aide (s’ouvre dans un nouvel onglet)", function () {
        window.open("/wiki/Aide:Gadget-CreerNouveauMot-dev");
      });

      const actionsToolbar = new OO.ui.Toolbar(toolFactory, toolGroupFactory);

      const insertWikicodeBtn = "insert";
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

      const gadgetBox = new OO.ui.PanelLayout({
        expanded: false,
        framed: true,
      });
      const contentFrame = new OO.ui.PanelLayout({
        expanded: false,
      });

      gadgetBox.$element.append(
          toolbar.$element,
          contentFrame.$element.append(tabsWidget.$element)
      );

      toolbar.initialize();
      toolbar.emit("updateState");

      $tedit.append(gadgetBox.$element);

      for (const projectCode of Object.keys(this._otherProjects)) {
        $(`#cnm-sister-project-${projectCode} span.oo-ui-actionFieldLayout-button`).attr("style", "width: 100%");
        $(`#cnm-sister-project-${projectCode} span.oo-ui-fieldLayout-field`).attr("style", "width: 100%");
      }

      this.addDefinition();

      // Enforce fonts for pronunciation text input.
      $("#cnm-pronunciation-field > input")
          .attr("style", 'font-family: "DejaVu Sans", "Segoe UI", "Lucida Grande", "Charis SIL", "Gentium Plus", "Doulos SIL", sans-serif !important');
    };

    gadget_creerNouveauMot.MainGui.prototype = Object.create(gadget_creerNouveauMot.Gui.prototype);

    /*
     * Public methods
     */

    /**
     * Selects the tab at the given index.
     * @param index {number} The index.
     */
    gadget_creerNouveauMot.MainGui.prototype.selectTab = function (index) {
      this._tabs[index].select();
    };

    /**
     * Selects the given language. All external links are modified appropriatly.
     * If the language is not in the dropdown menu, it is added to it.
     * @param language {Language} The language object.
     */
    gadget_creerNouveauMot.MainGui.prototype.selectLanguage = function (language) {
      gadget_creerNouveauMot._$TITLE_LANG.text(language.name);
      if (!this._languageSelectFld.getMenu().findItemFromData(language.code)) {
        this._languageSelectFld.getMenu().addItems([new OO.ui.MenuOptionWidget({
          data: language.code,
          label: language.name,
        })], 0);
      }
      this._updateFields(language);
      this._updateSisterProjectsLinks(language);
      const $link = $("#cnm-commons-audio-link");
      const $span = $link.parent();
      let commonsAudioUrl = "#";
      if (language.iso6393Code) {
        const w = this._word.replace(" ", "_");
        commonsAudioUrl =
            `https://commons.wikimedia.org/w/index.php?search=${w}.wav+incategory:"Lingua+Libre+pronunciation-${language.iso6393Code}"`;
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
     * @param genders {GrammaticalGender[]} The list of genders.
     */
    gadget_creerNouveauMot.MainGui.prototype.setAvailableGenders = function (genders) {
      this._setListValues(genders, this._gendersFld);
    };

    /**
     * Sets the available grammatical numbers widget.
     * @param numbers {GrammaticalNumber[]} The list of grammatical numbers.
     */
    gadget_creerNouveauMot.MainGui.prototype.setAvailableNumbers = function (numbers) {
      this._setListValues(numbers, this._numbersFld);
    };

    /*
     * Private methods
     */

    /**
     * Updates all language-related fields.
     * @param language {Language} The selected language.
     * @private
     */
    gadget_creerNouveauMot.MainGui.prototype._updateFields = function (language) {
      this._grammarClassSelectFld.getMenu().clearItems();
      const items = [];
      items.push(new OO.ui.MenuOptionWidget({
        data: "",
        label: new OO.ui.HtmlSnippet("— Veuillez choisir —"),
      }));

      for (const [key, grammarItem] of Object.entries(language.grammarItems)) {
        items.push(new OO.ui.MenuOptionWidget({
          data: key,
          label: new OO.ui.HtmlSnippet(grammarItem.grammaticalClass.label),
        }));
      }

      this._grammarClassSelectFld.getMenu().addItems(items);
      this._grammarClassSelectFld.getMenu().selectItem(items[0]);

      this._pronunciationFld.setDisabled(language.code === "conv");
    };

    /**
     * Updates the link search links to sister projects based on the selected language.
     * @param language {Language} The selected language.
     * @private
     */
    gadget_creerNouveauMot.MainGui.prototype._updateSisterProjectsLinks = function (language) {
      for (const [projectCode, projectData] of Object.entries(this._otherProjects)) {
        if (this._otherProjects.hasOwnProperty(projectCode)) {
          const forLangs = projectData.showOnlyForLangs || [];
          const disabled = forLangs.length !== 0 && !forLangs.includes(language.code);
          const checkbox = this._seeOtherProjectsChk[projectCode]["checkbox"];

          const projectDomain = projectData.urlDomain;
          const urlBase = projectData.urlBase || "w/index.php?search=";

          const $link = $(`#cnm-sister-project-${projectCode} a`);
          const url = this._generateProjectLink(projectDomain, urlBase, language.wikimediaCode, this._word);

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
     * @param values {(GrammaticalGender|GrammaticalNumber)[]} The list of values.
     * @param field {OO.ui.DropdownWidget} The OOUI widget.
     */
    gadget_creerNouveauMot.MainGui.prototype._setListValues = function (values, field) {
      // noinspection JSUnresolvedFunction
      field.getMenu().clearItems();
      const items = [];
      if (values.length) {
        if (values.length !== 1) { // No need to add an extra step when there’s only one choice
          items.push(new OO.ui.MenuOptionWidget({
            data: "",
            label: new OO.ui.HtmlSnippet("— Veuillez choisir —"),
          }));
        }
        for (const value of values) {
          items.push(new OO.ui.MenuOptionWidget({
            data: value.label,
            label: new OO.ui.HtmlSnippet(value.label),
          }));
        }
      } else {
        items.push(new OO.ui.MenuOptionWidget({
          data: "*",
          label: new OO.ui.HtmlSnippet("<em>indisponible</em>"),
        }));
      }
      // noinspection JSUnresolvedFunction
      field.getMenu().addItems(items);
      // noinspection JSUnresolvedFunction
      field.getMenu().selectItem(items[0]);
    };

    /**
     * Creates an HTML list of IPA symbols from a array of symbols.
     * @param ipaSymbols {string[][]} The list of IPA symbols.
     * @return {Object} A jQuery object.
     * @private
     */
    gadget_creerNouveauMot.MainGui.prototype._formatApi = function (ipaSymbols) {
      const $label = $("<span>");

      for (const [i, ipaSymbol] of ipaSymbols.entries()) {
        $label.append(this._createLinks(ipaSymbol, this._pronunciationFld, "API"));
        if (i < ipaSymbols.length - 1) {
          $label.append(" &mdash; ");
        }
      }

      return $label;
    };

    /**
     * Creates an HTML links sequence that will insert text into a text field when clicked.
     * @param list {string[]} The list of strings to convert into links.
     * @param textField {object} The text field to insert the text into.
     * @param cssClass {string?} Optional additonnal CSS classes.
     * @param text {string?} Some text that will be appended before the links.
     * @return {Object} A jQuery object.
     * @private
     */
    gadget_creerNouveauMot.MainGui.prototype._createLinks = function (list, textField, cssClass, text) {
      const $links = $("<span>");

      if (text) {
        $links.append(text + " &mdash; ");
      }

      for (const [i, item] of list.entries()) {
        const $link = $('<a href="#" class="{0}" data-value="{1}">{2}</a>'
            .format(cssClass, item.replace("&", "&amp;"), item.trim()));
        $link.click(e => {
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
    gadget_creerNouveauMot.MainGui.prototype._generateProjectLink = function (projectDomain, urlBase, langCode, word) {
      return langCode ? `https://${projectDomain.format(langCode)}/${urlBase}${encodeURI(word)}` : "#";
    }

    /*
     * Getters & setters
     */

    /**
     * Returns the contents of the given section.
     * @param sectionCode {string} Sections’s code.
     * @return {string} The section’s contents.
     */
    gadget_creerNouveauMot.MainGui.prototype.getSectionContent = function (sectionCode) {
      // noinspection JSCheckFunctionSignatures
      return this._otherSectionFields[sectionCode].getValue().trim();
    };

    // noinspection JSUnusedGlobalSymbols
    /**
     * Sets the contents of the given section.
     * @param sectionCode {string} Sections’s code.
     * @param content {string} The section’s contents.
     */
    gadget_creerNouveauMot.MainGui.prototype.setSectionContent = function (sectionCode, content) {
      this._otherSectionFields[sectionCode].setValue(content.trim());
    };

    /**
     * Indicates whether a link to the given sister project has to be inserted.
     * @param projectCode {string} Project’s code.
     * @return {boolean} True if a link has to be inserted.
     */
    gadget_creerNouveauMot.MainGui.prototype.hasAddLinkToProject = function (projectCode) {
      return this._seeOtherProjectsChk[projectCode]["checkbox"].isSelected();
    };

    /**
     * Sets whether a link to the given sister project has to be inserted.
     * @param projectCode {string} Project’s code.
     * @param link {boolean} True if a link has to be inserted.
     */
    gadget_creerNouveauMot.MainGui.prototype.setAddLinkToProject = function (projectCode, link) {
      this._seeOtherProjectsChk[projectCode]["checkbox"].setSelected(link);
    };

    /**
     * Returns the template parameters for the given sister project link.
     * @param projectCode {string} Project’s code.
     * @return {string} Template’s parameters.
     */
    gadget_creerNouveauMot.MainGui.prototype.getProjectLinkParams = function (projectCode) {
      // noinspection JSCheckFunctionSignatures
      return this._seeOtherProjectsChk[projectCode]["textfield"].getValue().trim();
    };

    /**
     * Sets template parameters for the given sister project link.
     * @param projectCode {string} Project’s code.
     * @param params {string} Template’s parameters.
     */
    gadget_creerNouveauMot.MainGui.prototype.setProjectLinkParams = function (projectCode, params) {
      this._seeOtherProjectsChk[projectCode]["textfield"].setValue(params.trim());
    };

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "tabsNumber", {
      /**
       * @return {number} The number of tabs.
       */
      get: function () {
        return this._tabs.length;
      }
    });

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "selectedLanguage", {
      /**
       * @return {string} Selected language’s code.
       */
      get: function () {
        // noinspection JSCheckFunctionSignatures
        return this._languageSelectFld.getMenu().findSelectedItem().getData();
      }
    });

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "gender", {
      /**
       * @return {string} Selected gender’s code.
       */
      get: function () {
        // noinspection JSCheckFunctionSignatures
        return this._gendersFld.getMenu().findSelectedItem().getData();
      },
    });

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "number", {
      /**
       * @return {string} Selected grammatical number’s code.
       */
      get: function () {
        // noinspection JSCheckFunctionSignatures
        return this._numbersFld.getMenu().findSelectedItem().getData();
      },
    });

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "grammarClass", {
      /**
       * @return {string} Selected grammatical class.
       */
      get: function () {
        // noinspection JSCheckFunctionSignatures
        return this._grammarClassSelectFld.getMenu().findSelectedItem().getData();
      },
    });

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "imageName", {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "imageDescription", {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "pronunciation", {
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

    /**
     * Returns the definition with the given number.
     * @param index {number} Definition’s index.
     * @return {Definition} A definition object.
     */
    gadget_creerNouveauMot.MainGui.prototype.getDefinition = function (index) {
      const definitionForm = this._definitionFlds[index];
      const examples = [];
      for (let i = 0; i < definitionForm.examples_number; i++) {
        examples.push(definitionForm.getExample(i));
      }
      return new Definition(definitionForm.getText(), examples);
    };

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "definitions_number", {
      /**
       * @return {number} The number of definitions.
       */
      get: function () {
        return this._definitionFlds.length;
      },
    });

    /**
     * Adds a definition form.
     */
    gadget_creerNouveauMot.MainGui.prototype.addDefinition = function () {
      const definitionForm = new this.DefinitionForm(this.definitions_number + 1);
      this._definitionFlds.push(definitionForm);
      this._definitionsLayout.addItems([definitionForm], this._definitionsLayout.items.length - 1);
      this._removeDefinitionBtn.toggle(this.definitions_number > 1);
    };

    /**
     * Removes a definition form.
     * @param index {number} The definition’s index.
     */
    gadget_creerNouveauMot.MainGui.prototype.removeDefinition = function (index) {
      const definitionForm = this._definitionFlds[index];
      this._definitionFlds.splice(index, 1);
      this._definitionsLayout.removeItems([definitionForm]);
      this._removeDefinitionBtn.toggle(this.definitions_number > 1);
    };

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "categories", {
      /**
       * @return {string[]} The categories.
       */
      get: function () {
        return this._categoriesWidget.getValue();
      },

      /**
       * Sets the categories.
       * @param categories {string[]} The image categories.
       */
      set: function (categories) {
        this._categoriesWidget.setValue(categories);
      },
    });

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "etymology", {
      /**
       * @return {string} The etymology.
       */
      get: function () {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "pronunciationSection", {
      /**
       * @return {string} The pronunciation section.
       */
      get: function () {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "homophones", {
      /**
       * @return {string} The homophones.
       */
      get: function () {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "paronyms", {
      /**
       * @return {string} The paronyms.
       */
      get: function () {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "references", {
      /**
       * @return {string} The references.
       */
      get: function () {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "bibliography", {
      /**
       * @return {string} The bibliography.
       */
      get: function () {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "isDraft", {
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

    Object.defineProperty(gadget_creerNouveauMot.MainGui.prototype, "sortingKey", {
      /**
       * @return {string} The sorting key.
       */
      get: function () {
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

    /*
     * Grammatical data definition
     */

    /**
     * Defines all available grammatical numbers.
     * @type {Object<string, GrammaticalNumber>}
     */
    gadget_creerNouveauMot.numbers = {
      DIFF_SINGULAR_PLURAL: new GrammaticalNumber("sing. et plur. différents"),
      SAME_SINGULAR_PLURAL: new GrammaticalNumber("sing. et plur. identiques", "{{sp}}"),
      SINGULAR_ONLY: new GrammaticalNumber("singulier uniquement", "{{au singulier uniquement|{0}}}"),
      PLURAL_ONLY: new GrammaticalNumber("pluriel uniquement", "{{au pluriel uniquement|{0}}}"),
      INVARIABLE: new GrammaticalNumber("invariable", "{{invariable}}"),
    };

    /**
     * Defines all available grammatical genders/verb groups.
     * @type {Object<string, GrammaticalGender>}
     */
    gadget_creerNouveauMot.genders = {
      MASCULINE: new GrammaticalGender("masculin", "{{m}}"),
      FEMININE: new GrammaticalGender("féminin", "{{f}}"),
      FEMININE_MASCULINE_DIFF: new GrammaticalGender("masc. et fém. différents"),
      FEMININE_MASCULINE: new GrammaticalGender("masc. et fém. identiques", "{{mf}}"),
      NO_GENDER: new GrammaticalGender("pas de genre"),
      VERB_GROUP1: new GrammaticalGender("1<sup>er</sup> groupe", "{{type|{0}}} {{conjugaison|fr|groupe=1}}"),
      VERB_GROUP2: new GrammaticalGender("2<sup>ème</sup> groupe", "{{type|{0}}} {{conjugaison|fr|groupe=2}}"),
      VERB_GROUP3: new GrammaticalGender("3<sup>ème</sup> groupe", "{{type|{0}}} {{conjugaison|fr|groupe=3}}"),
      VERB: new GrammaticalGender("verbe", "{{type|{0}}} {{conjugaison|{0}}}"),
      VERB_NO_TEMPLATE: new GrammaticalGender("verbe", "{{type|{0}}}"),
      REGULAR_VERB: new GrammaticalGender("régulier", "{{type|{0}}}"),
      IRREGULAR_VERB: new GrammaticalGender("irrégulier", "{{type|{0}}}"),
    };

    /**
     * Defines all available grammatical classes.
     * @type {Object<string, GrammaticalClass>}
     */
    gadget_creerNouveauMot.grammaticalClasses = {
      SYMBOL: new GrammaticalClass("symbole", "symbole"),
      LETTER: new GrammaticalClass("lettre", "lettre"),

      SCIENTIFIC_NAME: new GrammaticalClass("nom scientifique", "nom scientifique"),

      // Nouns
      NOUN: new GrammaticalClass("nom commun", "nom"),
      PROPER_NOUN: new GrammaticalClass("nom propre", "nom propre"),
      FIRST_NAME: new GrammaticalClass("prénom", "prénom"),
      LAST_NAME: new GrammaticalClass("nom de famille", "nom de famille"),

      // Adjectives
      ADJECTIVE: new GrammaticalClass("adjectif", "adjectif"),
      INTERROGATIVE_ADJECTIVE: new GrammaticalClass("adjectif interrogatif", "adjectif interrogatif"),
      NUMERAL_ADJECTIVE: new GrammaticalClass("adjectif numéral", "adjectif numéral"),
      POSSESSIVE_ADJECTIVE: new GrammaticalClass("adjectif possessif", "adjectif possessif"),

      // Adverbs
      ADVERB: new GrammaticalClass("adverbe", "adverbe"),
      INTERROGATIVE_ADVERB: new GrammaticalClass("adverbe interrogatif", "adverbe interrogatif"),

      // Pronouns
      PRONOUN: new GrammaticalClass("pronom", "pronom"),
      DEMONSTRATIVE_PRONOUN: new GrammaticalClass("pronom démonstratif", "pronom démonstratif"),
      INDEFINITE_PRONOUN: new GrammaticalClass("pronom indéfini", "pronom indéfini"),
      INTERROGATIVE_PRONOUN: new GrammaticalClass("pronom interrogatif", "pronom interrogatif"),
      PERSONAL_PRONOUN: new GrammaticalClass("pronom personnel", "pronom personnel"),
      POSSESSIVE_PRONOUN: new GrammaticalClass("pronom possessif", "pronom possessif"),
      RELATIVE_PRONOUN: new GrammaticalClass("pronom relatif", "pronom relatif"),

      // Conjunctions
      CONJUNCTION: new GrammaticalClass("conjonction", "conjonction"),
      COORDINATION_CONJUNCTION: new GrammaticalClass("conjonction de coordination", "conjonction de coordination"),

      // Articles
      ARTICLE: new GrammaticalClass("article", "article"),
      INDEFINITE_ARTICLE: new GrammaticalClass("article indéfini", "article indéfini"),
      DEFINITE_ARTICLE: new GrammaticalClass("article défini", "article défini"),
      PARTITIVE_ARTICLE: new GrammaticalClass("article partitif", "article partitif"),

      // Affixes
      PREFIX: new GrammaticalClass("préfixe", "préfixe"),
      SUFFIX: new GrammaticalClass("suffixe", "suffixe"),
      CIRCUMFIX: new GrammaticalClass("circonfixe", "circonfixe"),
      INFIX: new GrammaticalClass("infixe", "infixe"),

      VERB: new GrammaticalClass("verbe", "verbe"),
      PREPOSITION: new GrammaticalClass("préposition", "préposition"),
      POSTPOSITION: new GrammaticalClass("postposition", "postposition"),
      PARTICLE: new GrammaticalClass("particule", "particule"),
      INTERJECTION: new GrammaticalClass("interjection", "interjection"),
    };

    const cnm = gadget_creerNouveauMot;

    /*
     * French language definition.
     */

    function getFrenchModel(word, grammarClass, gender, number, pron, simple) {
      if (number === cnm.numbers.INVARIABLE.label) {
        return `{{fr-inv|${pron}|inv_titre=${grammarClass}}}`;
      }
      if (number === cnm.numbers.SAME_SINGULAR_PLURAL.label) {
        return `{{fr-inv|${pron}|sp=oui}}`;
      }
      if (number === cnm.numbers.SINGULAR_ONLY.label) {
        return `{{fr-inv|${pron}|inv_titre=Singulier}}`;
      }
      if (number === cnm.numbers.PLURAL_ONLY.label) {
        return `{{fr-inv|${pron}|inv_titre=Pluriel}}`;
      }

      if (gender === cnm.genders.FEMININE_MASCULINE.label) {
        return `{{fr-rég|${pron}|mf=oui}}`;
      }

      if (simple) {
        return `{{fr-rég|${pron}}}`;
      } else {
        return `{{fr-accord-rég|${pron}}}`;
      }
    }

    cnm.addLanguage(new Language(
        "fr",
        "fr",
        "fra",
        "français",
        [
          ["a", "ɑ", "ɑ̃", "ə", "œ", "œ̃", "ø", "e", "ɛ", "ɛ̃", "i", "o", "ɔ", "ɔ̃", "y", "u"],
          ["b", "d", "f", "ɡ", "k", "l", "m", "n", "ɲ", "ŋ", "p", "ʁ", "s", "ʃ", "t", "v", "z", "ʒ"],
          ["j", "w", "ɥ"],
          [".", "‿"],
        ],
        [
          new GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.FEMININE_MASCULINE_DIFF, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.VERB_GROUP1, cnm.genders.VERB_GROUP2, cnm.genders.VERB_GROUP3]),

          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.NUMERAL_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.DEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.PARTITIVE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.COORDINATION_CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.LAST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.POSTPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.PREFIX, [cnm.genders.NO_GENDER]),
          new GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getFrenchModel),
          new GrammaticalItem(cnm.grammaticalClasses.DEMONSTRATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.PERSONAL_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.RELATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getFrenchModel(word, grammarClass, gender, number, pron, true)),
          new GrammaticalItem(cnm.grammaticalClasses.SUFFIX, [cnm.genders.NO_GENDER]),
        ]
    )); // fr

    /*
     * English language definition.
     */

    function getEnglishModel(grammarClass, number, pron) {
      if (number === cnm.numbers.SAME_SINGULAR_PLURAL.label) {
        return `{{en-inv|${pron}|sp=oui}}`;
      }
      if (number === cnm.numbers.SINGULAR_ONLY.label) {
        return `{{en-inv|${pron}|inv_titre=Singulier}}`;
      }
      if (number === cnm.numbers.PLURAL_ONLY.label) {
        return `{{en-inv|${pron}|inv_titre=Pluriel}}`;
      }
      return `{{en-inv|${pron}|inv_titre=${grammarClass}}}`;
    }

    cnm.addLanguage(new Language(
        "en",
        "en",
        "eng",
        "anglais",
        [
          ["i", "iː", "ɪ", "ɛ", "æ", "ə", "ɚ", "ɜː", "ɝ", "uː", "u", "ʊ", "ʌ", "ɔː", "ɑː", "ɒ"],
          ["aɪ", "aʊ", "eə", "eɪ", "əʊ", "oʊ", "ɔə", "ɔɪ", "ɪə", "ʊə", "uə"],
          ["b", "d", "f", "ɡ", "h", "k", "l", "m", "n", "ŋ", "ɲ", "p", "ɹ", "ɻ", "s", "ʃ", "t", "θ", "ð", "v", "z", "ʒ"],
          ["j", "w"],
          [".", "ˈ", "ˌ", "ː"],
        ],
        [
          new GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => number !== cnm.numbers.DIFF_SINGULAR_PLURAL.label ? getEnglishModel(grammarClass, number, pron) : `{{en-nom-rég|${pron}}}`),
          new GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.REGULAR_VERB, cnm.genders.IRREGULAR_VERB], null, (word, grammarClass, gender, number, pron) => gender === cnm.genders.REGULAR_VERB.label ? `{{en-conj-rég|inf.pron=${pron}}}` : `{{en-conj-irrég|inf=${word}|inf.pron=${pron}|<!-- Compléter -->}}`),

          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.NUMERAL_ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.DEFINITE_ARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_ARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.PARTITIVE_ARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.COORDINATION_CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.LAST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => number !== cnm.numbers.DIFF_SINGULAR_PLURAL.label ? getEnglishModel(grammarClass, number, pron) : `{{en-nom-rég|${pron}}}`),
          new GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.POSTPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.PREFIX, [cnm.genders.NO_GENDER]),
          new GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => number !== cnm.numbers.DIFF_SINGULAR_PLURAL.label ? getEnglishModel(grammarClass, number, pron) : `{{en-nom-rég|${pron}}}`),
          new GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.DEMONSTRATIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.PERSONAL_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.RELATIVE_PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getEnglishModel(grammarClass, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.SUFFIX, [cnm.genders.NO_GENDER]),
        ]
    )); // en

    /*
     * Italian language definition.
     */

    function getItalianModel(word, grammarClass, gender, number, pron) {
      if (number === cnm.numbers.INVARIABLE.label) {
        return `{{it-inv|${pron}|inv_titre=${grammarClass}}}`;
      }
      if (number === cnm.numbers.SAME_SINGULAR_PLURAL.label) {
        return `{{it-inv|${pron}|sp=oui}}`;
      }
      if (number === cnm.numbers.SINGULAR_ONLY.label) {
        return `{{it-inv|${pron}|inv_titre=Singulier}}`;
      }
      if (number === cnm.numbers.PLURAL_ONLY.label) {
        return `{{it-inv|${pron}|inv_titre=Pluriel}}`;
      }

      if (gender === cnm.genders.FEMININE_MASCULINE.label) {
        return `{{it-flexion|${pron}|mf=oui}}`;
      }

      return `{{it-flexion|${pron}}}`;
    }

    cnm.addLanguage(new Language(
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
          new GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.FEMININE_MASCULINE_DIFF, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.VERB_GROUP1, cnm.genders.VERB_GROUP2, cnm.genders.VERB_GROUP3]),

          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.NUMERAL_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_ADJECTIVE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.DEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.PARTITIVE_ARTICLE, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.COORDINATION_CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.LAST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.PARTICLE, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.POSTPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.PREFIX, [cnm.genders.NO_GENDER]),
          new GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], getItalianModel),
          new GrammaticalItem(cnm.grammaticalClasses.DEMONSTRATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INDEFINITE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.INTERROGATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.PERSONAL_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.POSSESSIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.RELATIVE_PRONOUN, [cnm.genders.MASCULINE, cnm.genders.FEMININE, cnm.genders.FEMININE_MASCULINE], [cnm.numbers.DIFF_SINGULAR_PLURAL, cnm.numbers.SAME_SINGULAR_PLURAL, cnm.numbers.SINGULAR_ONLY, cnm.numbers.PLURAL_ONLY, cnm.numbers.INVARIABLE], (word, grammarClass, gender, number, pron) => getItalianModel(word, grammarClass, gender, number, pron)),
          new GrammaticalItem(cnm.grammaticalClasses.SUFFIX, [cnm.genders.NO_GENDER]),
        ]
    )); // it

    /*
     * Esperanto language definition.
     */

    function getEsperantoModel(_, grammarClass, gender, number, pron) {
      if (number === cnm.numbers.DIFF_SINGULAR_PLURAL.label) {
        return `{{eo-flexions|${pron}}}`;
      }
      if (grammarClass.toLowerCase() === cnm.grammaticalClasses.VERB.label) {
        return "{{eo-verbe}}";
      }
      return "";
    }

    cnm.addLanguage(new Language(
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
          new GrammaticalItem(cnm.grammaticalClasses.ADJECTIVE, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.CONJUNCTION, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.INTERJECTION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.FIRST_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.DIFF_SINGULAR_PLURAL], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.PREPOSITION, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.PRONOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE], getEsperantoModel),
          new GrammaticalItem(cnm.grammaticalClasses.VERB, [cnm.genders.VERB_NO_TEMPLATE], null, getEsperantoModel),
        ],
        word => word.toLowerCase()
            .replace(/c/g, "t͡s")
            .replace(/ĉ/g, "t͡ʃ")
            .replace(/g/g, "ɡ")
            .replace(/ĝ/g, "d͡ʒ")
            .replace(/ĥ/g, "x")
            .replace(/ĵ/g, "ʒ")
            .replace(/ŝ/g, "ʃ")
            .replace(/ŭ/g, "w")
    )); // eo

    /*
     * International conventions "language" definition.
     */

    cnm.addLanguage(new Language(
        "conv",
        null,
        null,
        "conventions internationales",
        [],
        [
          new GrammaticalItem(cnm.grammaticalClasses.SCIENTIFIC_NAME, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
          new GrammaticalItem(cnm.grammaticalClasses.PROPER_NOUN, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
          new GrammaticalItem(cnm.grammaticalClasses.SYMBOL, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
          new GrammaticalItem(cnm.grammaticalClasses.ADVERB, [cnm.genders.NO_GENDER], [cnm.numbers.INVARIABLE]),
        ]
    )); // conv

    gadget_creerNouveauMot.init();
  }
});
// </nowiki>
