/**
 * (en)
 * This gadget adds template value suggestion when pressing Ctrl+Space.
 * Upon pressing the keys, if the cursor is inside a supported template,
 * a list of values suggestions will pop up. If some text has already
 * been typed, only values that start with this text will be suggested.
 * The list is updated whenever a key is pressed.
 * ----------------------------------------------------------------------
 * (fr)
 * Ce gadget ajoute la suggestion de valeurs pour certains modèles
 * lorsque l’utilisateur appuie sur Ctrl+Espace. Après avoir appuyé sur
 * ces touches, si le curseur est dans un modèle supporté, une liste de
 * suggestions de valeurs apparait. Si du texte a déjà été entré, seules
 * les valeurs commençant par le texte en question seront suggérées. La
 * liste est mise à jour à chaque fois que l’utilisateur appuie sur une
 * touche.
 * ----------------------------------------------------------------------
 * [[Catégorie:JavaScript du Wiktionnaire|auto-complete]]
 */
$(function () {
  "use strict";

  if (["edit", "submit"].includes(mw.config.get("wgAction"))) {
    console.log("Chargement de Gadget-wikt.auto-complete.js…");

    window.gadget_autoComplete = {
      NAME: "Auto-complétion de modèles",

      VERSION: "1.1",

      /** Maximum number of suggestions to display. */
      _MAX_SUGGESTIONS: 100,

      /**
       * Associates templates to a list of values to suggest.
       * @type {Object<string, Array<string>>}
       */
      _templates: {},

      /** Indicates whether the gadget is making suggestions to the user. */
      _suggestMode: false,

      /** The suggestions jQuery component. */
      _$suggestionBox: null,

      /**
       * The list of suggestions for the current value.
       * @type {Array<Array<string>>}
       */
      _suggestions: [],

      /** The index of the selected suggestion in the list. */
      _suggestionIndex: -1,

      /** The position the cursor is supposed to be at after inserting a suggestion. */
      _cursorPosition: -1,

      /**
       * Initializes this gadget by registering callbacks on
       * the document body and inserting the suggestions box.
       */
      init: function () {
        var self = this;

        $(document.body).keydown(function (event) {
          if (self._suggestMode) {
            if (["ArrowUp", "ArrowDown", "Tab"].includes(event.code)) {
              // Prevent caret from moving and focus from changing
              event.preventDefault();
            }
          }
        });

        $(document.body).keyup(function (event) {
          // Register cursor position for insertion
          self._cursorPosition = wikt.edit.getCursorLocation();

          if (!self._suggestMode) {
            if (event.ctrlKey && event.code === "Space") {
              if (self._suggest()) {
                self._enableSuggestions(true);
              }
            }
          } else {
            var cursorPos = self._cursorPosition;

            if (event.code === "Escape" || event.key === "}") {
              self._enableSuggestions(false);
            } else if (event.code === "ArrowUp") { // FIXME fait nimp avec CodeMirror
              self._selectSuggestion(self._suggestionIndex - 1);
            } else if (event.code === "ArrowDown") { // FIXME fait nimp avec CodeMirror
              self._selectSuggestion(self._suggestionIndex + 1);
            } else if (event.code === "Tab") {
              var text = self._insertSuggestion();
              cursorPos += text.length;
            } else if (!self._suggest()) {
              self._enableSuggestions(false);
            }

            if (["ArrowUp", "ArrowDown", "Tab"].includes(event.code)) {
              wikt.edit.setCursorLocation(cursorPos);
            }
          }
        });

        $(document.body).click(function (event) {
          // Check if click target is inside the suggestions box.
          if ($(event.target).closest(self._$suggestionBox).length) {
            var editBox;
            if (wikt.edit.isCodeMirrorEnabled()) {
              editBox = wikt.edit.getCodeMirror();
            } else {
              editBox = wikt.edit.getEditBox();
            }
            if (editBox) {
              editBox.focus();
            }
            wikt.edit.setCursorLocation(self._cursorPosition);
          } else {
            self._enableSuggestions(false);
          }
        });

        this._$suggestionBox = $('<div id="autocomplete-suggestion-box"><span class="autocomplete-no-suggestions">Aucune suggestion</span><ul></ul></div>');
        $("body").append(this._$suggestionBox);
        this._$suggestionBox.hide();
      },

      /**
       * Declares parameter values for the given template.
       * @param templateName {string} Template’s name.
       * @param templateParameters {Array<string>} Template’s parameter values.
       */
      addTemplateParameters: function (templateName, templateParameters) {
        this._templates[templateName] = templateParameters;
      },

      /**
       * Enables/disables suggestions.
       * @param enable {boolean} True to enable; false to disable.
       * @private
       */
      _enableSuggestions: function (enable) {
        this._suggestMode = enable;
        if (this._suggestMode) {
          this._$suggestionBox.show();
        } else {
          this._$suggestionBox.hide();
        }
      },

      /**
       * Fetches the current template the cursor is in then adds
       * the relevent suggestions to the list.
       * @return {boolean} True if the cursor is in a template and there are suggestions for it.
       * @private
       */
      _suggest: function () {
        var cursorPosition = wikt.edit.getCursorLocation();
        var text = wikt.edit.getText().substring(0, cursorPosition);
        var templateStart = text.lastIndexOf("{{");
        var templateEnd = text.lastIndexOf("}}");

        if (templateStart > templateEnd || templateStart >= 0 && templateEnd === -1) {
          var template = text.substring(templateStart + 2);
          var templateName = template.substring(0, template.indexOf("|"));

          if (templateName && this._templates[templateName]) {
            this._updateSuggestions(
                templateName,
                template.substring(template.lastIndexOf("|") + 1),
                this._templates[templateName]
            );

            return true;
          }
        }

        return false;
      },

      /**
       * Adds to the list the available suggestions for the current template and value.
       * @param templateName {string} The template the cursor is in.
       * @param value {string} The value on the left of the cursor.
       * @param values {Array<string>} The available values for the template and the given value.
       * @private
       */
      _updateSuggestions: function (templateName, value, values) {
        var self = this;
        var $list = this._$suggestionBox.find("ul");
        $list.empty();
        this._suggestions.splice(0, this._suggestions.length); // Clear array

        var filteredValues = values.filter(function (v) {
          // noinspection JSUnresolvedFunction
          return v.toLowerCase().startsWith(value.toLowerCase());
        });

        filteredValues.forEach(function (v, i) {
          if (i >= self._MAX_SUGGESTIONS) {
            return;
          }

          var prefix = v.substr(0, value.length);
          var rest = v.substr(value.length);
          var $item = $('<li><span class="autocomplete-highlight">{0}</span>{1}</li>'.format(prefix, rest));

          $item.click(function () {
            self._selectSuggestion(i);
            self._insertSuggestion();
          });
          $list.append($item);
          self._suggestions.push([prefix, rest]);
        });

        var $message = this._$suggestionBox.find("span:not(.autocomplete-highlight)");
        if (filteredValues.length) {
          this._selectSuggestion(0);
          $message.hide();
        } else {
          this._suggestionIndex = -1;
          $message.show();
        }
      },

      _selectSuggestion: function (i) {
        if (this._suggestions.length !== 0) {
          var m = this._suggestions.length;
          this._suggestionIndex = ((i % m) + m) % m; // True modulo operation
          this._$suggestionBox.find("ul li").removeClass("autocomplete-selected");
          this._$suggestionBox.find("ul li:nth-child({0})".format(this._suggestionIndex + 1))
              .addClass("autocomplete-selected");
        }
      },

      _insertSuggestion: function () {
        if (this._suggestionIndex !== -1) {
          var cursorPosition = wikt.edit.getCursorLocation();
          var suggestionPrefix = this._suggestions[this._suggestionIndex][0];
          var suggestionSuffix = this._suggestions[this._suggestionIndex][1];

          // Replace already typed text by the start of the selected suggestion.
          wikt.edit.replaceText(this._cursorPosition - suggestionPrefix.length, this._cursorPosition, suggestionPrefix);
          // Insert the rest of the suggestion on the right of the cursor.
          wikt.edit.insertText(cursorPosition, suggestionSuffix);
          this._cursorPosition += suggestionSuffix.length;
          this._enableSuggestions(false);

          return suggestionSuffix;
        }

        return "";
      },
    };

    window.gadget_autoComplete.init();

    /**
     * Converts the given string representing a LUA table to a JSON object.
     * @param rawLua {string} The string containing the LUA table.
     * @return {Object} The corresponding JSON object.
     */
    var luaDataPageToJson = function (rawLua) {
      var startToken = "-- $Table start$\n";
      var startIndex = rawLua.indexOf(startToken);
      var endIndex = rawLua.indexOf("-- $Table end$");
      var rawParams = rawLua.substring(startIndex === -1 ? 0 : startIndex + startToken.length, endIndex === -1 ? rawLua.length : endIndex)
          .replaceAll(/--.+$/gm, "") // Remove comments
          .replaceAll(/^local\s+.+?=\s*(?={)/gm, "") // Remove assignment
          .replaceAll(/^(\s*)\[(['"])(.+?)\2]\s*=/gm, '$1"$3":') // Convert Lua keys syntax to JS
          .replaceAll(/(')(.*?[^\\])\1/g, '"$2"') // Convert ' to "
          .replaceAll(/\\'/g, "'") // Unescape single quotes
          .replaceAll(/(\w+)\s*=/g, '"$1":') // Add quotes on unquoted keys
          .replaceAll(/,(?=\s*})/gm, "") // Remove trailing commas
          .replaceAll(/{([^:]*?)}/gm, "[$1]") // Convert Lua lists to JS
          .replaceAll(/^\s*return.+$/gm, ""); // Remove "return" statement

      return JSON.parse(rawParams);
    };

    /**
     * Utility function that adds support to the given template that uses a single data module.
     * @param templateName {string} Template’s name without "Template:".
     * @param moduleName {string} Name of the module used by the template without "Module:".
     *                   Must have a /data subpage returning a table holding the authorized values.
     */
    var addTemplate = function (templateName, moduleName) {
      $.get(
          "https://fr.wiktionary.org/wiki/Module:{0}/data?action=raw".format(encodeURIComponent(moduleName)),
          function (data) {
            try {
              window.gadget_autoComplete.addTemplateParameters(templateName, Object.keys(luaDataPageToJson(data)));
            } catch (e) {
              console.log("An error occured while parsing LUA table for [[Module:{0}/data]] ([[Template:{1}]])".format(moduleName, templateName));
            }
          }
      );
    }

    // [[Modèle:langue]], [[Module:langues/data]]
    $.get(
        "https://fr.wiktionary.org/wiki/MediaWiki:Gadget-translation editor.js/langues.json?action=raw",
        function (data) {
          try {
            window.gadget_autoComplete.addTemplateParameters("langue", Object.keys(JSON.parse(data)));
          } catch (e) {
            console.log("An error occured while parsing JSON for [[MediaWiki:Gadget-translation editor.js/langues.json]] ([[Template:langue]]): " + e);
          }
        }
    );
    // [[Modèle:lexique]], [[Module:lexique/data]]
    addTemplate("lexique", "lexique");
    // [[Modèle:info lex]], [[Module:lexique/data]]
    addTemplate("info lex", "lexique");
    // [[Modèle:S]], [[Module:section article/data]], [[Module:types de mots/data]]
    $.get(
        "https://fr.wiktionary.org/wiki/Module:section_article/data?action=raw",
        function (data) {
          try {
            var sectionIds = Object.keys(luaDataPageToJson(data)["texte"]);
            $.get(
                "https://fr.wiktionary.org/wiki/Module:types_de_mots/data?action=raw",
                function (data) {
                  try {
                    var wordTypes = Object.keys(luaDataPageToJson(data)["texte"]);
                    window.gadget_autoComplete.addTemplateParameters("S", sectionIds.concat(wordTypes));
                  } catch (e) {
                    console.log("An error occured while parsing LUA table for [[Module:types de mots/data]] ([[Template:S]]): " + e);
                  }
                }
            );
          } catch (e) {
            console.log("An error occured while parsing LUA table for [[Module:section article/data]] ([[Template:S]]): " + e);
          }
        }
    );
  }
});
