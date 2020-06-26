/*====================================================================================
 Création d’un mot à partir d’un patron généré automatiquement
 à partir de quelques clics dans une boite de dialogue
------------------------------------------------------------------------------------
 Code en partie inspiré de w:MediaWiki:Gadget-RenommageCategorie.js
 et aussi de MediaWiki:Gadget-SpecialChar.js
 Le reste est fait par ArséniureDeGallium, sous CC-BY-SA-3.0
------------------------------------------------------------------------------------
 v2.0 2012-12-10
 v2.1 2012-12-26
 v2.2 2013-01-01
 v2.3 2013-01-04 restructuration des fonctions pour la boite de dialogue
 v2.4 2013-01-29 cookies pour mémoriser préférences
 v3.0 2013-02-28 intégration de l’outil dans la page
 v4.0 2014-01-22 prise en charge de la nouvelle syntaxe des sections modifiables
 v4.1 … en cours …
------------------------------------------------------------------------------------
[[Catégorie:JavaScript du Wiktionnaire|CreerNouveauMot.js]]
======================================================================================*/

// Tests
console.log("Gadget-CreerNouveauMot.js");

//--------------------------------------------------------------------------------------------
// Valeurs par défaut et variables globales

// Constantes (personnalisables dans votre .js)
window.CrNoMo_OuvrirAuto = false;
window.CrNoMo_Ebauche = true; // mettre bandeau ébauche
window.CrNoMo_DureeCookie = 30;
window.CrNoMo_TexteOnglet = "Ajouter avec un patron (v4.0)";
window.CrNoMo_ResumModif = "Ajout d’un mot assisté par [[Aide:Gadget-CreerNouveauMot|Gadget-CreerNouveauMot]] (v4.0)";

// Variables globales initialisées par vos cookies
window.CrNoMo_LangueMot = "fr"; // code langue selon ISO639

// Variables globales formulaire (init automatique)
window.CrNoMo_LangueSection = true; // créer section langue
window.CrNoMo_MotVedette = mw.config.get('wgTitle'); // page en cours, non modifiable
window.CrNoMo_CleVedette = CommonWikt_CleTri(CrNoMo_MotVedette); // clé de tri
window.CrNoMo_Lemme = CrNoMo_MotVedette; // forme de base pour flexions

// Variables globales formulaire (autres)
window.CrNoMo_TypeMot="";
window.CrNoMo_Flexion=false;
window.CrNoMo_Sigle=false;
window.CrNoMo_GenreMot="";
window.CrNoMo_Definit="";
window.CrNoMo_Prononc="";

var CrNoMo_SsÉty="";
var CrNoMo_SsSyn="";
var CrNoMo_SsDrv="";
var CrNoMo_SsApr="";
var CrNoMo_SsVoc="";
var CrNoMo_SsRéf="";

var CrNoMo_VoirWp = false; //créer section "voir aussi"

// Variables globales pour les calculs
window.CrNoMo_InsTxt="";
window.CrNoMo_LangueEffective=""; // == CrNoMo_LangueMot si patron spécifique, "qqq" sinon.
window.CrNoMo_InsertionFaite = false;

/***********************************************************************************************
 Création du lien d’ouverture du gadget, uniquement en mode édit ns=0
 (test fait sur id='Editnotice-0' censé être présent dans [[Mediawiki:Editnotice-0]])
 Ouverture automatique si autorisé et page vide
 (attention CrNoMo_OuvrirAuto personnalisable, c’est pour ça qu’il faut attendre window.load)
 ***********************************************************************************************/
jQuery( document ).ready( function( $ ) {
  var tedit = document.getElementById("Editnotice-0");
  // Si la coloration syntaxique est activée ou non (le crayon au-dessus de la fenêtre dédition)
  var useCodeMirror;
  if(tedit){
    var texte_bandeau = '<a href="javascript:CrNoMo_OpenMenu0()">Ouvrir le gadget CréerNouveauMot</a>';
    window.mw.loader.using( 'user.options' ).then(
        function() {
          if ( window.mw.user.options.get('codemirror-syntax-highlight') == 1 ) {
            useCodeMirror = true;
            texte_bandeau = '<span class="error">CréerNouveauMot n’est pas compatible'
                + 'avec la coloration syntaxique (le crayon au-dessus de la fenêtre d’édition)</span>';
          }
          CommonWikt_AddTabMenu( "javascript:CrNoMo_OpenMenu0();", CrNoMo_TexteOnglet );
          tedit.innerHTML = '<div class="CrNoMo_DialogBoxTitle" width="100%" style="border: 3px solid #9f9fff;text-align:center;border-radius: .2em; background-color:#f8f8ff	">'
              + texte_bandeau
              + '</div>'
              + '<b><i>CréerNouveauMot</i></b> est un outil qui vous aide à ajouter des mots sur le Wiktionnaire'
              + ' sans avoir besoin de tout comprendre à la syntaxe wiki.'
              + ' Voir <a href="javascript:CrNoMo_Aide()">l’aide</a> pour plus d’explications.<br />';
        }
    );
  }
} );

