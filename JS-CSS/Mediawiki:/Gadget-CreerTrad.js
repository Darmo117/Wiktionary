//==========================================================================================
// Création d'une page de traduction depuis un lien rouge dans une section traduction
// -----------------------------------------------------------------------------------------
// Pamputt 2013-06-13
// Inspiré de MediaWiki:Gadget-CreerFlexionFr.js développé par ArséniureDeGallium
// -----------------------------------------------------------------------------------------
// [[Catégorie:JavaScript du Wiktionnaire|CreerTrad]]
//==========================================================================================

// TEST
console.log("Gadget-CreerTrad.js");

if (mw.config.get('wgNamespaceNumber') === 0) {
  CrTr_ChangerLiensRouges();
}

//--------------------------------------------------------------------------------------
// Créer les liens vers le gadget
// pour tous les liens rouges dans les infobox de classe "translations"
//--------------------------------------------------------------------------------------
function CrTr_ChangerLiensRouges() {
  $('.translations').find('.new').filter(function () {
    // On évite la colorisation des liens rouges pour les écritures traditionnelles (chinois et coréen)
    // ainsi que pour les liens interwikis en exposants qui utilisent des codes langue redirigés
    // (cf. [[Discussion_module:traduction#Liens en exposant et codes wikimédia]])
    var enfants = $(this).children();
    return enfants.length > 0 && !enfants.first().hasClass('ecrit_tradi') &&
        !enfants.first().hasClass('trad-inconnu');
  })
      .each(function () {
        var link = $(this);
        var title = link.attr('title');
        var trad = /^(.*?) \(page inexistante\)$/.exec(title);
        if (trad !== null) {
          trad = trad[1];
        } else {
          // l'attribut title n'est pas sous la forme "<titre> (page inexistante)"
          // le lien ne sera pas colorisé
          return;
        }
        var code_langue = link.children().first().attr('lang');
        link.css('background-color', '#77B5FE');
        link.attr('title', 'cliquez pour créer « ' + trad + ' » avec le gadget');
        link.click(function (event) {
          event.preventDefault();
          CrTr_CreerTrad1(trad, code_langue);
        });
      });
}

window.CrTr_ChangerLiensRouges = CrTr_ChangerLiensRouges;

//==========================================================================================
var CrTr_Mot = "";
var CrTr_Trad = "";
var CrTr_codelangue = "";

//--------------------------------------------------------------------------------------
// Première étape suite à clic :
// * mémoriser les graphies des mots dans les variables globales
// * requête pour obtenir le wikicode de l'article
//--------------------------------------------------------------------------------------
function CrTr_CreerTrad1(trad, lang) {
  CrTr_Mot = mw.config.get('wgPageName').replace(/_/g, " ");
  CrTr_Trad = trad;
  CrTr_codelangue = lang;

  // requête pour obtenir le contenu de l'article
  var urlMot = mw.config.get('wgServer') + mw.config.get('wgScript') + '?title=' + encodeURIComponent(CrTr_Mot);
  CommonWikt_ajax.http({
    url: urlMot + '&action=raw',
    onSuccess: CrTr_CreerTrad2
  });
}

