"use strict";

console.log("Chargement de Gadget-wikt.highlight-missing-sections.js…");

window.wikt.gadgets.highlightMissingSections = {
  /** @type {Array<string>} */
  _languages: [],

  /** @type {Array<Object<string, Object>>} */
  _links: [],

  init: function () {
    var self = this;
    $.get(
        "https://fr.wiktionary.org/wiki/Module:langues/data?action=raw",
        function (data) {
          self._onResponse.apply(self, [data]);
        }
    );
  },

  /**
   * Callback function called when the GET query succeeds.
   * @param luaCode {string} The Lua source code of the [[Module:langues/data]] page.
   * @private
   */
  _onResponse: function (luaCode) {
    var self = this;
    this._languages = this._extractLangCodes(luaCode);

    $(".mw-parser-output a:not(.new)").each(function (_, link) {
      var $link = $(link);
      var match = /^\/wiki\/(.+?)#(.+)$/.exec($link.attr("href"));

      if (match) {
        var pageTitle = match[1];
        var namespace = pageTitle.substring(0, pageTitle.indexOf(":")).toLowerCase();
        var anchor = match[2];
        var namespaces = mw.config.get("wgNamespaceIds");

        if (self._languages.includes(anchor) && !namespaces[namespace] && !self._languages.includes(namespace)) {
          self._links.push({
            $link: $link,
            pageTitle: pageTitle,
            langCode: anchor
          });
        }
      }
    });

    this._links.forEach(function (item) {
      $.get(
          "/wiki/{0}?action=raw".format(item.pageTitle),
          function (pageCode) {
            self._highlightLink(item.$link, item.langCode, pageCode);
          }
      );
    })
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

  /**
   * Extracts all language codes from the given Lua source code.
   * @param rawLua {string} The Lua source code.
   * @returns {Array<string>} The list of language codes.
   * @private
   */
  _extractLangCodes: function (rawLua) {
    var regex = /^l\['(.+?)']/gm;
    var match;
    var codes = [];

    while (match = regex.exec(rawLua)) {
      if (match) {
        codes.push(match[1]);
      }
    }

    return codes;
  },
};

wikt.gadgets.highlightMissingSections.init();
