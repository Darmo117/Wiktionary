// <nowiki>
$(function () {
  "use strict";

  if (mw.config.get("wgCanonicalNamespace") === "Page" && $.inArray(mw.config.get("wgAction"), ["edit", "submit"]) !== -1) {
    var helper = {
      getData: function (data, pagename) {
        for (var ids in data.query.pages) {
          if (ids > 0 && data.query.pages[ids].title === pagename) {
            return data.query.pages[ids];
          }
        }
        return null;
      },

      lastMatch: function (regex, text) {
        var last_match = null;
        var match;
        while (match = regex.exec(text)) {
          last_match = match;
        }
        return last_match;
      },

      hasHypen: function () {
        var textbox = document.getElementById("wpTextbox1");
        return !textbox || textbox.value.search(/{{([Vv])df *(\|[^}]*)}}/) !== -1;
      },

      hasNowikiTag: function () {
        var textbox = document.getElementById("wpTextbox1");
        return !textbox || textbox.value.search(/<nowiki *\/>/) !== -1;
      },

      splitContent : function (content) {
        var result = {}
        var re = /^<noinclude>([\s\S]*?)\n*<\/noinclude>([\s\S]*)<noinclude>([\s\S]*?)<\/noinclude>\n*$/;
        var m = content.match(re);
        if (m) {
          result['header'] = m[1];
          result['body']   = m[2];
          result['footer'] = m[3];
        } else {
          var re2 = /^<noinclude>([\s\S]*?)\n*<\/noinclude>([\s\S]*?)\n$/;
          var m2 = content.match(re2);
          if (m2) {
            result['header'] = m2[1];
            // IE & Opera mis-implement non greedy match
            var re3 = /^([\s\S]*)<noinclude>([\s\S]*)<\/noinclude>\s*$/;
            var m3 = m2[2].match( re3 );
            if (m3) {
              result['body']   = m3[1];
              result['footer'] = m3[2];
            } else {
              result['body']   = m2[2];
              result['footer'] = '';
            }
          }
        }
        return result;
      },

      hypenAndNowikiTag: function () {
        if (!this.hasHypen() || !this.hasNowikiTag()) {
          var r = new RegExp("(\\d+)$");
          var page = parseInt(r.exec(mw.config.get("wgPageName"))[1]);

          this.pagename = "Paĝo:" + mw.config.get("wgTitle").replace(/\d+$/g, page - 2);
          this.previous_page = "Paĝo:" + mw.config.get("wgTitle").replace(/\d+$/g, page - 1);

          $.ajax({
            url: mw.config.get("wgServer") + mw.util.wikiScript("api"),
            dataType: "json",
            data: {
              "format": "json",
              "action": "query",
              "titles": this.pagename + "|" + this.previous_page,
              "prop": "revisions",
              "rvprop": "content",
            },
            success: this.fill_rh.bind(this)
          });
        }
      },

      fill_rh: function (data) {
        var apiPage = this.getData(data, this.previous_page);
        if (apiPage) {
          // noinspection JSUnresolvedVariable
          var content = apiPage.revisions[0]['*'];
          this.insertVdfTemplate(content);
          this.insertNowikiTag(content);
        }
      },

      insertVdfTemplate: function (previousPageContent) {
        var wpTextbox1 = document.getElementById("wpTextbox1");
        if (wpTextbox1 && !this.hasHypen()) {
          var tiret = new RegExp(/{{([Vv])dk *\|(.*?)\|(.*?)}}/);
          var match = tiret.exec(previousPageContent);
          if (match) {
            // TODO adapt to vdk/vdf
            /* {{tiret|dit|-il}} --> {{tiret2|dit-|il}}  et {{tiret|''aban|don''}} --> {{tiret2|aban|don}} */
            var part1 = match[2].replace(/''(.*)''/, "$1");
            part1 = part1.replace(/''(.*)/, "$1");
            part1 = part1.replace(/(.*)''/, "$1");
            var part2 = match[3];
            part2 = part2.replace(/''(.*)/, "$1");
            part2 = part2.replace(/(.*)''/, "$1");
            var hasItalic = false;
            if (part1 !== match[2] || part2 !== match[3])
              hasItalic = true;
            if (part2[0] === '-') {
              part2 = part2.slice(1);
              part1 += '-';
            }

            var text = wpTextbox1.value;

            var section = text.match(/^##[^#]*##\n(<nowiki[ ]*\/>\n\n)?/);
            if (!section) {
              section = [""];
              text = text.replace(/^<nowiki[ ]*\/>\n\n*(.*)/, "$1");
            }

            text = text.slice(section[0].length);

            var offset = text.indexOf(part2);
            if (offset !== -1 && offset < 16)
              text = text.slice(offset + part2.length);

            var tiret2 = match[0].replace(tiret, "{" + "{$1iret2|" + part1 + "|" + part2 + "}}");
            if (text.search(/[a-zA-Zçéèà]/) === 0)
              text = " " + text;

            if (hasItalic)
              tiret2 = "''" + tiret2;

            wpTextbox1.value = section[0] + tiret2 + text;
          }
        }
      },

      insertNowikiTag: function (previousPageContent) {
        if (this.hasHypen())
          return;

        var wpTextbox1 = document.getElementById("wpTextbox1");
        if (!wpTextbox1 || this.hasNowikiTag())
          return;

        /* First check if the text start with a <br />, if yes replace it by a nowiki and return */
        var content = wpTextbox1.value;
        var section = content.match(/^##[^#]*##\n/);
        if (!section)
          section = [""];
        content = content.slice(section[0].length);
        if (content.search(/^<br *\/?>/) === 0) {
          content = section[0] + content.replace(/^<br *\/>/, "<nowiki/>");
          wpTextbox1.value = content;
          return;
        }

        // FIXME: do we need all of this or only rely on the previous page content finishing by a [.?!»] ?
        previousPageContent = this.splitContent(previousPageContent)['body'];
        previousPageContent = previousPageContent.replace(/<ref>(.|\n)*?<\/ref>/gm, '');
        var lines = previousPageContent.split('\n');
        /* bug du '\n' https://bugzilla.wikimedia.org/show_bug.cgi?id=26028 */
        while (lines.length && lines[lines.length - 1].length === 0) {
          lines.pop();
        }
        var countEmpty = 0;
        for (var i in lines) {
          if (!lines[i].length) {
            countEmpty += 1;
          }
        }

        content = wpTextbox1.value.replace(/\s*(.)/, "$1");
        var match = previousPageContent.match(/([.!?»]<section end="[^"]*"\/>|[.!?»])$/);
        var avg_length = previousPageContent.length / (lines.length - countEmpty);
        var last_length = lines[lines.length - 1].length;
        if (avg_length > 30 && avg_length < 100 && last_length < avg_length * 0.60) {
          if (content.length) {
            wpTextbox1.value = '<nowiki />\n\n' + content;
          }
        } else if (match) {
          if (content.length) {
            wpTextbox1.value = '<nowiki />\n\n' + content;
          }
        }
      },

      exec: function (level) {
        this.level = level;
        /* for auto run level, check if we are inhibited by another gadget, this
         * allow for another gadget to take over this one and use it as a library,
         * typically because it wants to do its own api request.
         */
        if (level === "auto_create") {
          this.hypenAndNowikiTag();
        } else if (level === "on_button") {
          this.hypenAndNowikiTag();
        } else {
          mw.log("helper.exec(level) called with unknown level: " + level);
        }
      },

      editForm: function () {
        // TODO import gadget https://fr.wikisource.org/wiki/MediaWiki:Gadget-InsertButton.js
        window.insert_button.editForm({
          "img_classic": "//upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Button_running_header.svg/23px-Button_running_header.svg.png",
          "img_advanced": "//upload.wikimedia.org/wikipedia/commons/c/c1/LibreOffice_3.4_tango_icon_lc_graphicfiltertoolbox.png",
          "tooltip": "Mise en page",
          "img_id": "wsMiseEnPage",
          "on_click": function () {
            helper.exec("on_button");
          }
        });
      },

    };

    if ($(".mw-newarticletext").length) {
      helper.exec("auto_create");
    } else {
      helper.exec("auto_edit");
    }
    mw.loader.using("user.options").done(helper.editForm);
  }
});
// </nowiki>
