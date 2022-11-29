// ==UserScript==
// @name         Préférences Wiktionnaire
// @namespace    http://www.darmo-creations.net/
// @version      0.1
// @description  Add links to gadget sources from preferences page.
// @author       Darmo117
// @match        https://fr.wiktionary.org/wiki/Sp%C3%A9cial:Pr%C3%A9f%C3%A9rences
// @icon         https://fr.wiktionary.org/static/favicon/piece.ico
// @grant        none
// ==/UserScript==
// <nowiki>
(function () {
  "use strict";

  // Disable unless in Special:Preferences
  if (mw.config.get("wgCanonicalNamespace") !== "Special"
      || mw.config.get("wgCanonicalSpecialPageName") !== "Preferences") {
    return;
  }

  /**
   * @param gadgetsDefinition {string} Source code of [[MediaWiki:Gadgets-definition]].
   */
  function addSourceLinks(gadgetsDefinition) {
    /**
     * @param pageName {string}
     * @param text {string|null}
     * @return {HTMLElement}
     */
    function getLink(pageName, text) {
      const $link = $(`<a>${text || pageName}</a>`);
      $link.attr("href", "/wiki/Mediawiki:Gadget-" + pageName);
      $link.attr("target", "_blank");
      return $link;
    }

    /**
     * @param values {string}
     * @return {string[]}
     */
    function split(values) {
      return $.map(values.split("|"), s => s.trim()).filter(s => s !== "");
    }

    // Grab all checkbox fields for the gadgets tab
    $("#mw-prefsection-gadgets .mw-htmlform-field-HTMLCheckField").each((_, element) => {
      const $element = $(element);
      const gadgetName = $element.data("ooui").fieldWidget.tag;
      const gadgetDefPage = gadgetName.substr("mw-input-wpgadget-".length);
      const regex = new RegExp(
          `^\\*\\s*${gadgetDefPage.replace(".", "\\.")}\\s*\\[(?<options>.+?)](?<sources>.+)$`,
          "m"
      );
      const match = regex.exec(gadgetsDefinition);
      if (match) {
        const options = split(match.groups.options);
        const sources = split(match.groups.sources);
        const $links = $('<span style="font-size: 0.8em">');
        if (options.includes("default")) {
          $links.append('<span style="font-weight: bold">(Activé par défaut)</span> ');
        }
        if (options.includes("requiresES6")) {
          $links.append('<span style="font-weight: bold">(ES6+)</span> ');
        }
        $links.append(getLink(gadgetDefPage, "Description"));
        if (sources.length) {
          $links.append(" - Sources\u00a0: ");
        }
        for (const [i, source] of sources.entries()) {
          if (i > 0) {
            $links.append(", ");
          }
          $links.append(getLink(source, null));
        }
        const dependencies = options.filter(e => e.startsWith("dependencies="));
        if (dependencies.length) {
          const deps = dependencies[0].substr("dependencies=".length).split(",");
          $links.append(" - Dépendances\u00a0: ");
          for (const [i, dep] of deps.entries()) {
            if (i > 0) {
              $links.append(", ");
            }
            $links.append(dep);
          }
        }
        $element.find("label").append("<br>").append($links);
      }
    });
  }

  $.get(
      "https://fr.wiktionary.org/wiki/MediaWiki:Gadgets-definition",
      {
        action: "raw",
        ctype: "text/javascript",
      },
      addSourceLinks
  );
})();
// </nowiki>
