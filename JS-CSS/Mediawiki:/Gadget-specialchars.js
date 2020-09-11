/********************************************************************
 * (en)
 * On-the-fly character substitution when in edit mode.
 * Enables typing characters that are missing from the French AZERTY
 * keyboard.
 ********************************************************************
 * (fr)
 * Remplacement à la volée de certains caractères lors de l’édition.
 * Pensé pour les caractères absents du clavier AZERTY français pour
 * écrire le français.
 ********************************************************************
 * [[Catégorie:JavaScript du Wiktionnaire|specialchars.js]]
 ********************************************************************/

window.wikt.gadgets.specialChars = {
  NAME: "Caractères spéciaux",

  VERSION: "2.0",

  _TAGS: {
    "$ae": "æ",
    "$AE": "Æ",
    "$oe": "œ",
    "$OE": "Œ",
    "$aa": "ā",
    "$AA": "Ā",
    "$ii": "ī",
    "$II": "Ī",
    "$ee": "ē",
    "$EE": "Ē",
    "$oo": "ō",
    "$OO": "Ō",
    "$uu": "ū",
    "$UU": "Ū",
    "...": "…",
    "$s": "ſ",
    "$à": "À",
    "$é": "É",
    "$è": "È",
    "$ç": "Ç",
    "$.": "·",
    "$-": "–", // En dash
    "$_": "—", // Em dash
    "<<": "«\u00a0",
    ">>": "\u00a0»",
    "$ù": "Ù",
    "$,": "ʻ",
  },

  _elements: [],

  init: function () {
    var self = this;

    function onKeyUp(e) {
      self.parse($(e.target))
    }

    function fetchTextInput(nodeTree) {
      var $element = $(nodeTree);
      var tagName = $element.prop("tagName");
      var elements = [];

      if (tagName === "TEXTAREA" || tagName === "INPUT" && ["text", "search"].includes($element.attr("type"))) {
        elements.push($element);
      }

      for (var i = 0; i < nodeTree.children.length; i++) {
        if ($element = fetchTextInput(nodeTree.children[i])) {
          elements.concat($element);
        }
      }

      return elements;
    }

    if (wikt.edit.isCodeMirrorEnabled()) {
      wikt.edit.getCodeMirror().on("keyup", function () {
        console.log("cm keyup"); // DEBUG
        self.parse(wikt.edit.getEditBox());
      });
    }
    $("input[type=text]").keyup(onKeyUp).each(function (e) {
      self._elements.push(e);
    });
    $("input[type=search]").keyup(onKeyUp).each(function (e) {
      self._elements.push(e);
    });
    $("textarea").keyup(onKeyUp).each(function (e) {
      self._elements.push(e);
    });
    console.log(self._elements); // DEBUG
    wikt.page.onDOMChanges(function (mutationsList) {
      mutationsList.forEach(function (mutation) {
        if (mutation.type === "childList") {
          console.log(mutation.target); // DEBUG
          fetchTextInput(mutation.target).forEach(function ($element) {
            console.log($element); // DEBUG
            if ($element && !self._elements.includes($element[0])) {
              $element.keyup(onKeyUp);
              self._elements.push($element[0]);
            }
          });
        }
      });
    }, document.body, {subtree: true, childList: true});
    this._previousText = {};
  },

  parse: function ($input) {
    console.log($input); // DEBUG
    var text = wikt.edit.getText($input);

    if (text !== this._previousText[$input]) {
      var cursorPos = wikt.edit.getCursorLocation($input);
      var newPos = -1;
      var start, end;

      if (!wikt.edit.getSelectedText($input)) {
        // Do not replace apostrophes when in file name.
        var inMedia = /\[\[(Fichier|File|Image|Média|Media):[^|\]]+?$/i
            .test(text.substring(0, cursorPos));

        if (!inMedia && text.charAt(cursorPos - 1) === "'") {
          start = cursorPos - 2;
          end = cursorPos;
          var before = text.charAt(start);
          var quotes;

          if (before === "\\") {
            quotes = "'";
            newPos = cursorPos - 1;
          }
          else {
            quotes = before + "’";

            if (quotes === "’’" || quotes === "'’") {
              quotes = "''";
            }
            newPos = cursorPos;
          }
          text = text.substring(0, start) + quotes + text.substring(end);
        }
        else {
          for (var tag in this._TAGS) {
            if (this._TAGS.hasOwnProperty(tag)) {
              start = cursorPos - tag.length;
              end = cursorPos;
              var sub = text.substring(start, end);

              if (sub === tag) {
                var repl = this._TAGS[tag];
                text = text.substring(0, start) + repl + text.substring(end);
                newPos = start + repl.length;
                break;
              }
            }
          }
        }

        if (newPos >= 0) {
          wikt.edit.setText(text, $input);
          wikt.edit.setCursorLocation(newPos, $input);
        }
      }

      this._previousText[$input] = text;
    }
  },
};

(function () {
  // Do not enable gadget on JS, CSS nor module pages.
  var isJsPage = mw.config.get("wgTitle").endsWith(".js");
  var isCssPage = mw.config.get("wgTitle").endsWith(".css");
  var isModule = wikt.page.hasNamespaceIn(["Module"]);

  if (!isJsPage && !isCssPage && !isModule) {
    console.log("Chargement de Gadget-specialchars-dev.js…");
    wikt.gadgets.specialChars.init();
  }
})();