//jQuery( window ).on( 'load', function( $ ) {
//  var tb = document.getElementById("wpTextbox1");
//  if( (tb) && (CrNoMo_OuvrirAuto) && (tb.value.length==0) ){CrNoMo_OpenMenu0();}
//} );

/***********************************************************************************************
 PATRONS SPÉCIFIQUES PAR LANGUE
 ***********************************************************************************************/
if ( mw.config.get('wgNamespaceNumber') === 0 &&
    $.inArray( mw.config.get( 'wgAction' ), ['edit', 'submit'] ) !== -1
) {

  // On importe les sous-pages uniquement si on est en mode édition dans l’espace principal

  importScript("MediaWiki:Gadget-CreerNouveauMot.js/fr.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/ca.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/en.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/eo.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/es.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/it.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/oc.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/pcd.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/pro.js");
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/pt.js");
  // Patron générique (par défaut si les autres n’existent pas)
  importScript("MediaWiki:Gadget-CreerNouveauMot.js/qqq.js");
}

/***********************************************************************************************
 BOITE FORMULAIRE POUR LA LANGUE CHOISIE
 ***********************************************************************************************/
// --------------------------------------------------------------------------------------------
// Récup préférences utilisateur
// --------------------------------------------------------------------------------------------
function CrNoMo_OpenMenu0(){
  var x = CommonWikt_LitCookie("CrNoMo_LangueMot");
  if (x) CrNoMo_LangueMot = x;
  //suppression du blabla au dessus de la zone d’édition
  CommonWikt_Delete( document.getElementById('nouvel-article') );
  //passage à la suite
  setTimeout(CrNoMo_OpenMenu1, 1);
}
window.CrNoMo_OpenMenu0 = CrNoMo_OpenMenu0;

// --------------------------------------------------------------------------------------------
// affichage de l’onglet actif, et masquage de tous les autres
// --------------------------------------------------------------------------------------------
function CrNoMo_Onglet(num){
  CrNoMo_LitMenu(); //avant de changer d’onglet, il faut tout mémoriser !
  for (var k=1;k<=6;k++){
    var bt=document.getElementById("mb999bt"+k);
    var og=document.getElementById("mb999og"+k);
    if (k==num){
      bt.className="mbBoutonSel";
      og.style.display="block";
    }else{
      bt.className="mbBouton";
      og.style.display="none";
    }
  }
}
window.CrNoMo_Onglet = CrNoMo_Onglet;

