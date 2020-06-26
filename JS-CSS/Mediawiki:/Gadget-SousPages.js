/**
 [[Catégorie:JavaScript du Wiktionnaire|SousPages.js]]
 * Sous-pages
 *
 * Place un bouton "afficher les sous-pages" dans la boîte à outils
 *
 * Auteur initial : Delhovlyn
 */
mw.loader.using('mediawiki.util', function () {
  var nsWithoutSubpages = [-1, 0, 6, 14];
  var ns = mw.config.get('wgNamespaceNumber');
  if ($.inArray(ns, nsWithoutSubpages) == -1) {
    var lienSouspages = '/wiki/Special:PrefixIndex/' + mw.config.get('wgPageName') + '/';
    mw.util.addPortletLink('p-tb', lienSouspages, 'Sous-pages', 't-subpages', 'Sous-pages de cette page');
  }
});
