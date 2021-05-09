/**********************************************************************
 * (en)
 * This gadget highlights all blue links that feature an anchor which
 * corresponds to a language code but the pointed page does not
 * contain a section for this language code.
 **********************************************************************
 * (fr)
 * Ce gadget surligne tout les liens bleus possédant une ancre
 * correspondant à un code de langue mais dont la page pointée ne
 * contient pas de section pour le code en question.
 **********************************************************************
 * [[Catégorie:JavaScript du Wiktionnaire|highlight missing sections]]
 **********************************************************************/
"use strict";

if (mw.config.get("wgAction") === "view") {
  console.log("Chargement de Gadget-wikt.highlight-missing-sections.js…");

  window.wikt.gadgets.highlightMissingSections = {
    NAME: "Highlight Missing Sections",

    VERSION: "1.0",

    init: function () {
      $.get(
          "https://fr.wiktionary.org/wiki/MediaWiki:Gadget-translation_editor.js/langues.json?action=raw",
          (function (languages) {
            this._onResponse($.map(JSON.parse(languages), function (_, k) {
              return k;
            }));
          }).bind(this)
      );
    },

    /**
     * Callback function called when the GET query succeeds in init().
     * @param languages {Array<string>} The array containing language codes.
     * @private
     */
    _onResponse: function (languages) {
      var links = [];

      $(".mw-parser-output a:not(.new)").each(function (_, link) {
        var $link = $(link);
        var match = /^https:\/\/fr\.wiktionary\.org\/wiki\/(.+?)#(.+)$/.exec($link.prop("href"));

        if (match) {
          var pageTitle = match[1];
          var namespace = pageTitle.substring(0, pageTitle.indexOf(":")).toLowerCase();
          var anchor = match[2];
          var namespaces = mw.config.get("wgNamespaceIds");

          // Vérifie que le lien pointe vers l’espace principal, pas vers un autre wiki et que l’ancre est un code de langue
          if (languages.includes(anchor) && !namespaces[namespace] && !languages.includes(namespace)) {
            links.push({
              $link: $link,
              pageTitle: pageTitle,
              langCode: anchor
            });
          }
        }
      });

      var self = this;
      // Cache page codes in case same page is linked to several times
      var pageCodes = {};
      links.forEach(function (item) {
        if (!pageCodes[item.pageTitle]) {
          $.get(
              "https://fr.wiktionary.org/wiki/{0}?action=raw".format(item.pageTitle),
              function (pageCode) {
                pageCodes[item.pageTitle] = pageCode;
                self._highlightLink(item.$link, item.langCode, pageCodes[item.pageTitle]);
              }
          );
        } else {
          self._highlightLink(item.$link, item.langCode, pageCodes[item.pageTitle]);
        }
      });
    },

    /**
     * Highlights the given link if the target page doesn’t
     * feature a section for the given language code.
     * @param $link {Object} The jQuery link object.
     * @param langCode {string} The language code.
     * @param pageCode {string} The code of the page the link points to.
     * @private
     */
    _highlightLink: function ($link, langCode, pageCode) {
      if (!pageCode.includes("{{langue|{0}}}".format(langCode))) {
        $link.addClass(["wikt-missing-entry", "wikt-missing-entry-{0}".format(langCode)]);
        $link.attr("title", $link.attr("title") + " (section « {0} » manquante)".format(langCode))
      }
    },
  };

  wikt.gadgets.highlightMissingSections.init();
}
