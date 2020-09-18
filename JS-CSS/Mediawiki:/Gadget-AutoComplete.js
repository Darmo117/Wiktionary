$(function () {
  "use strict";

  if (["edit", "submit"].includes(mw.config.get("wgAction"))) {
    console.log("Chargement de Gadget-AutoComplete.js…");

    window.wikt.gadgets.autoComplete = {
      NAME: "Auto-complétion du wikicode",

      VERSION: "1.0",

      /**
       * Associates templates to a list of values to suggest.
       * @type {Object<string, Array<string>>}
       */
      _templates: {},

      /**
       * Indicates whether the gadget is making suggestions to the user.
       * @type {boolean}
       */
      _suggestMode: false,

      /**
       * The suggestions jQuery component.
       */
      _$suggestionBox: null,

      /**
       * The list of suggestions for the current value.
       * @type {Array<string>}
       */
      _suggestions: [],

      /**
       * The index of the selected suggestion in the list.
       * @type {number}
       */
      _suggestionIndex: -1,

      /**
       * The position the cursor is supposed to be at after inserting a suggestion.
       * @type {number}
       */
      _cursorPosition: -1,

      /**
       * Initializes this gadget by registering callbacks on
       * the document body and inserting the suggestions box.
       */
      init: function () {
        var self = this;

        $(document.body).keydown(function (event) {
          if (self._suggestMode) {
            var cursorPos = wikt.edit.getCursorLocation();

            if (["ArrowUp", "ArrowDown", "Tab"].includes(event.code)) {
              // Prevent caret from moving and focus from changing
              event.preventDefault();
              // Register cursor position as preventDefault has no effect with CodeMirror
              self._cursorPosition = cursorPos;
            }
          }
        });

        $(document.body).keyup(function (event) {
          console.log(self._suggestMode);
          if (!self._suggestMode) {
            if (event.ctrlKey && event.code === "Space") {
              if (self._suggest()) {
                self._enableSuggestions(true);
              }
            }
          }
          else {
            var cursorPos = self._cursorPosition;

            if (event.code === "Escape" || event.key === "}") {
              self._enableSuggestions(false);
            }
            else if (event.code === "ArrowUp") {
              self._selectSuggestion(self._suggestionIndex - 1);
            }
            else if (event.code === "ArrowDown") {
              self._selectSuggestion(self._suggestionIndex + 1);
            }
            else if (event.code === "Tab") {
              var text = self._insertSuggestion();
              cursorPos += text.length;
            }
            else if (!self._suggest()) {
              self._enableSuggestions(false);
            }

            if (["ArrowUp", "ArrowDown", "Tab"].includes(event.code)) {
              console.log(cursorPos); // DEBUG
              // FIXME curseur non repositionné avec CodeMirror mais valeur correcte
              wikt.edit.setCursorLocation(cursorPos);
              console.log("curseur bougé"); // DEBUG
            }
          }
        });

        $(document.body).click(function (event) {
          if ($(event.target).closest(self._$suggestionBox).length) {
            var editBox = wikt.edit.getEditBox();
            if (editBox) {
              editBox.focus(); // FIXME marche pas avec CodeMirror
            }
          }
          else {
            self._enableSuggestions(false);
          }
        });

        this._$suggestionBox = $('<div id="ac-suggestion-box"><ul></ul></div>');
        $("body").append(this._$suggestionBox);
        this._$suggestionBox.hide();
      },

      /**
       * Declares parameter values for the given template.
       * @param templateName Template’s name.
       * @param templateParameters Template’s parameter values.
       */
      addTemplateParameters: function (templateName, templateParameters) {
        this._templates[templateName] = templateParameters;
      },

      /**
       * Enables/disables suggestions.
       * @param enable True to enable; false to disable.
       * @private
       */
      _enableSuggestions: function (enable) {
        this._suggestMode = enable;
        if (this._suggestMode) {
          this._$suggestionBox.show();
        }
        else {
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
        var $list = this._$suggestionBox.find("ul");
        $list.empty();
        this._suggestions.splice(0, this._suggestions.length); // Clear array
        var self = this;

        values.filter(function (v) {
          return v.toLowerCase().startsWith(value.toLowerCase());
        }).forEach(function (v, i) {
          var prefix = v.substr(0, value.length);
          var rest = v.substr(value.length);
          var $item = $('<li><span class="ac-highlight">{0}</span>{1}</li>'.format(prefix, rest));

          $item.click(function () {
            self._selectSuggestion(i);
            self._insertSuggestion();
          });
          $list.append($item);
          self._suggestions.push(rest);
        });

        if (values.length) {
          this._selectSuggestion(0);
        }
        else {
          this._suggestionIndex = -1;
        }
      },

      _selectSuggestion: function (i) {
        if (this._suggestions.length !== 0) {
          var m = this._suggestions.length;
          this._suggestionIndex = ((i % m) + m) % m; // True modulo operation
          this._$suggestionBox.find("ul li").removeClass("ac-selected");
          this._$suggestionBox.find("ul li:nth-child({0})".format(this._suggestionIndex + 1)).addClass("ac-selected");
        }
      },

      _insertSuggestion: function () {
        // var text = wikt.edit.getText();
        var cursorPosition = wikt.edit.getCursorLocation();
        var suggestion = this._suggestions[this._suggestionIndex];
        // var newText = text.substring(0, cursorPosition) + suggestion + text.substring(cursorPosition);
        // wikt.edit.setText(newText)
        wikt.edit.insertText(cursorPosition, suggestion);
        this._enableSuggestions(false);

        return suggestion;
      },
    };

    window.wikt.gadgets.autoComplete.init();

    var luaTableToJson = function (rawLua) {
      var rawParams = rawLua
          .replaceAll(/^local\s+.+?=\s*(?={)/gm, "") // Remove assignment
          .replaceAll(/^(\s*)\[(['"])(.+?)\2]\s*=/gm, '$1"$3":') // Convert Lua keys syntax to JS
          .replaceAll(/(')(.+?)\1/g, '"$2"') // Convert ' to "
          .replaceAll(/,(?=\s*})/gm, "") // Remove trailing commas
          .replaceAll(/{([^:]*?)}/gm, "[$1]") // Convert Lua lists to JS
          .replaceAll(/^\s*return.+$/gm, ""); // Remove "return" statement

      return JSON.parse(rawParams);
    };

    // values for {{lexique}} template
    $.get(
        "https://fr.wiktionary.org/wiki/Module:lexique/data?action=raw",
        function (data) {
          window.wikt.gadgets.autoComplete.addTemplateParameters("lexique", Object.keys(luaTableToJson(data)));
        }
    );
  }
});
