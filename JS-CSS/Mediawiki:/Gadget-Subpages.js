/*
 * (fr)
 * Ce gadget ajoute un bouton à côté du titre de la page courante
 * pour récupérer la liste de toutes ses sous-pages.
 * (en)
 * This gadget adds a button next to the current page’s title to
 * fetch all of its subpages.
 */

window.wikt.gadgets.subpages = {
  NAME: "Sous-pages",

  VERSION: "1.0",

  init: function () {
    wikt.page.addButtonAfterTitle([{
      "text": "Sous-pages",
      "title": "Affiche les sous pages de la page courante.",
      "callback": this.fetchSubpages,
    }])
  },

  /**
   * Fecthes the list of subpages through the API then displays the
   * result in an promt popup.
   */
  fetchSubpages: function () {
    var url = "https://fr.wiktionary.org/wiki/Spécial:Index?prefix={0}&namespace={1}"
        .format(encodeURI(wikt.page.getCurrentPageTitle() + "/"), wikt.page.getCurrentPageNamespaceId());
    window.open(url);
  }
};

(function () {
  console.log("Chargement de Gadget-Subpages.js…");
  wikt.gadgets.subpages.init();
})();