//--------------------------------------------------------------------------------------
// Deuxième étape suite à clic :
// * récupération du wikicode de l'article et extraction des informations pertinentes
//--------------------------------------------------------------------------------------
function CrTr_CreerTrad2(Req) {
  // récupérer le wikicode
  var codewiki = Req.responseText;
  var codesplit = codewiki.split("\n"); // séparation en lignes individuelles

  var status = "pret";
  var new_codewiki = "";

  var ligne_trad = 0;
  var lig_trad_trouve = false;
  var a_rechercher = CrTr_codelangue + "|" + CrTr_Trad;
  var cmptDef = 0;
  var ligne_def = "";

  for (var k = 0; k < codesplit.length; k++) {
    // on recherche la ligne où se trouve la traduction
    if (codesplit[k].indexOf(a_rechercher) > 0) {
      if (lig_trad_trouve) {
        alert("Le gadget ne prend pas en charge le fait \n qu'une traduction apparaisse deux fois dans la même page.");
        status = "fini";
        break;
      }
      ligne_trad = k;
      lig_trad_trouve = true;
    }
  }

  // si une transcription est indiquée, on la récupère
  var transcription = "";
  var regex_transcription = new RegExp("\\{\\{trad[+-]{0,2}\\|" + CrTr_codelangue +
      "\\|" + CrTr_Trad + "\\|(?:[^}]*?\\|)?(?:R|tr)=([^=|}]*?)[|}]");
  var array_transcription = regex_transcription.exec(codesplit[ligne_trad]);
  if (array_transcription !== null) {
    transcription = array_transcription[1];
  }

  // si le paramètre dif est utilisé, on récupère sa valeur
  // exemple : * {{T|he}} : {{trad+|he|מכלב|R=makhlev|dif=מַכְלֵב}} {{m}}
  var dif = "";
  a_rechercher = CrTr_codelangue + "\\|" + CrTr_Trad + "[^}]*?dif=([^|}]*?)[|}]";
  var dif_regex = new RegExp(a_rechercher, "");
  if (dif_regex.exec(codesplit[ligne_trad]) !== null) {
    dif = dif_regex.exec(codesplit[ligne_trad])[1];
  }

  // si un genre est indiqué, on le récupère
  var genre = "";
  var regex_genre = new RegExp("\\{\\{trad[+-]{0,2}\\|" + CrTr_codelangue +
      "\\|" + CrTr_Trad + "\\|(?:[^}]*?\\|)?([^=|}]*?)[|}]");
  var array_genre = regex_genre.exec(codesplit[ligne_trad]);
  if (array_genre !== null) {
    genre = array_genre[1];
  }

  if (status !== "fini") {
    // on parcourt le code wiki de la ligne 0
    // à la ligne où on a trouvé la traduction
    // la dernière section que l'on rencontre
    // correspond à la nature grammaticale du mot traduit

    var nature = "";
    for (var kk = 0; kk < ligne_trad; kk++) {
      if (/-adj-\|/.test(codesplit[kk]) || /S\|adjectif\|/.test(codesplit[kk])) {
        nature = "adjectif";
      }
      if (/-adv-\|/.test(codesplit[kk]) || /S\|adverbe\|/.test(codesplit[kk])) {
        nature = "adverbe";
      }
      if (/-nom-\|/.test(codesplit[kk]) || /S\|nom\|/.test(codesplit[kk])) {
        nature = "nom";
      }
      if (/-verbe?-\|/.test(codesplit[kk]) || /-verb-pr-\|/.test(codesplit[kk]) || /S\|verbe\|/.test(codesplit[kk])) {
        nature = "verbe";
      }
      if (/-conj-\|/.test(codesplit[kk]) || /S\|conjonction\|/.test(codesplit[kk])) {
        nature = "conjonction";
      }
      if (/-nom-pr-\|/.test(codesplit[kk]) || /S\|nom propre\|/.test(codesplit[kk])) {
        nature = "nom propre";
      }
      if (/-prép-\|/.test(codesplit[kk]) || /S\|préposition\|/.test(codesplit[kk])) {
        nature = "préposition";
      }
      if (/-phr-\|/.test(codesplit[kk])) {
        nature = "locution-phrase";
      }
      if (/-onom-\|/.test(codesplit[kk]) || /S\|onomatopée\|/.test(codesplit[kk])) {
        nature = "onomatopée";
      }
      if (/S\|interj(?:ection)?\|/.test(codesplit[kk])) {
        nature = "interjection";
      }

      var diese = '#';
      var etoile = '*';
      if (codesplit[kk].charAt(0) === diese && codesplit[kk].charAt(1) !== etoile) {
        cmptDef++;
        ligne_def = codesplit[kk];
      }
    }

    //s'il n'y a qu'une seule définition, on récupère un éventuel modèle de spécificité (biologie, astronomie, ...)
    var domaine = "";

    if (cmptDef === 1) {
      //on cherche d'abord si le modèle est de la forme
      //{{lexique|boulangerie|fr}}
      var regex_domaine = /{{lexique\|([^}]+?)\|[^|}]+?}}/;
      var array_domaine = regex_domaine.exec(ligne_def);
      if (array_domaine !== null) {
        domaine = array_domaine[1];
      } else {
        //si ce n'est pas trouvé, on cherche la forme
        //{{boulangerie|fr}}
        regex_domaine = /{{([^|}]+?)\|[^|}]+?}}/;
        array_domaine = regex_domaine.exec(ligne_def);
        if (array_domaine !== null) {
          domaine = array_domaine[1];
        }
      }
    }


    // on écrit maintenant le code wiki
    new_codewiki = "";
    if (CrTr_codelangue === "ca")
      new_codewiki = remplir_ca(nature, CrTr_Trad, CrTr_Mot, domaine, genre);
    else if (CrTr_codelangue === "eo")
      new_codewiki = remplir_eo(nature, CrTr_Trad, CrTr_Mot, domaine);
    else if (CrTr_codelangue === "es")
      new_codewiki = remplir_es(nature, CrTr_Trad, CrTr_Mot, domaine, genre);
    else if (CrTr_codelangue === "it")
      new_codewiki = remplir_it(nature, CrTr_Trad, CrTr_Mot, domaine, genre);
    else if (CrTr_codelangue === "oc")
      new_codewiki = remplir_oc(nature, CrTr_Trad, CrTr_Mot, domaine, genre);
    else if (CrTr_codelangue === "ru")
      new_codewiki = remplir_ru(nature, CrTr_Trad, CrTr_Mot, domaine, genre);
    else
      new_codewiki = remplir_generique(CrTr_codelangue, nature, CrTr_Trad, CrTr_Mot, transcription, dif, domaine, genre);
  }

  //ouvrir la nouvelle page en édition
  var urlTrad = mw.config.get('wgServer') + mw.config.get('wgScript') + "?title=" + encodeURIComponent(CrTr_Trad);
  CommonWikt_ajax.http({
    url: urlTrad + "&action=edit",
    text: new_codewiki,
    onSuccess: CrTr_CreerTrad3
  });
}

