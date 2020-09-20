/**
 * This gadget adds buttons to add examples below definitions.
 * It only activates in the main and Reconstruction namespaces.
 */
window.wikt.gadgets.ajouterCitation = {
  NAME: "Ajouter citations",

  VERSION: "1.0",

  /**
   * Initializes this gadget.
   */
  init: function () {
    var self = this;

    $("ol > li").each(function (i, e) {
      var $definition = $(e);
      // FIXME
      var $quotes = $definition.find("ul:first");
      var $button = $('<a href="#" style="font-size: 80%">Ajouter un exemple</a>');
      $button.on("click", function (e) {
        self._addQuote($(e.target), $quotes);
      });

      if (!$quotes.length) {
        $quotes = $("<ul>");
        $definition.append($quotes);
      }
      var $item = $("<li>");
      $item.append($button);
      $quotes.prepend($item);
    });
  },

  // TODO supprimer {{ébauche-exe}} si présent
  _addQuote: function ($element, $quotes) {
    // DEBUG
    console.log($element, $quotes);
    // TODO
  },
};

(function () {
  if (wikt.page.hasNamespaceIn([""])) {
    wikt.gadgets.ajouterCitation.init();
  }
})();
