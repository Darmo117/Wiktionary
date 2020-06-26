// Copie partielle de [[Utilisateur:Automatik/sections.js]]
// Requiert la fonction maj_sections de la page MediaWiki:Gadget-Formatage/sections.js
// Requiert la fonction corrige_typographie de la page MediaWiki:Gadget-Formatage/typographie.js

// [[Catégorie:JavaScript du Wiktionnaire|Formatage]]

// Fonctions d'appoint
function lcfirst(string) {
  return string.substr(0, 1).toLowerCase() + string.substr(1, string.length);
}

function ucfirst(string) {
  return string.substr(0, 1).toUpperCase() + string.substr(1, string.length);
}

// Gestion des erreurs
var erreurs = []; // Tableau pour regrouper les erreurs qui sont elles-mêmes des tableaux sous le format [ligne_erronée, numero_ligne, explication_erreur]
var modifs = 0; // Nombre de modifications effectuées en ayant cliqué sur le bouton

function write_erreur(erreurs) {
  var nombre_mod, nombre_err;

  // Créé une boîte si elle n'existe pas déjà
  if ($("#log_formatage").length === 0) {
    jQuery('<div/>', {
      id: 'log_formatage',
    }).appendTo('.editButtons');
    $("#log_formatage").hide();
  }

  // Créé un indicateur du nombre de modifications
  if ($("#nombre_modifs").length === 0) {
    nombre_mod = jQuery('<span/>', {
      id: 'nombre_modifs',
      class: 'form_message_info'
    });
    nombre_mod.insertAfter('#codeFormatterWidget');
    $("#nombre_modifs").hide();
  }

  // Créé un indicateur de nombre d'erreurs
  if ($("#nombre_erreurs").length === 0) {
    nombre_err = jQuery('<span/>', {
      id: 'nombre_erreurs',
      class: 'form_message_info'
    });
    nombre_err.insertAfter('#codeFormatterWidget');
    $("#nombre_erreurs").hide();
  }

  if (modifs > 0) {
    if (modifs == 1) {
      $("#nombre_modifs").text("1 changement");
    }
    else {
      $("#nombre_modifs").text(modifs + " changements");
    }
  }
  else {
    $("#nombre_modifs").text("Aucun formatage");
  }
  $("#nombre_modifs").show('fast');

  if (erreurs.length >= 1) {
    message_erreur = jQuery("<p/>");

    // Indicateur de nombre
    if (erreurs.length == 1) {
      $("#nombre_erreurs").text("(1 erreur)");
    }
    else {
      $("#nombre_erreurs").text("(" + erreurs.length + " erreurs)");
    }

    liste = jQuery("<table/>", {
      class: "wikitable"
    });
    tete = jQuery("<tr/>");
    tete.append(jQuery("<th/>", {text: "Ligne"}));
    tete.append(jQuery("<th/>", {text: "Élément"}));
    tete.append(jQuery("<th/>", {text: "Erreur"}));
    liste.append(tete);

    for (var i = 0; i < erreurs.length; i++) {
      ligne = jQuery("<tr/>");
      ligne.append(jQuery("<td/>", {text: erreurs[i][1]}));
      ligne.append(jQuery("<td/>", {text: erreurs[i][0]}));
      ligne.append(jQuery("<td/>", {text: erreurs[i][2]}));
      liste.append(ligne);
    }
    message_erreur.append(liste);
    $("#log_formatage").html(message_erreur);
    $("#nombre_erreurs").show('fast');
    $("#log_formatage").show('fast');
  }
  else {
    $("#nombre_erreurs").hide('fast');
    $("#log_formatage").hide('fast');
  }
}

// Pour assurer la compatibilité avec WikEd
function wikEd_off() {
  if (typeof (wikEdUseWikEd) != 'undefined') {
    if (wikEdUseWikEd === true) {
      WikEdUpdateTextarea();
    }
  }
}

// Rendre la main à WikEd
function wikEd_on() {
  if (typeof (wikEdUseWikEd) != 'undefined') {
    if (wikEdUseWikEd === true) {
      WikEdUpdateFrame();
    }
  }
}

// Ensemble des opérations qui se passent quand on clique le bouton "Formater"
function formatage() {
  wikEd_off();
  erreurs = [];	/* Reinitialisation des erreurs */
  //modifs = 0;

  /* Fonctions de formatage */
  maj_sections();
  //corrige_typographie();

  write_erreur(erreurs);

  wikEd_on();
}

function create_toolbar_button() {
  /******************************************************
   * Ajout d'un bouton à la barre vector (ou l'ancienne)
   * Crédit : [[w:en:User:V111P/js/addToolbarButtons]]
   /******************************************************/
      // Propriétés du bouton
  var addToolbarButtonsUrl = '//en.wikipedia.org/w/index.php?title='
      + 'User:V111P/js/addToolbarButtons.js&action=raw&ctype=text/javascript';
  var modif_section_button = {
    id: 'sections-modifiables',
    tooltip: 'Rendre les sections modifiables',
    callback: formatage,
    iconUrl: '//upload.wikimedia.org/wikipedia/commons/4/43/Sections_modifiables_icone3.png'
  };

  // Ajout à la barre d'outils
  if (mw.libs.addToolbarButtons)
    mw.libs.addToolbarButtons(modif_section_button);
  else {
    var tbs = window.toolbarButtonsToAdd = window.toolbarButtonsToAdd || [];
    tbs.push(modif_section_button);
    $.ajax({
      url: addToolbarButtonsUrl,
      dataType: 'script',
      cache: true
    });
  }
}

function create_submitlike_button() {
  // EN PLUS : création et ajout du bouton "Formater" après "Changements en cours"
  button = ['<span id="codeFormatterWidget" class="oo-ui-widget oo-ui-widget-enabled oo-ui-buttonElement oo-ui-buttonElement-framed oo-ui-labelElement oo-ui-buttonInputWidget">',
    '<input id="codeFormatter" class="oo-ui-inputWidget-input oo-ui-buttonElement-button" aria-disabled="false" value="Formater" title="Formater le wikitexte" type="button">',
    '</span>'].join('');
  $(button).insertAfter($('#wpDiffWidget'));
  $('#codeFormatter').attr(
      'tabindex',
      parseInt($('#wpDiffWidget input').attr('tabindex')) + 1
  );

  // Association des évènements de formatage au bouton
  $('#codeFormatter').click(function (event) {
    event.preventDefault();
    /***********/
    formatage();
    /***********/
    return false;
  });
}

// Ajout du bouton de formatage sous la zone de modification
function add_format_buttons() {
  /*
  if ( $( '.wikiEditor-ui' ).length === 0 && $( '#toolbar' ).length === 1) {
    create_toolbar_button();
  }
  */
  create_submitlike_button();
}

$(add_format_buttons());

//</nowiki>