// --------------------------------------------------------------------------------------------
// Création de la boite de dialogue
// --------------------------------------------------------------------------------------------
function CrNoMo_OpenMenu1(){
  var tedit = document.getElementById('Editnotice-0');

  // détection auto existence section de langue
  var wikicode = document.getElementById("wpTextbox1").value;
  var section = new RegExp( "\\{\\{langue\\|" + CrNoMo_LangueMot + "\\}\\}","g");
  var pos = wikicode.search(section);
  CrNoMo_LangueSection = (pos<0);

  // html selon la langue
  // Si les fonctions existent, c’est qu’il y a un modèle dédié à la langue,
  // sinon on prend le modèle par défaut (qqq)
  try {
    var lg = CrNoMo_LangueMot + "();"; // suffixe de l'appel de fonction
    eval( "var MenuContent = CrNoMo_DialogHtml_" + lg );
    eval( "var TitreContent = CrNoMo_TitreHtml_" + lg );
    eval( "var BarreAPI = CrNoMo_BarreAPI_" + lg );
    CrNoMo_LangueEffective = CrNoMo_LangueMot;
  }
  catch(err){
    var MenuContent = CrNoMo_DialogHtml_qqq();
    var TitreContent = CrNoMo_TitreHtml_qqq();
    var BarreAPI = CrNoMo_BarreAPI_qqq();
    CrNoMo_LangueEffective = "qqq";
  }

  // bandeau titre
  var bandeau='<div class="CrNoMo_DialogBoxTitle" width="100%" style="text-align:center;background-color:silver">'
      + TitreContent+'</div>';

  // onglet n°1
  var titre1 = '<a href="javascript:CrNoMo_Onglet(1)">Langue, type, définition</a>';
  var contenu1 = bandeau
      + '<fieldset><legend>Langue</legend>'
      + '<input type="text" id="IdLangue" size="4" value="' + CrNoMo_LangueMot
      + '" onchange="CrNoMo_ChangeLangue();"/>&nbsp;'
      + '<select id="IdLangList" onchange="CrNoMo_ClicLangue();">'
      + '<option value="">choisissez</option>'
      + '<option value="fr">français</option>'
      + '<option value="pro">ancien occitan</option>'
      + '<option value="en">anglais</option>'
      + '<option value="ca">catalan</option>'
      + '<option value="es">espagnol</option>'
      + '<option value="eo">espéranto</option>'
      + '<option value="it">italien</option>'
      + '<option value="oc">occitan</option>'
      + '<option value="pcd">picard</option>'
      + '<option value="pt">portugais</option>'
      + '</select>&nbsp;'
      + '<input type="button" value="Passer à cette langue" onclick="CrNoMo_ChangeLangue();"/>'
      + '&nbsp;<input type="checkbox" id="IdLangueSection" /><label for="IdLangueSection">'
      + 'Ajouter à la section de langue existante si elle existe déjà</label>'
      + '</fieldset>'
      + MenuContent
      + '<fieldset><legend>Prononciation — '+BarreAPI+'</legend>'
      + '<input type="text" id="IdPron" value="'+CrNoMo_Prononc+'" size="45" tabindex="2"/>'
      + '</fieldset>'
      + '<fieldset><legend>Définition — '+CrNoMo_BarCharDef('’àÀæÆçÇéÉèÈêÊëîÎïôÔœŒùû')+'</legend>'
      + '<textarea id="IdDefinit" rows="3" tabindex="3">'+CrNoMo_Definit+'</textarea><br />'
      + '</fieldset>';

  // onglet n°2
  var titre2 = '<a href="javascript:CrNoMo_Onglet(2)">Sections supplémentaires</a>';
  var contenu2 = bandeau + '<br />'
      + '<fieldset><legend>Étymologie — '+CrNoMo_BarCharÉty('’àÀæÆçÇéÉèÈêÊëîÎïôÔœŒùû«  »')+'</legend>'
      + '<textarea id="IdSsÉtyBx" rows="2">' + CrNoMo_SsÉty + '</textarea><br />'
      + '</fieldset>'
      + 'Références :<br />'
      + '<textarea id="IdSsRéfBx" rows="2">' + CrNoMo_SsRéf + '</textarea><br />'
      + '<small>Ci-dessous mettez les mots les uns en dessous des autres sans aucune mise en forme.</small><br />'
      + '<table style="border-spacing:5px"><tr><td>'
      + 'Synonymes :<br />'
      + '<textarea id="IdSsSynBx" rows="5" cols="30">'+CrNoMo_SsSyn+'</textarea><br />'
      + 'Dérivés :<br />'
      + '<textarea id="IdSsDrvBx" rows="5" cols="30">'+CrNoMo_SsDrv+'</textarea><br />'
      + '</td><td>'
      + 'Apparentés étymologiques :<br />'
      + '<textarea id="IdSsAprBx" rows="5" cols="30">'+CrNoMo_SsApr+'</textarea><br />'
      + 'Apparentés par le sens :<br />'
      + '<textarea id="IdSsVocBx" rows="5" cols="30">'+CrNoMo_SsVoc+'</textarea><br />'
      + '</td></tr></table>';

  // onglet n°3
  var titre3 = '<a href="javascript:CrNoMo_Onglet(3)">Options avancées</a>';
  var contenu3 = bandeau
      + '<fieldset><legend>Options avancées</legend>'
      + '<input type="checkbox" id="IdEbauche" /><label for="IdEbauche">Ébauche</label><br />'
      + '<input type="checkbox" id="IdVoirWp" /><label for="IdVoirWp">Mettre une section "voir Wikipédia"</label><br />'
      + 'Clé de tri : <input type="text" id="IdCle" size="40" value="'+CrNoMo_CleVedette+'"/>'
      + '</fieldset>';

  // onglet n°4
  var titre4 = '<a href="javascript:CrNoMo_Onglet(4)">Masquer</a>';
  var contenu4 = '';

  // onglet n°5
  var titre5 = '<a href="javascript:CrNoMo_Aide()">Aide</a>';
  var contenu5 = '';

  // onglet n°6
  var titre6 = '<a href="javascript:CrNoMo_CheckMenu();CrNoMo_Onglet(6)">Insérer le code wiki</a>';
  var contenu6 = 'Le code a été inséré dans la boite d’édition ci-dessous.'
      + ' Vous devriez <b>vérifier</b> que le résultat est conforme à vos souhaits, et en particulier'
      + ' utiliser le bouton "prévisualisation" avant de publier (faites <b>Ctrl+F5</b> pour tout annuler).';

  // création boiboite en html, avec plein d'onglets, c'est plus cool :D
  tedit.innerHTML = '<div id="mb999" class="mbViolet"><div>'
      + '<div id="mb999bt1" class="mbBoutonSel">'+titre1+'</div>'
      + '<div id="mb999bt2" class="mbBouton">'+titre2+'</div>'
      + '<div id="mb999bt3" class="mbBouton">'+titre3+'</div>'
      + '<div id="mb999bt4" class="mbBouton">'+titre4+'</div>'
      + '<div id="mb999bt5" class="mbBouton">'+titre5+'</div>'
      + '<div id="mb999bt6" class="mbBouton">'+titre6+'</div>'
      + '</div><div class="mbContenu">'
      + '<div id="mb999og1" style="display:block;">'+contenu1+'</div>'
      + '<div id="mb999og2" style="display:none;">'+contenu2+'</div>'
      + '<div id="mb999og3" style="display:none;">'+contenu3+'</div>'
      + '<div id="mb999og4" style="display:none;">'+contenu4+'</div>'
      + '<div id="mb999og5" style="display:none;">'+contenu5+'</div>'
      + '<div id="mb999og6" style="display:none;">'+contenu6+'</div>'
      + '</div></div>';

  //initialisations des checkbox et selects
  document.getElementById('IdSigle').checked = CrNoMo_Sigle;
  document.getElementById('IdFlexion').checked = CrNoMo_Flexion;
  document.getElementById('IdEbauche').checked = CrNoMo_Ebauche;
  document.getElementById('IdLangueSection').checked = !CrNoMo_LangueSection;
  document.getElementById('IdVoirWp').checked = CrNoMo_VoirWp;

  var tt=document.getElementById('IdType');
  if (CrNoMo_TypeMot.length>0) tt.value = CrNoMo_TypeMot;
  document.getElementById('IdGenre').value = CrNoMo_GenreMot;

  // poka yoke pour éviter une prévisualisation sans avoir inséré le texte
  document.getElementById ('wpPreview').onclick = function (event) {
    if (CrNoMo_InsertionFaite === true) {
      // si l’insertion a déjà été réalisée, rien à signaler.
      return true;
    }
    if (document.getElementById('IdDefinit').value === '') {
      // si la définition (dans le gadget) est vide, rien à signaler.
      return true;
    }
    alert ('Attention : en prévisualisant maintenant sans appuyer sur « Insérer le code wiki », vous perdrez ce que vous avez entré dans le gadget. Si c’est ce que vous souhaitez, effacez le contenu du champ « définition » avant de recliquer sur « Prévisualiser ».');
    // si la définition n’est pas vide et que l’insertion n’est pas faite, on empêche le bouton de fonctionner.
    event.preventDefault ();
    return false;
  };
}

