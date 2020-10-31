// Cet outil remplace les modèles dans les résumés d'édition par un id de section non ambigu
// (ou un titre, quand il n'y a pas d'id qui soit non ambigu).
$(function () {
  // On ajoute &summary=/* summary */ à chaque lien de modification.
  if (mw.config.get("wgAction") === "view") {
    $(".mw-editsection").each(function () {
      // noinspection JSUnresolvedFunction
      var firstChild = $(this).prev(".mw-headline").children().first();
      if (!firstChild.length) {
        return;
      }
      var sectionClass = firstChild.attr("class");
      var langSectionNb = $(".mw-parser-output > h2").length;
      var summary;
      if (langSectionNb === 1 || sectionClass !== "titredef") {
        summary = "/* " + $(this).prev(".mw-headline").attr("id").replace(/_/g, " ") + " */%20";
      } else {
        summary = "/* " + firstChild.attr("id") + " */%20";
      }
      // When "Show me both editor tabs" enabled, there will be two links: visual and wikitext.
      $(this).find("a").attr("href", function (i, href) {
        return href + "&summary=" + summary;
      });
    });
  }
});
