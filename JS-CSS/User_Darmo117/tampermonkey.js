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

    /**
     * @param imageURL {string}
     * @param alt {string}
     * @return {string}
     */
    function getImage(imageURL, alt) {
      return `<img alt="${alt}" title="${alt}" style="height: 12px" src="${imageURL}"> `;
    }

    /**
     * @param rawOptions {string}
     * @return {Object<string, string[]>}
     */
    function extractOptions(rawOptions) {
      const options = {};
      for (const rawOption of split(rawOptions)) {
        if (rawOption.includes("=")) {
          const [option, values] = rawOption.split("=");
          options[option] = values.split(",");
        } else {
          options[rawOption] = [];
        }
      }
      return options;
    }

    function formatList($links, values, text, f) {
      f = f || (v => v);
      $links.append(` - ${text}\u00a0: `);
      for (const [i, value] of values.entries()) {
        if (i > 0) {
          $links.append(", ");
        }
        $links.append(f(value));
      }
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
        const options = extractOptions(match.groups.options);
        const sources = split(match.groups.sources);
        const $links = $('<span style="font-size: 0.8em">');

        if (options["default"]) {
          $links.append(getImage(
              "https://upload.wikimedia.org/wikipedia/commons/8/8e/OOjs_UI_icon_flag-ltr-progressive.svg",
              "Activé par défaut"
          ));
        }
        if (options["requiresES6"]) {
          $links.append(getImage(
              "https://uploads.toptal.io/blog/category/logo/120618/ECMAScript-2e939bbfa79342dcfcdbb9744afb2a50.png",
              "ES6+"
          ));
        }
        if (!options["targets"] || options["targets"].includes("desktop")) {
          $links.append(getImage(
              "https://upload.wikimedia.org/wikipedia/commons/0/05/OOjs_UI_icon_desktop-progressive.svg",
              "Desktop"
          ));
        }
        if (options["targets"] && options["targets"].includes("mobile")) {
          $links.append(getImage(
              "https://upload.wikimedia.org/wikipedia/commons/3/34/OOjs_UI_icon_mobile-progressive.svg",
              "Mobile"
          ));
        }
        // Cannot compare arrays directly, compare their JSON string representations
        if (JSON.stringify(options["type"]) === JSON.stringify(["styles"])) {
          $links.append(getImage(
              "https://upload.wikimedia.org/wikipedia/commons/d/d5/CSS3_logo_and_wordmark.svg",
              "Style seulement"
          ));
        }

        // Description
        $links.append(getLink(gadgetDefPage, "Description"));

        // Sources
        if (sources.length) {
          formatList($links, sources, "Sources", getLink);
        }
        // Rights
        if (options["rights"]) {
          formatList($links, options["rights"], "Droits");
        }
        // Dependencies
        if (options["dependencies"]) {
          formatList($links, options["dependencies"], "Dépendances");
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