// --------------------------------------------------------------------------------------------
// récupération des données de la boite de dialogue

function CrNoMo_LitMenu(){
  CrNoMo_Prononc = document.getElementById('IdPron').value;
  CrNoMo_Lemme = document.getElementById('IdLemme').value;
  CrNoMo_TypeMot = document.getElementById('IdType').value;
  CrNoMo_LangueSection = !document.getElementById('IdLangueSection').checked;
  CrNoMo_Flexion = document.getElementById('IdFlexion').checked;
  CrNoMo_Sigle = document.getElementById('IdSigle').checked;
  CrNoMo_GenreMot = document.getElementById('IdGenre').value;
  CrNoMo_Definit = document.getElementById('IdDefinit').value;
  CrNoMo_Ebauche = document.getElementById('IdEbauche').checked;
  CrNoMo_SsÉty = document.getElementById('IdSsÉtyBx').value;
  CrNoMo_SsSyn = document.getElementById('IdSsSynBx').value;
  CrNoMo_SsDrv = document.getElementById('IdSsDrvBx').value;
  CrNoMo_SsApr = document.getElementById('IdSsAprBx').value;
  CrNoMo_SsVoc = document.getElementById('IdSsVocBx').value;
  CrNoMo_SsRéf = document.getElementById('IdSsRéfBx').value;
  CrNoMo_VoirWp = document.getElementById('IdVoirWp').checked;
}

