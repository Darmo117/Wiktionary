/**
 * (fr)
 * Ce gadget permet l’ajout d’exemples sans passer en mode édition. Un bouton pour
 * ouvrir le formulaire devrait apparaitre à la fin de chaque série d’exemples pour
 * chaque définition (seulement si le modèle [[Modèle:exemple]] est utilisé).
 * ------------------------------------------------------------------------------------
 * (en)
 * This gadget allows to add examples without entering edit mode. A button to open the
 * form should appear at the end of each series of examples for each definition
 * (only if [[Modèle:exemple]] template is used).
 * ------------------------------------------------------------------------------------
 * v1.0 2021-09-12 Initial version
 * v1.1 2021-09-16 Added input field for "lien" parameter.
 * ------------------------------------------------------------------------------------
 * [[Catégorie:JavaScript du Wiktionnaire|add-examples.js]]
 * <nowiki>
 */
$(function () {
  "use strict";

  console.log("Chargement de Gadget-wikt.add-examples.js…");

  var NAME = "Ajouter des exemples";
  var VERSION = "1.1";

  var COOKIE_KEY_TEXT = 'add_examples_text';
  var COOKIE_KEY_SOURCE = 'add_examples_source';
  var COOKIE_KEY_SOURCE_URL = 'add_examples_source_url';
  var COOKIE_KEY_TRANSLATION = 'add_examples_translation';
  var COOKIE_KEY_TRANSCRIPTION = 'add_examples_transcription';

  var api = new mw.Api();
  var languages = {};
  var sectionNames = {
    "adj": ["adj", "adjectif", "adjectif qualificatif"],
    "adv": ["adv", "adverbe"],
    "adv-ind": ["adv-ind", "adverbe ind", "adverbe indéfini"],
    "adv-int": ["adv-int", "adverbe int", "adverbe interrogatif"],
    "adv-pron": ["adv-pron", "adverbe pro", "adverbe pronominal"],
    "adv-rel": ["adv-rel", "adverbe rel", "adverbe relatif"],
    "conj": ["conj", "conjonction"],
    "conj-coord": ["conj-coord", "conjonction coo", "conjonction de coordination"],
    "copule": ["copule"],
    "adj-dém": ["adj-dém", "adjectif dém", "adjectif démonstratif"],
    "dét": ["dét", "déterminant"],
    "adj-excl": ["adj-excl", "adjectif exc", "adjectif exclamatif"],
    "adj-indéf": ["adj-indéf", "adjectif ind", "adjectif indéfini"],
    "adj-int": ["adj-int", "adjectif int", "adjectif interrogatif"],
    "adj-num": ["adj-num", "adjectif num", "adjectif numéral"],
    "adj-pos": ["adj-pos", "adjectif pos", "adjectif possessif"],
    "adj-rel": ["adj-rel", "adjectif rel", "adjectif relatif"],
    "art": ["art", "article"],
    "art-déf": ["art-déf", "article déf", "article défini"],
    "art-indéf": ["art-indéf", "article ind", "article indéfini"],
    "art-part": ["art-part", "article par", "article partitif"],
    "nom": ["nom", "substantif", "nom commun"],
    "nom-fam": ["nom-fam", "nom de famille"],
    "patronyme": ["patronyme"],
    "nom-pr": ["nom-pr", "nom propre"],
    "nom-sciences": ["nom-sciences", "nom science", "nom scient", "nom scientifique"],
    "prénom": ["prénom"],
    "prép": ["prép", "préposition"],
    "pronom": ["pronom"],
    "pronom-adj": ["pronom-adj", "pronom-adjectif"],
    "pronom-dém": ["pronom-dém", "pronom dém", "pronom démonstratif"],
    "pronom-indéf": ["pronom-indéf", "pronom ind", "pronom indéfini"],
    "pronom-int": ["pronom-int", "pronom int", "pronom interrogatif"],
    "pronom-pers": ["pronom-pers", "pronom-per", "pronom personnel", "pronom réf", "pronom-réfl", "pronom réfléchi"],
    "pronom-pos": ["pronom-pos", "pronom pos", "pronom possessif"],
    "pronom-rel": ["pronom-rel", "pronom rel", "pronom relatif"],
    "racine": ["racine"],
    "verb": ["verb", "verbe"],
    "verb-pr": ["verb-pr", "verbe pr", "verbe pronominal"],
    "interj": ["interj", "interjection"],
    "onoma": ["onoma", "onom", "onomatopée"],
    "aff": ["aff", "affixe"],
    "circon": ["circon", "circonf", "circonfixe"],
    "inf": ["inf", "infixe"],
    "interf": ["interf", "interfixe"],
    "part": ["part", "particule"],
    "part-num": ["part-num", "particule num", "particule numérale"],
    "post": ["post", "postpos", "postposition"],
    "préf": ["préf", "préfixe"],
    "rad": ["rad", "radical"],
    "suf": ["suf", "suff", "suffixe"],
    "pré-verb": ["pré-verb", "pré-verbe"],
    "pré-nom": ["pré-nom"],
    "procl": ["procl", "proclitique"],
    "loc": ["loc", "locution"],
    "phr": ["loc-phr", "locution-phrase", "locution phrase", "phrase"],
    "prov": ["prov", "proverbe"],
    "quantif": ["quantif", "quantificateur"],
    "var-typo": ["var-typo", "variante typo", "variante par contrainte typographique"],
    "lettre": ["lettre"],
    "symb": ["symb", "symbole"],
    "class": ["class", "classif", "classificateur"],
    "numeral": ["numér", "num", "numéral"],
    "sinogramme": ["sinog", "sino", "sinogramme"],
    "gismu": ["gismu"],
    "rafsi": ["rafsi"],
  };

  // Get names of all defined languages
  api.get({
    action: "query",
    format: "json",
    titles: "MediaWiki:Gadget-translation editor.js/langues.json",
    prop: "revisions",
    rvprop: "content",
    rvslots: "main",
  }).then(function (data) {
    for (var pageID in data.query.pages) {
      if (data.query.pages.hasOwnProperty(pageID)) {
        // noinspection JSUnresolvedVariable
        languages = JSON.parse(data.query.pages[pageID].revisions[0].slots.main["*"]);
        break;
      }
    }
  });

  $("ul > li > .example").each(function () {
    var $element = $(this);
    var $item = $element.parent();

    if (!$item.next().length) {
      // Get example’s language
      var language = $item.find("span[lang]")[0].lang;

      // Get section and indices of associated definition
      var definitionLevel = [];
      var $definitionItem = $item.parent().parent();
      var $topItem;
      do {
        definitionLevel.splice(0, 0, $definitionItem.index());
        $topItem = $definitionItem;
        $definitionItem = $definitionItem.parent().parent();
      } while ($definitionItem.prop("tagName") === "LI");
      var $section = $($topItem.parent().prevAll("h3").get(0)).find(".titredef");
      definitionLevel.splice(0, 0, $section.attr("id"));

      // Remove default edit link if present
      var $defaultEditLink = $item.find("span.stubedit");
      if ($defaultEditLink.length) {
        $defaultEditLink.remove();
      }

      // Add a nice button to open the form
      var $formItem = $("<li>");
      var button = new OO.ui.ButtonWidget({label: "Ajouter un exemple"});
      button.on("click", function () {
        if (!button.getData()) {
          $formItem.append(new Form($item, button, language, definitionLevel).$element);
        }
        button.getData().setVisible(true);
      });
      $item.after($formItem.append(button.$element));
    }
  });

  /**
   * Constructor for the edit form.
   * @constructor
   * @param $lastExample {jQuery} The element corresponding to the example right above the button.
   * @param button {OO.ui.ButtonWidget} The button that shows this form.
   * @param language {string} Language for the example.
   * @param definitionLevel {Array<string|number>} Indices of the associated definition.
   */
  function Form($lastExample, button, language, definitionLevel) {
    var self = this;
    this._language = language;
    this._definitionLevel = definitionLevel;
    this._$lastExample = $lastExample;
    this._button = button;
    this._button.setData(this);

    this._textInput = new OO.ui.MultilineTextInputWidget();
    var textInputLayout = new OO.ui.FieldLayout(this._textInput, {
      label: "Texte de l’exemple",
      align: "top",
    });
    this._textInput.on("change", function (value) {
      self._applyButton.setDisabled(!value);
    })

    this._sourceInput = new OO.ui.MultilineTextInputWidget();
    var sourceInputLayout = new OO.ui.FieldLayout(this._sourceInput, {
      label: "Source de l’exemple",
      align: "top",
    });

    this._sourceURLInput = new OO.ui.TextInputWidget();
    var sourceURLInputLayout = new OO.ui.FieldLayout(this._sourceURLInput, {
      label: "Adresse web de l’exemple",
      align: "top",
    });

    this._translationInput = new OO.ui.MultilineTextInputWidget();
    var translationInputLayout = new OO.ui.FieldLayout(this._translationInput, {
      label: "Traduction en français de l’exemple",
      align: "top",
    });

    this._transcriptionInput = new OO.ui.MultilineTextInputWidget();
    var transcriptionInputLayout = new OO.ui.FieldLayout(this._transcriptionInput, {
      label: "Transcription de l’exemple",
      align: "top",
      help: "Ne renseigner que dans le cas où le texte de l’exemple n’est pas écrit avec l’alphabet latin.",
      helpInline: true,
    });

    this._applyButton = new OO.ui.ButtonWidget({
      label: "Publier",
      title: "Publier l’exemple pour cette définition",
      flags: ["progressive", "primary"],
      disabled: true,
    });
    this._applyButton.on("click", this.submit.bind(this));
    this._cancelButton = new OO.ui.ButtonWidget({
      label: "Annuler",
      title: "Refermer le formulaire",
      flags: ["destructive"],
    });
    this._cancelButton.on("click", function () {
      self.setVisible(false);
    });

    this._loadingImage = new OO.ui.LabelWidget({
      label: $('<img src="https://upload.wikimedia.org/wikipedia/commons/7/7a/Ajax_loader_metal_512.gif" alt="loading" style="width: 1.5em">'),
    });
    this._loadingImage.toggle(false);

    var content = [textInputLayout, sourceInputLayout, sourceURLInputLayout];
    if (language !== "fr") {
      content.push(translationInputLayout, transcriptionInputLayout);
    }
    var fieldsLayout = new OO.ui.FieldsetLayout({
      label: "Ajout d’un exemple en " + (languages[this._language] || "langue inconnue"),
      items: content,
      classes: ["add-example-fieldset"],
    });

    var buttonsLayout = new OO.ui.HorizontalLayout({
      items: [
        this._applyButton,
        this._cancelButton,
        this._loadingImage,
      ]
    });

    this._frame = new OO.ui.PanelLayout({
      id: "add-example-definition-{0}-form".format(this._definitionLevel.join("-")),
      classes: ["add-example-form"],
      expanded: false,
      content: [
        fieldsLayout,
        buttonsLayout,
      ],
    });
  }

  Form.prototype = {
    /**
     * Returns the jQuery object for this form.
     * @return {jQuery}
     */
    get $element() {
      return this._frame.$element;
    },

    /**
     * Toggles the visibility of this form.
     * @param visible {boolean}
     */
    setVisible: function (visible) {
      this._button.toggle(!visible);
      this._frame.toggle(visible);
      if (visible) {
        if (!this._textInput.getValue() && $.cookie(COOKIE_KEY_TEXT)) {
          this._textInput.setValue($.cookie(COOKIE_KEY_TEXT));
        }
        if (!this._sourceInput.getValue() && $.cookie(COOKIE_KEY_SOURCE)) {
          this._sourceInput.setValue($.cookie(COOKIE_KEY_SOURCE));
        }
        if (!this._sourceURLInput.getValue() && $.cookie(COOKIE_KEY_SOURCE_URL)) {
          this._sourceURLInput.setValue($.cookie(COOKIE_KEY_SOURCE_URL));
        }
        if (!this._translationInput.getValue() && $.cookie(COOKIE_KEY_TRANSLATION)) {
          this._translationInput.setValue($.cookie(COOKIE_KEY_TRANSLATION));
        }
        if (!this._transcriptionInput.getValue() && $.cookie(COOKIE_KEY_TRANSCRIPTION)) {
          this._transcriptionInput.setValue($.cookie(COOKIE_KEY_TRANSCRIPTION));
        }
      }
    },

    /**
     * Clears all fields contained in this forms.
     */
    clear: function () {
      this._textInput.setValue("");
      this._sourceInput.setValue("");
      this._sourceURLInput.setValue("");
      this._translationInput.setValue("");
      this._transcriptionInput.setValue("");
    },

    /**
     * Generates and submits the wikicode then inserts the resulting HTML element if no errors occured.
     */
    submit: function () {
      var self = this;

      self._textInput.setDisabled(true);
      self._sourceInput.setDisabled(true);
      self._sourceURLInput.setDisabled(true);
      self._translationInput.setDisabled(true);
      self._transcriptionInput.setDisabled(true);
      this._applyButton.setDisabled(true);
      this._loadingImage.toggle(true);

      // noinspection JSUnresolvedFunction
      var listMarker = "".padStart(this._definitionLevel.length - 1, "#") + "*";

      var code = listMarker + " {{exemple|" + this._textInput.getValue().trim();

      if (this._language !== "fr") {
        var translation = this._translationInput.getValue().trim();
        var transcription = this._transcriptionInput.getValue().trim();
        if (translation) {
          code += "|" + translation;
        }
        if (transcription) {
          code += "|tr=" + transcription;
        }
      }

      var source = this._sourceInput.getValue().trim();
      if (source) {
        code += "|source=" + source;
      }

      var sourceURL = this._sourceURLInput.getValue().trim();
      if (sourceURL) {
        code += "|lien=" + sourceURL;
      }

      if (this._definitionLevel.length > 2) {
        code += "|tête=" + listMarker;
      }

      code += "|lang={0}}}".format(this._language);

      var sectionIDPattern = new RegExp("^" + this._language + "-(?:(flex)-)?([\\w-]+)-(\\d+)$");
      var match = sectionIDPattern.exec(this._definitionLevel[0]);
      var isInflection = match[1] === "flex";
      var sectionType = match[2];
      var sectionNum = parseInt(match[3]);

      // Insert new example into page’s code
      api.get({
        action: "query",
        titles: mw.config.get("wgPageName"),
        prop: "revisions",
        rvprop: "content",
        rvslots: "main",
      }).then(function (data) {
        var pageContent;
        for (var pageID in data.query.pages) {
          if (data.query.pages.hasOwnProperty(pageID)) {
            // noinspection JSUnresolvedVariable
            pageContent = data.query.pages[pageID].revisions[0].slots.main["*"];
            break;
          }
        }

        // Look for correct language section
        var langSectionRegex = new RegExp("==\\s*{{langue\\|{0}}}\\s*==".format(self._language));
        var langSectionIndex = pageContent.search(langSectionRegex);

        if (langSectionIndex === -1) {
          error();
          return;
        }

        // Look for correct word type section
        var lines = pageContent.slice(langSectionIndex).split("\n");
        var sectionRegex = /^===\s*{{S\|([\wéèà -]+)\|/;

        var targetLineIndex;
        for (targetLineIndex = 0; targetLineIndex < lines.length; targetLineIndex++) {
          var line = lines[targetLineIndex];
          var match = sectionRegex.exec(line);
          if (match && sectionNames[sectionType].includes(match[1])
              // Parameter "num" is absent if there is only one section for this type
              && (line.includes("|num=" + sectionNum) || sectionNum === 1)
              // Check whether the section is an inflection if required
              && (isInflection === line.includes("|flexion"))) {
            break;
          }
        }

        if (targetLineIndex === lines.length) {
          error();
          return;
        }

        // Look for correct definition
        var defIndex = -1;
        var level = 1;
        for (; targetLineIndex < lines.length; targetLineIndex++) {
          var m = /^(#+)[^*#]/.exec(lines[targetLineIndex]);
          if (m) {
            if (level === m[1].length) {
              defIndex++;
              if (self._definitionLevel[level] === defIndex) {
                if (level === self._definitionLevel.length - 1) {
                  break;
                } else {
                  level++;
                  defIndex = -1;
                }
              }
            }
          }
        }

        // Look for last example of current definition
        for (targetLineIndex += 1; targetLineIndex < lines.length; targetLineIndex++) {
          var line_ = lines[targetLineIndex];
          // noinspection JSUnresolvedFunction
          if (!line_.startsWith(listMarker)
              // "exemple" template’s arguments may span several lines
              && !/^\s*\|/.test(line_)) {
            break;
          }
        }

        // Insert new example into page content
        var replace = /#+\*\s*{{exemple\|lang=[^|}]+}}/.test(lines[targetLineIndex - 1]);
        if (replace) {
          // Replace empty template with new example
          lines.splice(targetLineIndex - 1, 1, code);
        } else {
          // Insert new example
          lines.splice(targetLineIndex, 0, code);
        }

        // Submit new page content
        api.edit(mw.config.get("wgPageName"), function (_) {
          return {
            text: pageContent.slice(0, langSectionIndex) + lines.join("\n"),
            summary: "Ajout d’un exemple avec le gadget « {0} » (v{1}).".format(NAME, VERSION),
          };
        }).then(function () {
          api.parse(code).done(function (data) {
            var $renderedExample = $(data).find("ul > li").html();
            var $item;
            // Insert rendered example into page
            if (replace) {
              self._$lastExample.html($renderedExample);
              $item = self._$lastExample;
            } else {
              self._$lastExample.after($item = $("<li>").append($renderedExample));
            }
            $item.css("background-color", "lightgreen");
            setTimeout(function () {
              $item.css("background-color", "inherit");
            }, 1000);
            self._$lastExample = $item;
          });
          self.setVisible(false);
          self.clear();
          $.removeCookie(COOKIE_KEY_TEXT);
          $.removeCookie(COOKIE_KEY_SOURCE);
          $.removeCookie(COOKIE_KEY_SOURCE_URL);
          $.removeCookie(COOKIE_KEY_TRANSLATION);
          $.removeCookie(COOKIE_KEY_TRANSCRIPTION);
          reenable();
        });
      });

      function error() {
        alert("L’exemple n’a pas pu être publié car la page a probablement été modifiée entre temps. " +
            "Veuillez recharger la page et réessayer.");
        $.cookie(COOKIE_KEY_TEXT, self._textInput.getValue());
        $.cookie(COOKIE_KEY_SOURCE, self._sourceInput.getValue());
        $.cookie(COOKIE_KEY_SOURCE_URL, self._sourceURLInput.getValue());
        $.cookie(COOKIE_KEY_TRANSLATION, self._translationInput.getValue());
        $.cookie(COOKIE_KEY_TRANSCRIPTION, self._transcriptionInput.getValue());
        reenable();
      }

      function reenable() {
        self._textInput.setDisabled(false);
        self._sourceInput.setDisabled(false);
        self._sourceURLInput.setDisabled(false);
        self._translationInput.setDisabled(false);
        self._transcriptionInput.setDisabled(false);
        self._applyButton.setDisabled(false);
        self._cancelButton.setDisabled(false);
        self._loadingImage.toggle(false);
      }
    },
  };
});
// </nowiki>
