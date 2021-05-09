/**
 * (fr)
 *  Ce gadget permet de créer les flexions pour les lemmes dans
 *  diverses langues à partir des liens rouges dans les tables de
 *  flexions.
 * ------------------------------------------------------------------
 * (en)
 * This gadget lets users create inflection pages for lemmas in
 * several languages from red links within inflection tables.
 * ------------------------------------------------------------------
 * v1.0 2021-??-?? First version TODO màj date à la sortie
 * ------------------------------------------------------------------
 * [[Catégorie:JavaScript du Wiktionnaire|create-inflection-dev.js]]
 */

$(function () {
  // Activate only in main namespace.
  // noinspection PointlessBooleanExpressionJS TEST
  if (true/*wikt.page.hasNamespaceIn([""])*/) { // TEST
    console.log("Chargement de Gadget-wikt.create-inflection-dev.js…");

    window.wikt.gadgets.createInflection = {
      NAME: "Créer flexion",

      VERSION: "1.0",

      _baseWord: "",

      _inflectionToCreate: "",

      _gender: "",

      _number: "",

      /** @type {wikt.gadgets.createInflection.LanguageData} */
      _language: null,

      /**
       * @type {Array<wikt.gadgets.createInflection.LanguageData>}
       */
      _languages: [],

      /**
       * Adds the given language data to this gadget.
       * @param languageData {wikt.gadgets.createInflection.LanguageData}
       */
      addLanguageData: function (languageData) {
        this._languages.push(languageData);
      },

      /**
       * Initializes the gadget by adding a callback function to
       * this gadget to red links inside the first table with the
       * "flextable-fr-mfsp" CSS class.
       */
      init: function () {
        var self = this;

        this._languages.forEach(function (languageData) {
          var flexTableClass = "." + languageData.inflectionTableClass;

          var gender = null;
          var $flextableSelfLink = $(flexTableClass + " .selflink");

          if ($flextableSelfLink.length) {
            languageData.genderClasses.forEach(function (genderClass) {
              if ($flextableSelfLink.first().parents("." + genderClass.class).length) {
                gender = genderClass.code;
              }
            });
          }

          $(flexTableClass + " .new").each(function (_, e) {
            var $redLink = $(e);
            var inflection = $redLink.text();

            // Une boite de flexions pour noms communs contient deux lemmes différents :
            // celui au masculin et au féminin : on ne colore dans ce cas que les formes
            // du genre correspondant au nom de la page
            var isNoun = false;
            // Get word type from section title
            // noinspection JSUnresolvedFunction
            var wordType = $redLink.parents(flexTableClass)
                .prevAll("h3").first().find(".titredef").text();

            if (wordType === "Nom commun" || wordType === "Locution nominale") {
              isNoun = true;
            }

            // gender of the red link
            var redLinkGender = null;
            languageData.genderClasses.forEach(function (genderClass) {
              if ($redLink.parents("." + genderClass.class).length) {
                redLinkGender = genderClass.code;
              }
            });
            console.log(isNoun, redLinkGender, gender); // DEBUG

            // On ne surligne pas les liens qui ne sont pas des flexions du mot courant
            // redLinkGender est null dans le cas de fr-rég, où le genre n'est pas
            // indiqué dans le tableau de flexions.
            if (isNoun && redLinkGender && redLinkGender !== gender) {
              return;
            }

            $redLink.css("background-color", "#0f0");
            $redLink.attr("title", "Cliquez pour créer « {0} » avec le gadget CréerFlexion".format(inflection));
            $redLink.click(function (e) {
              e.preventDefault();
              self._baseWord = mw.config.get("wgPageName").replace(/_/g, " ");
              self._inflectionToCreate = inflection.replace(/&nbsp;/g, " ");
              // TODO set self._number
              self._language = languageData;
              self._onClick();
            });
          });
        });
      },

      /**
       * Called when the user clicks on an inflection.
       * Sends an AJAX request to get the HTML code of
       * the current page then proceeds to the rest of
       * the procedure.
       * @private
       */
      _onClick: function () {
        $.get(
            mw.config.get("wgServer") + mw.config.get("wgScript"),
            {
              "title": this._baseWord,
              "action": "raw"
            },
            this._onSuccess.bind(this)
        );
      },

      /**
       * Gets the wikicode for the current page, generates the wikicode for the
       * inflection then sends a request to open the edit page.
       * @param wikicode {string} The wikicode for the current page.
       * @private
       */
      _onSuccess: function (wikicode) {
        console.log(this._baseWord, this._inflectionToCreate, this._language.languageCode); // DEBUG
        var self = this;
        var wikicodeLines = wikicode.split("\n");
        var newWikicode = "";

        // Générer le code wiki de la nouvelle page en ne conservant que les lignes utiles
        // de l'ancienne (la page principale du mot).
        // Le principe est que l'on doit trouver dans l'ordre :
        // * une section de langue française
        // ** une section de type de mot
        // *** éventuellement une boite de flexions
        // *** une ligne de forme
        // ** éventuellement une autre section de type de mot (retour récursif).
        // * Une autre section de langue arrête tout.

        newWikicode = wikicodeLines.join("\n"); // TEST

        // TODO reprendre tout les modèles de flexion pour ajouter des classe CSS pour les genres/nombres

        $.get(
            mw.config.get("wgServer") + mw.config.get("wgScript"),
            {
              "title": this._inflectionToCreate,
              "action": "edit",
            },
            function (data) {
              self._loadEditPage(data, newWikicode, self._baseWord);
            }
        );
      },

      /**
       * Replaces the current page content by the inflection edit page.
       * @param pageData {string} Edit page HTML content.
       * @param newWikicode {string} Inflection wikicode.
       * @param referer {string} Origin page title.
       */
      _loadEditPage: function (pageData, newWikicode, referer) {
        document.body.innerHTML = pageData;
        $("#wpTextbox1").val(newWikicode);
        $("#wpSummary").val(
            "Création avec [[Aide:Gadget-wikt.create-inflection|{0}]] (v{1}) depuis [[{2}]]"
                .format(this.NAME, this.VERSION, referer));
      },
    };

    /**
     * Data structure defining language specific values and parsing functions.
     * @param languageCode {string} Language’s code.
     * @param inflectionTableClass {string} List of inflection table classes to hook the gadget to.
     * @param genderClasses {Array<{class: string, code: string}>}
     * @constructor
     */
    wikt.gadgets.createInflection.LanguageData = function (languageCode, inflectionTableClass, genderClasses) {
      this._languageCode = languageCode;
      this._inflectionTableClass = inflectionTableClass;
      this._genderClasses = genderClasses;
    };

    wikt.gadgets.createInflection.LanguageData.prototype = {};

    Object.defineProperty(wikt.gadgets.createInflection.LanguageData.prototype, "languageCode", {
      /**
       * @return {string} The language code.
       */
      get: function () {
        return this._languageCode;
      }
    });

    Object.defineProperty(wikt.gadgets.createInflection.LanguageData.prototype, "inflectionTableClass", {
      /**
       * @return {string} The inflection table class.
       */
      get: function () {
        return this._inflectionTableClass;
      }
    });

    Object.defineProperty(wikt.gadgets.createInflection.LanguageData.prototype, "genderClasses", {
      /**
       * @return {Array<{class: string, code: string}>} The list of CSS classes for each gender.
       */
      get: function () {
        return this._genderClasses;
      }
    });

    var namespaceId = mw.config.get("wgNamespaceIds")["mediawiki"];
    var basePage = "Gadget-wikt.create-inflection-dev.js";

    wikt.page.getSubpages(namespaceId, basePage, "[a-zA-Z]*\\.js", function (response) {
      var modules = $.map(response.query.search, function (e) {
        return "https://fr.wiktionary.org/wiki/{0}?action=raw&ctype=text/javascript".format(e.title);
      });
      wikt.loadScripts(modules).done(function () {
        wikt.gadgets.createInflection.init();
      });
    });
  }
});