// --------------------------------------------------------------------------------------------
// Choix de la langue dans la liste

function CrNoMo_ClicLangue(){
  document.getElementById('IdLangue').value=document.getElementById('IdLangList').value;
}
window.CrNoMo_ClicLangue = CrNoMo_ClicLangue;

// --------------------------------------------------------------------------------------------
// Traitement du bouton "changer de langue"
// * ferme la boite de dialogue
// * charge les fonctions pour la nouvelle langue
// --------------------------------------------------------------------------------------------
function CrNoMo_ChangeLangue(){
  CrNoMo_LitMenu();
  CrNoMo_LangueMot = document.getElementById('IdLangue').value;
  CommonWikt_AjouteCookie("CrNoMo_LangueMot", CrNoMo_LangueMot, CrNoMo_DureeCookie );
  setTimeout(CrNoMo_OpenMenu1,250);
}
window.CrNoMo_ChangeLangue = CrNoMo_ChangeLangue;

// --------------------------------------------------------------------------------------------
// Traitement du bouton "aide"
// --------------------------------------------------------------------------------------------
function CrNoMo_Aide(){
  var urlVrb = mw.config.get('wgServer') + mw.config.get('wgScript') +
      "?title="+encodeURIComponent("Aide:Gadget-CreerNouveauMot") +
      "&action=view";
  window.open(urlVrb);
}
window.CrNoMo_Aide = CrNoMo_Aide;

// --------------------------------------------------------------------------------------------
// Traitement du bouton "insérer"
// * teste la validité des saisies de l’utilisateur, et si possible…
// * lance le calcul du patron à insérer
// * insère le texte du patron dans la boite d’édition
// --------------------------------------------------------------------------------------------
function CrNoMo_CheckMenu(){
  CrNoMo_LitMenu();
  var tb = document.getElementById("wpTextbox1");

  // calcul du texte à insérer
  CrNoMo_Insert();

  // position initiale du curseur
  var startPos = tb.selectionStart;
  var endPos = tb.selectionEnd;
  var textScroll = tb.scrollTop;

  // insertion du texte
  var DebTxt = tb.value.substring(0, startPos);
  var FinTxt = tb.value.substring(startPos);
  tb.value = DebTxt + CrNoMo_InsTxt + FinTxt;
  // mise à jour de CrNoMo_InsertionFaite
  window.CrNoMo_InsertionFaite = true;

  // résumé de modif
  document.getElementById('wpSummary').value = CrNoMo_ResumModif;

  // repositionnement du curseur
  tb.selectionStart = startPos + CrNoMo_Curseur;
  tb.selectionEnd = tb.selectionStart;
  tb.scrollTop = textScroll;

}
window.CrNoMo_CheckMenu = CrNoMo_CheckMenu;

//------------------------------
// réponse au clic "flexion"
//------------------------------
function CrNoMo_ClicFlexion() {
  var cb = document.getElementById('IdFlexion');
  var tb = document.getElementById('IdLemme');
  tb.disabled = !cb.checked;
}
window.CrNoMo_ClicFlexion = CrNoMo_ClicFlexion;

//------------------------------
// Clavier virtuel pour API
//------------------------------
function CrNoMo_ClicCharAPI(c) {
  var pb = document.getElementById('IdPron');
  var m = pb.selectionStart;
  var n = pb.selectionEnd;
  pb.value = pb.value.substring(0,m) + c + pb.value.substring(n);
  pb.selectionStart = m + c.length;
  pb.selectionEnd = pb.selectionStart;
  pb.focus();
}
window.CrNoMo_ClicCharAPI = CrNoMo_ClicCharAPI;

