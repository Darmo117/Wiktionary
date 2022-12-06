(function () {
  function replaceAll(matches, text, replacementFunction) {
    Array.from(matches).forEach(function (match) {
      text = text.replace(match[0], replacementFunction(match));
    });

    return text;
  }

  function escapeHtml(s) {
    return s.replace(/&/g, "&amp;").replace(/"/g, "&quot;")
        .replace(/'/g, "&apos;").replace(/</g, "&lt;");
  }

  /**
   * Parse les sources JS ou Lua pour ajouter des liens vers les URL ou des pages wiki.
   */
  function parseScript() {
    var e = $(this);
    var s = e.text();

    if (!s.match(/{\d+}/)) {
      var uri = new mw.Uri(window.location.href);
      var url = "{0}://{1}/wiki/".format(uri.protocol, uri.host);
      // Escape HTML tags
      var text = escapeHtml(s);
      var match;

      // Namespaced pages
      if (match = text.match(/^(&apos;|&quot;)([^\s\[{(%?^\-+*$/.|:<>&]+?:[^\/].*?)\1$/)) {
        var page = match[2];
        var quotes = match[1];
        // noinspection HtmlUnknownTarget
        text = '{0}<a style="text-decoration:underline;" href="{1}{2}">{2}</a>{0}'
            .format(quotes, url, page);
        e.html(text.replace(match[0], text));
      }
      else {
        var matches;

        // URLs
        if (matches = text.matchAll(/((?:https?:)?\/\/[^\s]+?\.\w+\/[^\s]+?)(?=\s|&apos;|&quot;|$)/g)) {
          text = replaceAll(matches, text, function (match) {
            var page = match[1];
            // noinspection HtmlUnknownTarget
            return '<a class="external" style="text-decoration:underline;" href="{0}" target="_blank">{0}</a>'
                .format(page);
          });
        }
        // Links
        if (matches = text.matchAll(/\[\[(.+?)(?=\||]])/g)) {
          text = replaceAll(matches, text, function (match) {
            var page = match[1].trim();
            // noinspection HtmlUnknownTarget
            return '[[<a style="text-decoration:underline;" href="{0}{1}">{1}</a>'
                .format(url, page);
          });
        }
        // Invoked modules
        if (matches = text.matchAll(/{{#invoke:([^{#]+?)(?=\||}})/g)) {
          text = replaceAll(matches, text, function (match) {
            var modulePage = match[1].trim();
            // noinspection HtmlUnknownTarget
            return '{{#invoke:<a style="text-decoration:underline;" href="{0}Module:{1}">{1}</a>'
                .format(url, modulePage);
          });
        }
        // Templates
        if (matches = text.matchAll(/{{([^{#]+?)(?=\||}})/g)) {
          text = replaceAll(matches, text, function (match) {
            var templatePage = match[1].trim();
            // noinspection HtmlUnknownTarget
            return '{{<a style="text-decoration:underline;" href="{0}Modèle:{1}">{1}</a>'
                .format(url, templatePage);
          });
        }
        // Lua doc @param tags
        if (matches = text.matchAll(/@param(\s+)((?:\w+|\.\.\.)+?)(\s+)((?:table|string|boolean|number|function|any|file|thread|void|nil|\||,)+?)(?=\s|$)/g)) {
          text = replaceAll(matches, text, function (match) {
            var paramName = match[1];
            var ws1 = match[2];
            var paramType = match[3];
            var ws2 = match[4];
            return '<span class="ct">@param</span>{0}<span class="cpn">{1}</span>{2}<span class="cpt">{3}</span>'
                .format(paramName, ws1, paramType, ws2);
          });
        }
        // Lua doc @return tag
        if (matches = text.matchAll(/@(returns?)(\s+)((?:table|string|boolean|number|function|any|file|thread|void|nil|\||,)+?)(?=\s|$)/g)) {
          text = replaceAll(matches, text, function (match) {
            var tag = match[1];
            var ws = match[2];
            var type = match[3];
            return '<span class="ct">@{0}</span>{1}<span class="cpt">{2}</span>'
                .format(tag, ws, type);
          });
        }
        // Doc comments
        if (match = text.match(/^(\s*)---(.*)$/)) {
          var ws = match[1];
          var comment = match[2];
          text = '{0}<span class="cd">---{1}</span>'.format(ws, comment);
        }

        if (matches || match) {
          e.html(text);
        }
      }
    }
  }

  $(".mw-highlight .s1").each(parseScript);
  $(".mw-highlight .s2").each(parseScript);
  $(".mw-highlight .sb").each(parseScript);
  $(".mw-highlight .sx").each(parseScript);
  $(".mw-highlight .c1").each(parseScript);
  $(".mw-highlight .cm").each(parseScript);

  /**
   * Parse un type d’instruction Lua dans l’éditeur pour ajouter des liens vers les URL ou des pages wiki.
   * @param e {Object} L’objet jQuery.
   * @param type {string} Le type d’instruction (template, module, link ou extlink).
   */
  function parseLuaStatement(e, type) {
    function addClick(element, link) {
      element.css("cursor", "pointer");
      element.attr("title", "Ctrl + Clic pour ouvrir");
      element.on("click", function (event) {
        if (event.ctrlKey) {
          window.open(link);
        }
      });
    }

    var s = e.text();

    switch (type) {
      case "template": {
        addClick(e, "/wiki/Modèle:" + s);
        break;
      }
      case "module": {
        var sep = e.next();
        if (sep.hasClass("cm-mw-parserfunction-delimiter")) {
          var moduleName = sep.next();
          if (moduleName.hasClass("cm-mw-parserfunction")) {
            addClick(moduleName, "/wiki/Module:" + moduleName.text());
          }
        }
        break;
      }
      case "link": {
        var link = "/wiki/";
        if (s.startsWith("/")) {
          link += new mw.Uri(window.location.href).query["title"];
        }
        link += s;
        var anchorSymbol = e.next();
        if (anchorSymbol.hasClass("cm-mw-link")) {
          var anchor = anchorSymbol.next();
          link += "#";
          if (anchor.hasClass("cm-mw-link-tosection")) {
            link += anchor.text();
            addClick(anchor, link);
          }
          addClick(anchorSymbol, link);
        }
        addClick(e, link);
        break;
      }
      case "extlink": {
        var url = e.next().text();
        addClick(e, s + url);
        break;
      }
    }
  }

  /**
   * Parse le code Lua dans l’éditeur pour ajouter des liens vers les URL ou des pages wiki.
   */
  function parseLuaCode() {
    $(".wikiEditor-ui-text .cm-mw-template-name").each(function (e) {
      parseLuaStatement($(e), "template");
    });

    $(".wikiEditor-ui-text .cm-mw-parserfunction-name").each(function (e) {
      parseLuaStatement($(e), "module");
    });

    $(".wikiEditor-ui-text .cm-mw-link-pagename").each(function (e) {
      parseLuaStatement($(e), "link");
    });
    $(".wikiEditor-ui-text .cm-mw-extlink-protocol").each(function (e) {
      parseLuaStatement($(e), "extlink");
    });

    console.log("Overhaul-Sources: Parsing done.");
  }

  // FIXME n’est pas activé
  //.wikiEditor-ui .CodeMirror-code .noime
  $(".CodeMirror-line").on("change", parseLuaCode);
})();
