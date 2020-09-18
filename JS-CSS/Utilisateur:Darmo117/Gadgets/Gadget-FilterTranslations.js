/**
 * (fr)
 * Ce gadget masque les traductions qui ne sont pas dans la liste définie
 * dans le common.js de l’utilisateur. Voir [[Aide:Gadget-FilterTranslations]].
 * ----
 * (en)
 * This gadget filters out translations that are not listed in the user’s
 * common.js. See [[Aide:Gadget-FilterTranslations]] (fr).
 * ----
 * [[Catégorie:JavaScript du Wiktionnaire|FilterTranslations.js]]
 */

window.wikt.gadgets.filterTranslations = {
  NAME: "Filtrer traductions",

  VERSION: "1.0",

  /**
   * Sets the whitelisted language codes then filters the translations.
   * @param whitelistedLangs {Array<string>} Language codes to whitelist.
   */
  init: function (whitelistedLangs) {
    whitelistedLangs = whitelistedLangs || [];

    $(".translations > ul > li").each(function () {
      var $item = $(this);
      var match = /trad-(\w+)/.exec($item.find("span").prop("class"));

      if (match && !whitelistedLangs.includes(match[1])) {
        $item.hide(); // TODO permettre de réafficher les traductions cachées
      }
    });
  },
};

(function () {
  if (wikt.page.hasNamespaceIn([""])) {
    var username = mw.config.get("wgUserName");
    var url = "https://fr.wiktionary.org/wiki/User:{0}/filterTranslations.js?action=raw&ctype=text/javascript".format(username);
    var wg = wikt.gadgets;
    wikt.loadScripts([url]).done(function () {
      console.log("Chargement de Gadget-FilterTranslations.js…");
      try {
        if (whitelist instanceof Array) {
          wg.filterTranslations.init(whitelist); // Variable should be declared in user page.
        }
      }
      catch (e) {
        console.log("Gadget-FilterTranslations.js: Variable 'whitelist' non définie.");
      }
    });
  }
})();