function CrNoMo_BarCharAPI(lc){
  var res = "";
  for (var k=0;k<lc.length;k++)
    res += ' <a href="#" onclick="CrNoMo_ClicCharAPI(\'' + lc[k] + '\');">' + lc[k] + '</a>';
  return res;
}
window.CrNoMo_BarCharAPI = CrNoMo_BarCharAPI;

//----------------------------------------
// Clavier virtuel pour définitions
//----------------------------------------
function CrNoMo_ClicCharDef(c) {
  var db = document.getElementById('IdDefinit');
  var m = db.selectionStart;
  var n = db.selectionEnd;
  db.value = db.value.substring(0,m) + c + db.value.substring(n);
  db.selectionStart = m + c.length;
  db.selectionEnd = db.selectionStart;
  db.focus();
}
window.CrNoMo_ClicCharDef = CrNoMo_ClicCharDef;

function CrNoMo_BarCharDef(lc){
  var res = "";
  for (var k=0;k<lc.length;k++)
    res += ' <a href="#" onclick="CrNoMo_ClicCharDef(\'' + lc[k] + '\');">' + lc[k] + '</a>';
  return res;
}
window.CrNoMo_BarCharDef = CrNoMo_BarCharDef;

//----------------------------------------
// Clavier virtuel pour étymologie
//----------------------------------------
function CrNoMo_ClicCharÉty(c) {
  var eb = document.getElementById('IdSsÉtyBx');
  var m = eb.selectionStart;
  var n = eb.selectionEnd;
  eb.value = eb.value.substring(0,m) + c + eb.value.substring(n);
  eb.selectionStart = m + c.length;
  eb.selectionEnd = eb.selectionStart;
  eb.focus();
}
window.CrNoMo_ClicCharÉty = CrNoMo_ClicCharÉty;

function CrNoMo_BarCharÉty(lc){
  var res = "";
  for (var k=0;k<lc.length;k++)
    res += ' <a href="#" onclick="CrNoMo_ClicCharÉty(\'' + lc[k] + '\');">' + lc[k] + '</a>';
  return res;
}
window.CrNoMo_BarCharÉty = CrNoMo_BarCharÉty;

//-------------------------------------
// Ajout d'une option à un select
//-------------------------------------
function CrNoMo_AddOpt(lb,txt,val) {
  var xx = document.createElement('option');
  xx.text = txt;
  xx.value = val;
  try {
    lb.add(xx, null); // standards compliant; doesn't work in IE
  }
  catch(ex) {
    lb.add(xx); // IE only
  }
}
window.CrNoMo_AddOpt = CrNoMo_AddOpt;

/***********************************************************************************************
 BOITE OPTIONS AVANCÉES
 ***********************************************************************************************/

// --------------------------------------------------------------------------------------------
// Wikification d'une liste de mots séparés par des \n
function CrNoMo_SectionsSuppWikifListe(liste, langue){
  var li = liste.split("\n");
  var ch = "";
  var mot = "";
  for (k=0;k<li.length;k++){
    mot = li[k].replace(/^\s+|\s+$/g,''); //enlever les espaces au début et à la fin
    if (mot.length>0) ch += "* {{lien|" + mot + "|" + langue + "}}\n";
  }
  if (li.length>3) ch = "{{(}}\n" + ch + "{{)}}\n"; //boite déroulante éventuelle
  return ch;
}

/****************************************************************************
 CRÉATION PATRON
 *****************************************************************************/
