// [[Catégorie:JavaScript du Wiktionnaire|externalsearch.js]]
//<source lang="JavaScript">

/** Change Special:Search to use a drop-down menu *******************************************************
 *
 *  Description: Change Special:Search to use a drop-down menu, with the default being
 *               the internal MediaWiki engine
 *  Created and maintained by: [[User:Gracenotes]]
 */

function SpecialSearchEnhanced() {
  var createOption = function (site, action, mainQ, addQ, addV) {
    var opt = document.createElement('option');
    opt.appendChild(document.createTextNode(site));
    searchEngines.push([action, mainQ, addQ, addV]);
    return opt;
  }

  if (document.forms['powersearch'])
    var searchForm = document.forms['powersearch'];
  if (document.forms['search'])
    var searchForm = document.forms['search'];

  if (searchForm.lsearchbox) {
    var searchBox = searchForm.lsearchbox;
  }
  else {
    var searchBox = searchForm.search;
  }
  var selectBox = document.createElement('select');
  selectBox.id = 'searchEngine';
  searchForm.onsubmit = function () {
    var optSelected = searchEngines[document.getElementById('searchEngine').selectedIndex];
    searchForm.action = optSelected[0];
    searchBox.name = optSelected[1];
    searchForm.title.value = optSelected[3];
    searchForm.title.name = optSelected[2];
  }
  var domain = mw.config.get('wgServer').replace(/^.*?\/\//, '');
  selectBox.appendChild(createOption('Recherche interne', mw.config.get('wgScriptPath') + '/index.php', 'search', 'title', 'Special:Search'));
  selectBox.appendChild(createOption('Google', 'http://www.google.com/search', 'q', 'sitesearch', domain));
  selectBox.appendChild(createOption('Yahoo', 'http://search.yahoo.com/search', 'p', 'vs', domain));
  selectBox.appendChild(createOption('Bing', 'http://www.bing.com/search', 'q', 'q1', 'site:' + domain));
  selectBox.appendChild(createOption('Wikiwix', 'http://www.wikiwix.com/', 'action', 'lang', 'fr'));
  selectBox.appendChild(createOption('Exalead', 'http://www.exalead.com/wikipedia/results', 'q', 'language', 'fr'));
  searchBox.style.marginLeft = '0px';
  if (document.getElementById('loadStatus')) {
    var lStat = document.getElementById('loadStatus');
  }
  else {
    var lStat = searchForm.title;
    if (typeof lStat == 'object' && typeof lStat.length === 'number') lStat = lStat[0];
  }
  lStat.parentNode.insertBefore(selectBox, lStat);
}

var searchEngines = [];

if (mw.config.get('wgCanonicalSpecialPageName') == "Search") { //scripts specific to Special:Search
  jQuery(document).ready(SpecialSearchEnhanced);
}

//</source>