//--------------------------------------------------------------------------------------
// Troisième étape suite à clic :
// * charger le code wiki dans la zone d'édition
// * rendre la main à l'utilisateur
//--------------------------------------------------------------------------------------
function CrTr_CreerTrad3(Req, data) {
  var TexteFinal = data.text;
  while (document.body.firstChild) {
    document.body.removeChild(document.body.firstChild);
  }
  document.body.innerHTML = Req.responseText;
  document.getElementById('wpTextbox1').value = TexteFinal;
  document.getElementById('wpSummary').value = "Création avec [[Aide:Gadget-CreerTrad|Gadget-CreerTrad]]";
}

//--------------------------------------------------------------------------------------
// Permet de tester si une expression est une locution
// Ça passe par la recherche d'au moins une espace
//--------------------------------------------------------------------------------------
function estUneLocution(Trad) {
  return /[ ]/.test(Trad);
}

//--------------------------------------------------------------------------------------
// Permet de remplir le code wiki de la nouvelle page
//--------------------------------------------------------------------------------------
function remplir_generique(codelangue, nature, CrTr_Trad, CrTr_Mot, transcription, dif, domaine, genre) {
  var new_codewiki = "== {{langue|" + codelangue + "}} ==\n";
  new_codewiki += "{{ébauche|" + codelangue + "}}\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{ébauche-étym|" + codelangue + "}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|" + codelangue + "}} ===\n";

  if (dif.length > 0)
    new_codewiki += "'''" + dif + "'''";
  else
    new_codewiki += "'''" + CrTr_Trad + "'''";
  if (transcription.length > 0)
    new_codewiki += " (" + transcription + ")";
  new_codewiki += " {{pron||" + codelangue + "}}";
  if (nature === "nom" && genre.length > 0)
    new_codewiki += " {{" + genre + "}}";
  new_codewiki += "\n";
  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);
  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|" + codelangue + "}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  return new_codewiki;
}

function remplir_ca(nature, CrTr_Trad, CrTr_Mot, domaine, genre) {
  var new_codewiki = "== {{langue|ca}} ==\n";
  new_codewiki += "{{ébauche|ca}}\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{ébauche-étym|ca}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|ca}} ===\n";

  if (nature === "nom")
    new_codewiki += "{{ca-rég|}}\n";

  new_codewiki += "'''" + CrTr_Trad + "''' {{pron||ca}}";
  if (nature === "nom" && genre.length > 0)
    new_codewiki += " {{" + genre + "}}";
  new_codewiki += "\n";

  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);

  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|ca}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  return new_codewiki;
}