// ----------------------------------------------------------------------
// Création du texte à insérer
// ----------------------------------------------------------------------
function CrNoMo_Insert() {
  CrNoMo_InsTxt = "";

  //-- section langue (début)
  if (CrNoMo_LangueSection){
    CrNoMo_InsTxt += "== {{langue|" + CrNoMo_LangueMot + "}} ==\n";

    if (CrNoMo_Ebauche){
      CrNoMo_InsTxt += "{{ébauche|" + CrNoMo_LangueMot + "}}\n";
    }
    if (CrNoMo_SsÉty.length>0){
      CrNoMo_InsTxt += "=== {{S|étymologie}} ===\n";
      if (CrNoMo_SsÉty[0]!=":") CrNoMo_InsTxt += ": ";
      CrNoMo_InsTxt += CrNoMo_SsÉty + "\n";
    }else if (!CrNoMo_Flexion){
      CrNoMo_InsTxt += "=== {{S|étymologie}} ===\n: {{ébauche-étym|" + CrNoMo_LangueMot + "}}\n";
    }
    CrNoMo_InsTxt += "\n";
  }

  //-------------------- titre section mot -----------------------
  var xx = CrNoMo_TypeMot;
  //if (CrNoMo_Flexion) xx = "-flex" + xx;
  CrNoMo_InsTxt += "=== {{S|" + xx + "|" + CrNoMo_LangueMot;
  if (CrNoMo_Flexion) CrNoMo_InsTxt += "|flexion";
  CrNoMo_InsTxt += "}} ===\n";

  //------- contenu section mot selon la langue sélectionnée -----
  try {
    eval( "CrNoMo_InsTxt += CrNoMo_Patron_" + CrNoMo_LangueEffective + "();" );
  }catch(err){
    alert("Bug lors de l'appel de CrNoMo_Patron_" + CrNoMo_LangueEffective + "(). Merci de le signaler à GaAs." );
  }

  //-------------------- définition ------------------------------
  if (CrNoMo_Definit.length>0) {
    if (CrNoMo_Definit[0] != "#") CrNoMo_InsTxt += "# ";
    CrNoMo_InsTxt += CrNoMo_Definit + "\n";
  }else{
    CrNoMo_InsTxt = CrNoMo_InsTxt
        + "# {{ébauche-déf|" + CrNoMo_LangueMot + "}}\n"
        + "#*<!-- ''.'' {{source|}}-->{{ébauche-exe|" + CrNoMo_LangueMot + "}}\n";
  }
  CrNoMo_InsTxt += "\n";

  //----------------- ss-sections optionnelles -------------------
  if (CrNoMo_SsSyn.length>0){
    CrNoMo_InsTxt += "==== {{S|synonymes}} ====\n" + CrNoMo_SectionsSuppWikifListe(CrNoMo_SsSyn, CrNoMo_LangueMot) + "\n";
  }
  if (CrNoMo_SsDrv.length>0){
    CrNoMo_InsTxt += "==== {{S|dérivés}} ====\n" + CrNoMo_SectionsSuppWikifListe(CrNoMo_SsDrv, CrNoMo_LangueMot) + "\n";
  }
  if (CrNoMo_SsApr.length>0){
    CrNoMo_InsTxt += "==== {{S|apparentés}} ====\n" + CrNoMo_SectionsSuppWikifListe(CrNoMo_SsApr, CrNoMo_LangueMot) + "\n";
  }
  if (CrNoMo_SsVoc.length>0){
    CrNoMo_InsTxt += "==== {{S|vocabulaire}} ====\n" + CrNoMo_SectionsSuppWikifListe(CrNoMo_SsVoc, CrNoMo_LangueMot) + "\n";
  }

  //------------------ ss-section "traduc" -----------------------
  if ((!CrNoMo_Flexion) &&(CrNoMo_LangueMot=="fr")) {
    CrNoMo_InsTxt = CrNoMo_InsTxt
        + "==== {{S|traductions}} ====\n"
        + "{{trad-début|}}\n"
        + "{{trad-fin}}\n"
        + "\n";
  }

  // mémo pos curseur pour enchainement création
  CrNoMo_Curseur = CrNoMo_InsTxt.length;

  //-- section langue (fin)
  if (CrNoMo_VoirWp){
    var modele_wp = CrNoMo_LangueMot == 'fr' ? '{{WP}}' : '{{WP|lang=xx}}'.replace('xx', CrNoMo_LangueMot);
    CrNoMo_InsTxt += "=== {{S|voir aussi}} ===\n* <modele_wp>\n\n".replace('<modele_wp>', modele_wp);
  }
  if (CrNoMo_SsRéf.length>0){
    CrNoMo_InsTxt += "=== {{S|références}} ===\n" + CrNoMo_SsRéf + "\n\n";
  }
  if ( CrNoMo_LangueSection && (CrNoMo_CleVedette.toLowerCase() != CrNoMo_MotVedette.toLowerCase()) ){
    CrNoMo_InsTxt += "{{clé de tri|" + CrNoMo_CleVedette + "}}\n";
  }
}
