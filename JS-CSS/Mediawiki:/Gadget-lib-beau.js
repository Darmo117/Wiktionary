// [[Catégorie:JavaScript du Wiktionnaire|lib-beau.js]]

var beau$userGroups = {};

if (mw.config.get('wgUserGroups')) {
  for (var i = 0; i < mw.config.get('wgUserGroups').length; i++) {
    beau$userGroups[mw.config.get('wgUserGroups')[i]] = true;
  }
}

function beau$callAPI(query) {
  var url = mw.config.get('wgServer') + mw.config.get('wgScriptPath') + '/api.php?';

  for (var field in query) {
    var value = query[field];
    url += '&' + field + '=' + encodeURIComponent(value);
  }
  url += '&format=json';
  mw.loader.load(url);
}

function importScriptFromWikipedia(page) {
  mw.loader.load('//pl.wikipedia.org/w/index.php?action=raw&ctype=text/javascript&title=' + encodeURIComponent(page));
}

function importStylesheetFromWikipedia(page) {
  mw.loader.load('//pl.wikipedia.org/w/index.php?action=raw&ctype=text/css&title=' + encodeURIComponent(page));
}

var toolbarGadget = {};

/**
 * Status strony, true - strona załadowana.
 */
toolbarGadget.pageLoaded = false;

/**
 * Tablica przycisków, które zostały dodane za wcześnie.
 */
toolbarGadget.buttons = new Array();

/**
 * Dodaje przycisk na pasek narzędziowy.
 * @param button Obiekt opisujący przycisk, jego parametry to
 * title - tytuł przycisku
 * alt - tekst alternatywny
 * id - identyfikator przycisku (obiektu img)
 * href - link
 * onclick - funkcja wywoływana po naciśnięciu
 * icon - ikona przycisku
 * oldIcon - ikona przycisku dla starego paska (domyślnie icon)
 * newIcon - ikona przycisku dla nowego paska (domyślnie icon)
 * section - nazwa sekcji, do której przycisk ma zostać dodany
 * group- nazwa grupy, do której przycisk ma zostać dodany (jeśli takiej nie ma, zostanie stworzona)
 */

toolbarGadget.addButton = function (button) {
  if (!this.pageLoaded) {
    this.buttons.push(button);
    return;
  }
  //console.log("Wstawianie przycisku");
  //console.log(button);
  var title = button.title ? button.title : "";

  // Nowy pasek narzędzi
  // FIXME: zrobić to lepiej, jak będzie istniała dokumentacja do API...
  var toolbar = document.getElementById('wikiEditor-ui-toolbar');
  if (toolbar) {
    //console.log("Wykryto nowy pasek narzędzi");
    var image = document.createElement('img');
    image.alt = button.alt ? button.alt : title;
    image.title = title;
    image.className = "tool tool-button";
    image.style.cssText = "width: 22px; height: 18px; padding-top:4px";

    if (button.id)
      image.id = button.id;

    if (button.newIcon)
      image.src = button.newIcon;
    else if (button.icon)
      image.src = button.icon;

    var link = document.createElement('a');
    if (button.href)
      link.href = button.href;
    if (button.onclick)
      link.onclick = button.onclick;

    link.appendChild(image);

    // Sekcja nowego przycisku
    var section;
    if (button.section) {
      var sections = $(toolbar).find('div.section-' + button.section).get();
      if (sections.length) {
        section = sections[0];
        //console.log("Znaleziono sekcję");
      }
    }

    // Grupa nowego przycisku
    var group;
    var groupName = button.group ? button.group : 'custom';
    if (!group) {
      var groups = $(section ? section : toolbar).find("div.group-" + groupName).get();
      if (groups.length) {
        group = groups[0];
        //console.log("Znaleziono grupę");
      }
    }
    if (!group) {
      // Jeśli sekcja nie istnieje, umieść grupę w głównej
      if (!section) {
        var sections = $(toolbar).find("div.section-main").get();
        if (sections.length) {
          section = sections[0];
        }
      }
      group = document.createElement('div');
      group.className = 'group group-' + groupName;
      group.rel = groupName;

      section.appendChild(group);
    }
    group.appendChild(link);
    return;
  }
  // Stary pasek narzędzi
  toolbar = document.getElementById('toolbar');
  if (toolbar) {
    //console.log("Wykryto stary pasek narzędzi");
    var image = document.createElement('img');
    image.alt = button.alt ? button.alt : title;
    image.title = title;
    image.className = 'mw-toolbar-editbutton';
    if (button.id)
      image.id = button.id;

    if (button.oldIcon)
      image.src = button.oldIcon;
    else if (button.icon)
      image.src = button.icon;
    image.style.cursor = 'pointer';

    if (button.onclick)
      image.onclick = button.onclick;

    if (button.href) {
      var link = document.createElement('a');
      link.href = button.href;
      link.appendChild(image);
      toolbar.appendChild(link);
    }
    else {
      toolbar.appendChild(image);
    }
    return;
  }
  //console.log("Nie wykryto paska narzędzi");
}

toolbarGadget.addButtons = function () {
  for (var i = 0; i < this.buttons.length; i++) {
    this.addButton(this.buttons[i]);
  }
  this.buttons = null;
}

$('load').on(function () {
  if (toolbarGadget.pageLoaded) return;
  toolbarGadget.pageLoaded = true;
  //console.log("Strona została załadowania");
  toolbarGadget.addButtons();
});
