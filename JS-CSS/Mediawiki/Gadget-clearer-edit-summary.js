/**
 * Cet outil remplace les modèles dans les résumés d'édition par un nom lisible,
 * en listant le fil d’Ariane de la section modifiée.
 */
$(function () {
  // Add `&summary=/* <summary> */` to each “Edit” link.
  if (mw.config.get("wgAction") === "view") {
    console.log("Chargement de Gadget-clearer-edit-summary.js…");
    $(".mw-editsection").each(function () {
      var $this = $(this);
      var $title = $this.prev(); // H* tag that precedes the current element
      if (!$title.length)
        return;
      // Build breadcrumb
      var titleLevel = +$title.prop("tagName").charAt(1);
      var titles = [];
      for (var level = titleLevel; level > 1; level--) {
        titles.unshift($title.attr("id").replace(/_/g, "%20"));
        if (level > 2) { // Look for the containing section header
          $title = $title.parent()
              .prevAll(".mw-heading" + (level - 1)) // All previous headers of directly higher level
              .first() // Closest previous header of directly higher level
              .children() // H* tags
              .first(); // First (and only) H* tag
          if (!$title.length) break;
        }
      }
      // When "Show me both editor tabs" enabled, there will be two links: visual and wikitext.
      $this.find("a").attr("href", function (_, href) {
        return href + "&summary=/*%20" + titles.join("/") + "%20*/%20";
      });
    });
  }
});
