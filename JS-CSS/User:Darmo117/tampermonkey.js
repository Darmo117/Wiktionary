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
      var $link = $("<a>" + (text || pageName) + "</a>");
      $link.attr("href", "/wiki/Mediawiki:Gadget-" + pageName);
      $link.attr("target", "_blank");
      return $link;
    }

    /**
     * @param values {string}
     * @return {string[]}
     */
    function split(values) {
      return $.map(values.split("|"), function (s) {
        return s.trim();
      }).filter(function (s) {
        return s !== "";
      });
    }

    // Grab all checkbox fields for the gadgets tab
    $("#mw-prefsection-gadgets .mw-htmlform-field-HTMLCheckField").each(function (_, element) {
      var $element = $(element);
      var gadgetName = $element.data("ooui").fieldWidget.tag;
      var gadgetDefPage = gadgetName.substr("mw-input-wpgadget-".length);
      var regex = new RegExp(
          "^\\*\\s*" + gadgetDefPage.replace(".", "\\.") + "\\s*\\[(?<options>.+?)\\](?<sources>.+)$",
          "m"
      );
      var match = regex.exec(gadgetsDefinition);
      if (match) {
        var options = split(match.groups.options);
        // noinspection JSUnresolvedVariable
        var sources = split(match.groups.sources);
        var $links = $("<span style='font-size: 0.8em'>");
        if (options.includes("default")) {
          $links.append("<span style='font-weight: bold'>(Activé par défaut)</span> ");
        }
        $links.append(getLink(gadgetDefPage, "Définition"));
        if (sources.length) {
          $links.append(" - Sources\u00a0: ");
        }
        for (var i = 0; i < sources.length; i++) {
          if (i > 0) {
            $links.append(", ");
          }
          $links.append(getLink(sources[i], null));
        }
        var dependencies = options.filter(function (e) {
          // noinspection JSUnresolvedFunction
          return e.startsWith("dependencies=");
        });
        if (dependencies.length) {
          var deps = dependencies[0].substr("dependencies=".length).split(",");
          $links.append(" - Dépendances\u00a0: ");
          for (var j = 0; j < deps.length; j++) {
            if (j > 0) {
              $links.append(", ");
            }
            $links.append(deps[j]);
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
