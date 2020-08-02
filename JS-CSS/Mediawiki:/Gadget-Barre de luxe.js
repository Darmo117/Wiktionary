/**
 * (fr)
 * Ce gadget ajoute de nouveaux boutons à la barre d’outils.
 * Page d’aide : [[Aide:Gadget-Barre de luxe]]
 * Icones (OOUI): https://commons.wikimedia.org/wiki/OOUI_icons
 * Icones (Monobook): http://commons.wikimedia.org/wiki/Category:MediaWiki_edit_toolbar
 * ----
 * (en)
 * This gadget adds new buttons for the edit toolbar.
 * Help page: [[Aide:Gadget-Barre de luxe]] (fr)
 * Icons (OOUI): https://commons.wikimedia.org/wiki/OOUI_icons
 * Icons (Monobook): http://commons.wikimedia.org/wiki/Category:MediaWiki_edit_toolbar
 * ----
 * [[Catégorie:JavaScript du Wiktionnaire|Barre de luxe.js]]
 */

window.wikt.gadgets.barreDeLuxe = {
  NAME: "Barre de luxe",

  VERSION: "2.0",

  groups: [
    {id: "misc_templates", label: "Modèles"},
    {id: "links", label: "Liens"},
    {id: "section_templates", label: "Patrons"},
    {id: "messages", label: "Messages"},
    {id: "headers", label: "Bandeaux"},
    {id: "html_tags", label: "Balises"},
    {id: "default", label: ""},
  ],

  sectionId: "advanced",

  defaultButtons: [
    {
      tagOpen: "’",
      imageFileName: "5/57/Apostrophe.png",
      imageFileNameOOUI: "8/88/Upper_single_apostrophe_toolbar_symbol.png",
      tooltip: "Apostrophe typographique",
      buttonId: "apos",
      group: "format",
    },
    {
      tagOpen: "\u00a0",
      imageFileName: "5/55/Button_nbsp_1.png",
      tooltip: "Espace insécable",
      buttonId: "nbsp",
      group: "format",
    },
    {
      tagOpen: "«\u00a0",
      tagClose: "\u00a0»",
      imageFileName: "2/26/Button_latinas.png",
      imageFileNameOOUI: "a/ac/Norwegian_quote_sign.png",
      tooltip: "Guillemets français",
      buttonId: "fr-quotes",
      group: "format",
    },
    {
      tagOpen: "#REDIRECT[[",
      tagClose: "]]",
      imageFileName: "4/47/Button_redir.png",
      tooltip: "Redirection",
      buttonId: "redirect",
      toolbarIgnore: true,
    },
    {
      tagOpen: "{{w|",
      tagClose: "}}",
      imageFileName: "c/cb/Button_wikipedia.png",
      imageFileNameOOUI: "thumb/1/14/OOjs_UI_icon_logo-wikipedia.svg/24px-OOjs_UI_icon_logo-wikipedia.svg.png",
      tooltip: "Lien vers Wikipédia",
      buttonId: "link-wp",
      group: "links",
    },
    {
      tagOpen: "{{subst:" + "Merci IP|",
      tagClose: "}}~~" + "~~",
      imageFileName: "1/12/Button_accueilA.png",
      imageFileNameOOUI: "thumb/b/bf/Twemoji12_1f603.svg/24px-Twemoji12_1f603.svg.png",
      tooltip: "Merci IP",
      buttonId: "thanks-ip",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Bienvenue}}~~" + "~~",
      imageFileName: "e/eb/Button_accueilB.png",
      imageFileNameOOUI: "thumb/a/aa/Twemoji12_1f642.svg/24px-Twemoji12_1f642.svg.png",
      tooltip: "Bienvenue",
      buttonId: "welcome",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Débutant}}~~" + "~~",
      imageFileName: "a/a7/Button_smiley3.png",
      imageFileNameOOUI: "thumb/d/db/OOjs_UI_icon_error.svg/24px-OOjs_UI_icon_error.svg.png",
      tooltip: "Débutant",
      buttonId: "beginner",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Vandale}}~~" + "~~",
      imageFileName: "3/3b/Button_crocs.png",
      imageFileNameOOUI: "thumb/c/ca/OOjs_UI_icon_error-progressive.svg/24px-OOjs_UI_icon_error-progressive.svg.png",
      tooltip: "Vandale",
      buttonId: "vandal",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Vandale2}}~~" + "~~",
      imageFileName: "e/ec/Button_aviso.png",
      imageFileNameOOUI: "thumb/4/4e/OOjs_UI_icon_error-destructive.svg/24px-OOjs_UI_icon_error-destructive.svg.png",
      tooltip: "Vandale 2",
      buttonId: "vandal2",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Bloqué|2 ",
      tagClose: "h|Vandalisme}}~~" + "~~",
      imageFileName: "3/3f/Button_attendre.png",
      imageFileNameOOUI: "thumb/5/53/OOjs_UI_icon_cancel-destructive.svg/24px-OOjs_UI_icon_cancel-destructive.svg.png",
      tooltip: "Bloqué",
      buttonId: "vandal3",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Spam}}~~" + "~~",
      imageFileName: "6/6d/Button_exclamation_1.png",
      imageFileNameOOUI: "thumb/3/3b/OOjs_UI_icon_alert-warning.svg/24px-OOjs_UI_icon_alert-warning.svg.png",
      tooltip: "Spam",
      buttonId: "spam",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Spam2}}~~" + "~~",
      imageFileName: "3/33/Button_exclamation.png",
      imageFileNameOOUI: "thumb/f/f6/OOjs_UI_icon_alert-destructive.svg/24px-OOjs_UI_icon_alert-destructive.svg.png",
      tooltip: "Spam 2",
      buttonId: "spam2",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Copyvio}}~~" + "~~",
      imageFileName: "c/c9/Button_copy_vio.png",
      imageFileNameOOUI: "thumb/7/7e/Orange_copyright.svg/24px-Orange_copyright.svg.png",
      tooltip: "Copyvio",
      buttonId: "copyvio",
      group: "messages",
    },
    {
      tagOpen: "{{subst:" + "Copyvio2}}~~" + "~~",
      imageFileName: "7/72/Button_copy_vio_plagio.png",
      imageFileNameOOUI: "thumb/1/1d/Red_copyright.svg/24px-Red_copyright.svg.png",
      tooltip: "Copyvio 2",
      buttonId: "copyvio2",
      group: "messages",
    },
    {
      tagOpen: "{{sup" + "p|",
      tagClose: "}}",
      imageFileName: "f/f3/Button_broom2.png",
      imageFileNameOOUI: "thumb/d/de/OOjs_UI_icon_trash-destructive.svg/24px-OOjs_UI_icon_trash-destructive.svg.png",
      tooltip: "Suppression rapide",
      buttonId: "delete",
      group: "headers",
    },
    {
      tagOpen: "{{subst:" + "suppression à débattre|",
      tagClose: "}}~~" + "~~",
      imageFileName: "9/9f/Button_broom3.png",
      imageFileNameOOUI: "thumb/3/3f/OOjs_UI_icon_trash.svg/24px-OOjs_UI_icon_trash.svg.png",
      tooltip: "Proposition de suppression",
      buttonId: "delete-proposition",
      group: "headers",
    },
    {
      tagOpen: "== {{langue|fr}} ==\n=== {{S|étymologie}} ===\n{{ébauche-étym|fr}}\n:",
      tagClose: " {{" + "date|?|lang=fr}}/{{" + "siècle|?|lang=fr}}\n=== {{S|nom|fr}} ===\n{{fr-rég|}}\n'''{{subst:" + "PAGENAME}}''' {{pron||fr}} {{genre ?}}\n#\n#* ''''\n==== {{S|variantes orthographiques}} ====\n==== {{S|synonymes}} ====\n==== {{S|antonymes}} ====\n==== {{S|dérivés}} ====\n==== {{S|apparentés}} ====\n==== {{S|vocabulaire}} ====\n==== {{S|hyperonymes}} ====\n==== {{S|hyponymes}} ====\n==== {{S|méronymes}} ====\n==== {{S|holonymes}} ====\n==== {{S|traductions}} ====\n{{trad-début}}\n{{ébauche-trad}}\n{{trad-fin}}\n=== {{S|prononciation}} ===\n* {{pron||fr}}\n* {{écouter|<!--  précisez svp la ville ou la région -->||audio=|lang=}}\n==== {{S|homophones|fr}} ====\n==== {{S|paronymes}} ====\n=== {{S|anagrammes}} ===\n=== {{S|voir aussi}} ===\n* {{WP}}\n=== {{S|références}} ===\n{{clé de tri}}",
      imageFileName: "3/32/Button_anular_voto.png",
      imageFileNameOOUI: "thumb/8/81/OOjs_UI_icon_stripeFlow-ltr.svg/24px-OOjs_UI_icon_stripeFlow-ltr.svg.png",
      tooltip: "Patron long",
      buttonId: "long-template",
      group: "section_templates",
    },
    {
      tagOpen: "== {{langue|fr}} ==\n=== {{S|étymologie}} ===\n{{ébauche-étym" + "\|fr}}\n\n=== {{S|nom|fr}} ===\n{{fr-rég\|}}\n\'\'\'{{subst:" + "PAGENAME}}\'\'\' {{m}}\n# ",
      tagClose: "\n\n==== {{S|traductions}} ====\n{{trad-début}}\n{{ébauche-trad}}\n* {{T|en}}\u00a0: {{trad|en|}}\n{{trad-fin}}\n\n=== {{S|voir aussi}} ===\n* {{WP}}",
      imageFileName: "a/a7/Francefilm.png",
      imageFileNameOOUI: "thumb/7/71/OOjs_UI_icon_stripeSummary-ltr.svg/24px-OOjs_UI_icon_stripeSummary-ltr.svg.png",
      tooltip: "Patron court",
      buttonId: "short-template",
      group: "section_templates",
    },
    {
      tagOpen: "=== {{S|références}} ===\n==== {{S|sources}} ====\n{{Références}}\n\n==== {{S|bibliographie}} ====\n",
      imageFileName: "6/64/Buttonrefvs8.png",
      imageFileNameOOUI: "thumb/9/9c/OOjs_UI_icon_reference.svg/24px-OOjs_UI_icon_reference.svg.png",
      tooltip: "Références",
      buttonId: "references",
      group: "section_templates",
    },
    {
      tagOpen: "{{source| {{ouvrage| url= | titre= | prénom1= | nom1= | éditeur= | année= }} }}",
      imageFileName: "e/ef/Button_cite_book.png",
      imageFileNameOOUI: "thumb/5/5b/OOjs_UI_icon_quotesAdd-ltr.svg/24px-OOjs_UI_icon_quotesAdd-ltr.svg.png",
      tooltip: "Source d’exemple",
      buttonId: "source",
      group: "insert",
    },
    {
      tagOpen: "{{Autres projets\n|w=",
      tagClose: "\n|b=\n|v=\n|n=\n|s=\n|q=\n|commons=\n|wikispecies=\n|m=\n}}",
      imageFileName: "4/4c/Button_interprojet.png",
      imageFileNameOOUI: "thumb/4/40/Network_sans.svg/24px-Network_sans.svg.png",
      tooltip: "Autres projets",
      buttonId: "other-projects",
      group: "links",
    },
    {
      tagOpen: "{{" + "refnec|",
      tagClose: "|lang=<!-- Merci d’indiquer la langue -->}}",
      imageFileName: "0/0b/Button_fuente.png",
      imageFileNameOOUI: "thumb/6/69/OOjs_UI_icon_help.svg/24px-OOjs_UI_icon_help.svg.png",
      tooltip: "Référence nécessaire",
      buttonId: "refnec",
      group: "misc_templates",
    },
    {
      tagOpen: "{{" + "?|",
      tagClose: "|lang=<!-- Merci d’indiquer la langue -->}}",
      imageFileName: "8/89/Button_nosense.png",
      imageFileNameOOUI: "thumb/b/b2/OOjs_UI_icon_help-ltr.svg/24px-OOjs_UI_icon_help-ltr.svg.png",
      tooltip: "À vérifier",
      buttonId: "to-check",
      group: "misc_templates",
    },
  ],

  /**
   * Creates the Deluxe bar with the default buttons if the edit toolbar is disabled,
   * or adds the default buttons to the edit toolbar if enabled.
   */
  init: function () {
    var self = this;
    mw.loader.using("user.options").then(function () {
      if (mw.user.options.get("usebetatoolbar") === 1) {
        $.when(
            mw.loader.using("ext.wikiEditor")
        ).then(function () {
          var groups = {};

          for (var i = 0; i < self.groups.length; i++) {
            var group = self.groups[i];

            groups[group.id] = {
              label: group.label,
            };
          }

          wikt.edit.getEditBox().wikiEditor("addToToolbar", {
            section: self.sectionId,
            groups: groups,
          });
        });
      }
    });
    self.addButtons(self.defaultButtons);
  },

  /**
   * Adds the given list of buttons to the toolbar or Deluxe bar.
   * @param buttons {Array<Array<string>>|Array<Object<string,string>>} The buttons.
   */
  addButtons: function (buttons) {
    var self = this;

    /**
     * Converts legacy array format to current object format.
     * @param arrayButton The button as an array.
     * @return {Object} The button object.
     */
    function toObject(arrayButton) {
      return {
        tagOpen: arrayButton[0],
        tagClose: arrayButton[1],
        imageFileName: arrayButton[2],
        tooltip: arrayButton[3],
        buttonId: arrayButton[4],
      };
    }

    /**
     * Returns a standard button object.
     * @param button The button definition object.
     * @return {Object} The full button object.
     */
    function getButtonObject(button) {
      /**
       * Returns the full URL to the given button sub-URL.
       * If the sub-URL doesn’t feature an extension, .png is used.
       * @param urlEnd The end of the URL.
       * @return {string} The full URL.
       */
      function getFileName(urlEnd) {
        var fullUrl = "//upload.wikimedia.org/wikipedia/commons/{0}".format(urlEnd);

        if (!/\.\w+$/.test(fullUrl)) {
          fullUrl += ".png";
        }

        return fullUrl;
      }

      var b = {
        imageFile: getFileName(button.imageFileName),
        imageId: "mw-editbutton-" + button.buttonId,
        speedTip: button.tooltip,
        toolbarIgnore: button.toolbarIgnore,
        group: button.group || "default",
      };

      if (button.imageFileNameOOUI) {
        b["imageFileOOUI"] = getFileName(button.imageFileNameOOUI);
      }
      if (button.action) {
        b.onClick = function () {
          var inputText = prompt(button.promptText, button.promptDefault).trim();

          if (inputText) {
            var selectedText = wikt.edit.getSelectedText();
            var result = button.action(selectedText, inputText);
            wikt.edit.replaceSelectedText(result);
          }
        };
      }
      else {
        b.tagOpen = button.tagOpen;
        b.tagClose = button.tagClose || "";
      }

      return b;
    }

    mw.loader.using("user.options").then(function () {
      // 2010 edit toolbar
      if (mw.user.options.get("usebetatoolbar") === 1) {
        $.when(
            mw.loader.using("ext.wikiEditor")
        ).then(function () {
          buttons.forEach(function (button) {
            var buttonObject = {};
            var b = getButtonObject(button instanceof Array ? toObject(button) : button);
            var action;

            if (b.toolbarIgnore) {
              return;
            }

            if (b.onClick) {
              action = {
                type: "callback",
                execute: b.onClick,
              };
            }
            else {
              action = {
                type: "encapsulate",
                options: {
                  pre: b.tagOpen,
                  post: b.tagClose,
                },
              };
            }

            buttonObject[b.imageId] = {
              label: b.speedTip,
              type: "button",
              icon: b.imageFileOOUI || b.imageFile,
              action: action,
            };

            wikt.edit.getEditBox().wikiEditor("addToToolbar", {
              section: self.sectionId,
              group: b.group,
              tools: buttonObject,
            });
          });
        });
      } // MW toolbar
      else {
        mw.loader.using("ext.gadget.mediawiki.toolbar", function () {
          buttons.forEach(function (button) {
            mw.toolbar.addButton(getButtonObject(button instanceof Array ? toObject(button) : button));
          });
        });
      }
    });
  },
};

(function () {
  if (["edit", "submit"].includes(mw.config.get("wgAction"))) {
    console.log("Chargement de Gadget-Barre_de_luxe.js…");
    wikt.gadgets.barreDeLuxe.init();
    var username = mw.config.get("wgUserName");
    var url = "https://fr.wiktionary.org/wiki/User:{0}/barreDeLuxe.js?action=raw&ctype=text/javascript".format(username);
    var wg = wikt.gadgets;
    wikt.loadScripts([url]).done(function () {
      try {
        if (buttons && buttons instanceof Array) {
          wg.barreDeLuxe.addButtons(buttons); // Variable should be declared in user page.
        }
      }
      catch (e) {
        console.log("Gadget-Barre_de_luxe.js: Variable 'buttons' non définie.");
      }
    });
  }
})();