function remplir_eo(nature, CrTr_Trad, CrTr_Mot, domaine) {
  var new_codewiki = "== {{langue|eo}} ==\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{date|lang=eo}} {{ébauche-étym|eo}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|eo}} ===\n";

  if (nature === "adjectif" || nature === "nom")
    new_codewiki += "{{eo-flexions|}}\n";
  if (nature === "verbe")
    new_codewiki += "{{eo-verbe}}\n";

  new_codewiki += "'''" + CrTr_Trad + "''' {{pron||eo}}";
  if (nature === "verbe")
    new_codewiki += " {{valence ?|eo}} {{conjugaison|eo}}";
  new_codewiki += "\n";

  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);
  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|eo}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n";

  new_codewiki += "#* {{exemple|lang=eo}}\n\n";

  return new_codewiki;
}

function remplir_es(nature, CrTr_Trad, CrTr_Mot, domaine, genre) {
  var new_codewiki = "== {{langue|es}} ==\n";
  new_codewiki += "{{ébauche|es}}\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{ébauche-étym|es}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|es}} ===\n";

  if (nature === "nom")
    new_codewiki += "{{es-rég|}}\n";

  new_codewiki += "'''" + CrTr_Trad + "''' {{pron||es}}";
  if (nature === "nom" && genre.length > 0)
    new_codewiki += " {{" + genre + "}}";
  new_codewiki += "\n";

  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);

  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|es}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  return new_codewiki;
}

function remplir_it(nature, CrTr_Trad, CrTr_Mot, domaine, genre) {
  var new_codewiki = "== {{langue|it}} ==\n";
  new_codewiki += "{{ébauche|it}}\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{ébauche-étym|it}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|it}} ===\n";

  if (nature === "nom")
    new_codewiki += "{{it-flexion|}}\n";

  new_codewiki += "'''" + CrTr_Trad + "''' {{pron||it}}";
  if (nature === "nom" && genre.length > 0)
    new_codewiki += " {{" + genre + "}}";
  else
    new_codewiki += " {{genre ?|it}}";
  new_codewiki += "\n";

  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);

  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|it}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n";
  new_codewiki += "#* {{ébauche-exe|it}}\n\n";
  return new_codewiki;
}

function remplir_oc(nature, CrTr_Trad, CrTr_Mot, domaine, genre) {
  var new_codewiki = "== {{langue|oc}} ==\n";
  new_codewiki += "{{ébauche|oc}}\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{ébauche-étym|oc}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|oc}} ===\n";

  if (nature === "adjectif")
    new_codewiki += "{{oc-accord-mixte|}}\n";
  if (nature === "nom")
    new_codewiki += "{{oc-rég|}}\n";

  new_codewiki += "'''" + CrTr_Trad + "''' {{pron||oc}}";
  if (nature === "nom" && genre.length > 0)
    new_codewiki += " {{" + genre + "}}";
  new_codewiki += "\n";
  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);
  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|oc}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  return new_codewiki;
}

function remplir_ru(nature, CrTr_Trad, CrTr_Mot, domaine, genre) {
  var new_codewiki = "== {{langue|ru}} ==\n";
  new_codewiki += "{{ébauche|ru}}\n";
  new_codewiki += "=== {{S|étymologie}} ===\n";
  new_codewiki += ": {{ébauche-étym|ru}}\n\n";

  new_codewiki += "=== {{S|" + nature + "|ru}} ===\n";

  if (nature === "nom" && genre)
    new_codewiki += "{{ru-décl" + genre + "|<!-- Compléter -->}}\n";

  new_codewiki += "'''" + CrTr_Trad + "''' ''{{transliterator|ru|" + CrTr_Trad + "}}'' {{pron||ru}}";
  if (nature === "nom" && genre.length > 0)
    new_codewiki += " {{" + genre + "}}";
  new_codewiki += "\n";
  var motEnMaj = CrTr_Mot.charAt(0).toUpperCase() + CrTr_Mot.substring(1);
  if (domaine.length > 0)
    new_codewiki += "# {{lexique|" + domaine + "|ru}} [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  else
    new_codewiki += "# [[" + CrTr_Mot + "#fr|" + motEnMaj + "]].\n\n";
  return new_codewiki;
}
