local p = {}

--- Return a html formated version of text stylized as an error.
local function errorMessage(text)
  local html = mw.html.create("div")
  html:addClass("error")
      :wikitext(text)
      :wikitext("[[Catégorie:Pages faisant un appel erroné au modèle Auteur]]") -- TODO rename category
  return tostring(html)
end

local function toAbsoluteTitle(relativeTitle, baseTitle)
  -- FIXME hacky implementation
  return mw.getCurrentFrame():callParserFunction("#rel2abs", { relativeTitle, tostring(baseTitle or mw.title.getCurrentTitle()) })
end

local function formatString(str, schemaProperty)
  return tostring(mw.html.create("span")
                    :attr("itemprop", schemaProperty)
                    :wikitext(str)
  )
end

local function formatYear(date, schemaProperty)
  local year = tonumber(date)
  if year == nil or year < 1000 then
    return tostring(mw.html.create("span")
                      :attr("itemprop", schemaProperty)
                      :wikitext(date))
  else
    return tostring(mw.html.create("time")
                      :attr("datetime", year)
                      :attr("itemprop", schemaProperty)
                      :wikitext(date))
  end
end

local function formatPublisherWithName(name)
  return tostring(mw.html.create("span")
                    :attr("itemprop", "publisher")
                    :attr("itemscope", "")
                    :attr("itemtype", "http://schema.org/Thing") -- TODO better types
                    :tag("span")
                    :attr("itemprop", "name")
                    :wikitext(name)
                    :done()
  )
end

local function formatLink(page, label, schemaProperty)
  local title = mw.title.new(toAbsoluteTitle(page))
  if title == nil then
    return tostring(mw.html.create("span")
                      :attr("itemprop", schemaProperty)
                      :attr("itemscope", "")
                      :attr("itemtype", "http://schema.org/Thing") -- TODO better types
                      :wikitext(mw.ustring.format('[[%s|<span itemprop="name">%s</span>]]', page, label))
    )
  end
  if title.isRedirect then
    title = title.redirectTarget
  end
  local tag = mw.html.create("span")
                :attr("itemprop", schemaProperty)
                :attr("itemscope", "")
                :attr("itemtype", "http://schema.org/Thing") -- TODO better types
                :wikitext(mw.ustring.format('[[%s|<span itemprop="name">%s</span>]]', title.fullText, label))
                :tag("link")
                :attr("itemprop", "mainEntityOfPage")
                :attr("href", title:fullUrl(nil, "canonical"))
                :done()
  local itemId = mw.wikibase.getEntityIdForTitle(title.fullText)
  if itemId ~= nil then
    tag:attr("itemid", "http://www.wikidata.org/entity/" .. itemId)
  end
  return tostring(tag)
end

local function parseWikitextLinks(wikitext, schemaProperty)
  wikitext = mw.ustring.gsub(wikitext, "%[%[([^|]*)|(.*)%]%]", function(page, link)
    return formatLink(page, link, schemaProperty)
  end)
  wikitext = mw.ustring.gsub(wikitext, "%[%[([^|]*)%]%]", function(page)
    return formatLink(page, mw.ustring.gsub(page, "%.*/", ""), schemaProperty)
  end)
  return wikitext
end

local function formatTitleLink(page, label, schemaProperty)
  local title = mw.title.new(toAbsoluteTitle(page))
  if title == nil then
    return "[[" .. page .. "|" .. label .. "]]"
  end
  if title.isRedirect then
    title = title.redirectTarget
  end
  local tag = mw.html.create("span")
                :attr("itemprop", schemaProperty)
                :attr("itemscope", "")
                :attr("itemtype", "http://schema.org/CreativeWork") -- TODO find a more relenvant type
                :wikitext(mw.ustring.format('[[%s|<span itemprop="name">%s</span>]]', title.fullText, label))
                :tag("link")
                :attr("itemprop", "mainEntityOfPage")
                :attr("href", title:fullUrl(nil, "canonical"))
                :done()
  local itemId = mw.wikibase.getEntityIdForTitle(title.fullText)
  if itemId ~= nil then
    tag:attr("itemid", "http://www.wikidata.org/entity/" .. itemId)
  end
  return tostring(tag)
end

local function parseTitleWikitext(wikitext, schema_property)
  wikitext = mw.ustring.gsub(wikitext, "%[%[([^|]*)|(.*)%]%]", function(page, link)
    return formatTitleLink(page, link, schema_property)
  end)
  wikitext = mw.ustring.gsub(wikitext, "%[%[([^|]*)%]%]", function(page)
    return formatTitleLink(page, page, schema_property)
  end)
  return wikitext
end

local function pagination(from, to)
  if from ~= "" and to ~= "" then
    if from == to then
      return '<abbr title="paĝo">p.</abbr>&nbsp;' .. formatString(from, "pagination")
    else
      return '<abbr title="paĝoj">p.</abbr>&nbsp;' .. formatString(from, "pageStart") .. "-" .. formatString(to, "pageEnd")
    end
  end
end

local function outputMicroformatRow(name, value)
  return mw.html.create("span")
           :addClass("ws-" .. name)
           :wikitext(value)
end

local function cleanCoinsParameter(param)
  param = string.gsub(param, "%[%[.*|(.*)%]%]", "%1")
  return string.gsub(param, "%[%[(.*)%]%]", "%1")
end

function p.headerTemplate(frame)
  local parentFrame = frame:getParent()
  local data = require("Modulo:Index data").indexDataWithWikidata(parentFrame)
  local args = data.args
  local page = mw.title.getCurrentTitle()
  local item = mw.wikibase.getEntity()
  local headerType = args.value
  if args.header_type then
    headerType = args.header_type
  end

  headerType = mw.ustring.lower(headerType)
  -- "toc" is the default value if neither "header_type", "from" nor "to" are specified
  local isTOC = (headerType == "enhavo" or headerType == "toc")

  -- Custom page numbers
  local from = ""
  if args.displayed_from then
    from = args.displayed_from
  elseif args.from then
    from = args.from
  end

  local to = ""
  if args.displayed_to then
    to = args.displayed_to
  elseif args.to then
    to = args.to
  end

  local schemaRoot = "http://schema.org/"
  local schemaType = "CreativeWork"
  if args["tipo"] then
    if args["tipo"] == "book" then
      if isTOC then
        schemaType = "http://schema.org/Book"
      else
        schemaType = "http://schema.org/Chapter"
      end
    elseif args["tipo"] == "collection" then
      if isTOC then
        schemaType = "https://schema.org/Collection"
      end
    elseif args["tipo"] == "journal" then
      if isTOC then
        schemaType = "https://schema.org/PublicationVolume"
      else
        schemaType = "http://schema.org/Article"
      end
    elseif args["tipo"] == "phdthesis" then
      if isTOC then
        schemaType = "http://schema.org/Thesis"
      else
        schemaType = "http://schema.org/Chapter"
      end
    end
  end

  -- Header start
  local html = mw.html.create()
  local container = html:tag("div")
                        :attr("itemscope", "")
                        :attr("itemtype", schemaRoot .. schemaType)
  if item then
    container:attr("itemid", "http://www.wikidata.org/entity/" .. item.id)
  end

  if args.header_type == "empty" then
    if args["enhavo"] then
      container:tag("div")
               :addClass("ws-summary")
               :css("margin-top", "1em")
               :newline()
               :wikitext(args["enhavo"])
    end
    return html
  end

  local headerTemplate = container:tag("div")
                                  :attr("id", "headertemplate")
                                  :addClass("ws-noexport")
                                  :tag("div")
                                  :css("border", "1px solid rgb(170, 221, 170)")
                                  :css("background-color", "rgb(228, 242, 228)")
                                  :css("text-align", "center")
                                  :css("font-size", "0.9em")

  if args["tipo"] == "journal" then
    headerTemplate:addClass("headertemplate-journal")
  else
    headerTemplate:addClass("headertemplate")
  end

  -- Title
  local title = formatString(page.baseText, "name")
  if args["tipo"] == "collection" then
    if args.current then
      title = formatString(args.current, "name")
    else
      if isTOC then
        title = formatString(title, "name")
      else
        title = parseTitleWikitext(title, "isPartOf")
      end
    end
  elseif args["tipo"] == "journal" then
    if isTOC then
      title = formatString(args["titolo"], "name")
    elseif args.current then
      title = formatString(args.current, "name")
    else
      title = parseTitleWikitext(title, "isPartOf")
    end
  else
    if args["titolo"] then
      title = args["titolo"]
    end
    if isTOC then
      title = formatString(title, "name")
    else
      title = parseTitleWikitext(title, "isPartOf")
    end
  end
  if args["jaro"] then
    title = mw.ustring.format("%s (%s)", title, formatYear(args["jaro"], "datePublished"))
  end
  if args["subtitolo"] then
    title = mw.ustring.format("%s<br/><small>%s</small>", title, args["subtitolo"])
  end
  headerTemplate:tag("div")
                :addClass("headertemplate-title")
                :wikitext(title)

  -- Author
  if args["aŭtoro"] then
    headerTemplate:tag("div")
                  :addClass("headertemplate-author")
                  :wikitext(mw.ustring.format("''de %s''", parseWikitextLinks(args["aŭtoro"], "author")))
  end

  -- References
  local references = headerTemplate:tag("div")
                                   :addClass("headertemplate-reference")
  if args["tradukinto"] then
    references:wikitext(mw.ustring.format("Tradukita de ''%s''", parseWikitextLinks(args["tradukinto"], "translator")))
              :tag("br")
  end

  if isTOC and args["volumo"] then
    references:wikitext(formatString(args["volumo"], "volumeNumber"))
              :tag("br")
  end

  local infos = {} -- Liste des données à afficher séparés par une virgule
  if args["tipo"] == "collection" then
    if args["titolo"] then
      table.insert(infos, mw.ustring.format("<i>%s</i>", parseTitleWikitext(args["titolo"], "isPartOf")))
    end
    if args["eldonejo"] then
      table.insert(infos, formatPublisherWithName(args["eldonejo"]))
    end
    if not isTOC then
      if args["volumo"] then
        table.insert(infos, formatString(args["volumo"], "volumeNumber"))
      end
    end

  elseif args["tipo"] == "journal" then
    if not isTOC then
      table.insert(infos, mw.ustring.format("<i>%s</i>", parseTitleWikitext(args["titolo"], "isPartOf")))
      if args["volumo"] then
        table.insert(infos, formatString(args["volumo"], "volumeNumber"))
      end
    end

  else
    if args["eldonejo"] then
      table.insert(infos, formatPublisherWithName(args["eldonejo"]))
    end
    if args["eldona_loko"] then
      table.insert(infos, formatString(args["eldona_loko"], "place"))
    end
  end

  local line = ""
  if infos ~= {} then
    line = table.concat(infos, ",&nbsp;")
  end

  -- Brackets
  if not isTOC and from ~= "" then
    local bracketsContent = ""
    if args["volumo"] and args["tipo"] ~= "collection" and args["tipo"] ~= "journal" then
      bracketsContent = formatString(args["volumo"], "volumeNumber") .. ",&nbsp;"
    end
    if from ~= to or from ~= "-" then
      bracketsContent = bracketsContent .. pagination(from, to)
    end

    if bracketsContent ~= "" then
      line = line .. " (" .. bracketsContent .. ")"
    end
  end

  if line ~= '' then
    references:wikitext(line)
  end

  local subheader = container:tag("div")
                             :attr("id", "subheader")
                             :addClass("ws-noexport")
                             :css("margin-bottom", "1.5em")
  if isTOC then
    local fullText = mw.title.new(page.prefixedText .. "/Kompleta teksto")
    if fullText and fullText.exists then
      subheader:tag("div")
               :css("text-align", "center")
               :wikitext("[[" .. fullText.fullText .. "|Kompleta teksto en sama paĝo]]")
    end
  end

  if (not isTOC or (args.header_type and args.header_type == "toc")) and (args.prev or args.next) then
    local maxWidth = 50
    if args["tipo"] ~= "collection" and args.current then
      maxWidth = 33
    end
    local footer = subheader:tag("div")
                            :addClass("footertemplate")
                            :addClass("ws-noexport")
    local nav = footer:tag("div")
                      :css("width", "100%")
                      :css("padding-left", "0")
                      :css("padding-right", "0")
                      :css("background-color", "transparent")
    if args.prev then
      nav:tag("div")
         :css("text-align", "left")
         :css("float", "left")
         :css("max-width", maxWidth .. "%")
         :tag("span")
         :attr("id", "headerprevious")
         :tag("span")
         :css("color", "#808080")
         :wikitext("◄&nbsp;&nbsp;")
         :done()
         :wikitext(parseWikitextLinks(args.prev, "previousItem"))
    end
    if args.next then
      nav:tag("div")
         :css("text-align", "right")
         :css("float", "right")
         :css("max-width", maxWidth .. "%")
         :tag("span")
         :attr("id", "headernext")
         :wikitext(parseWikitextLinks(args.next, "nextItem"))
         :tag("span")
         :css("color", "#808080")
         :wikitext("&nbsp;&nbsp;►")
    end
    if args["tipo"] ~= "collection" and args.current then
      nav:tag("div")
         :attr("itemprop", "name")
         :css("text-align", "center")
         :css("margin-left", "25%")
         :css("margin-right", "25%")
         :wikitext(args.current)
    end
    footer:tag("div")
          :css("clear", "both")
  end

  -- Categories
  if isTOC and (not item or not item["claims"] or not item["claims"]["P629"]) then
    container:wikitext("[[Kategorio:Eldono sen ligita verko]]")
  end

  -- Include TOC
  if headerType == "toc" then
    -- If only "index" is specified in <pages/>, fetch "enhavo" field from index and transclude it after the header
    container:tag("div")
             :addClass("ws-summary")
             :css("margin-top", "1em")
             :wikitext(args["enhavo"])
  elseif headerType == "enhavo" then
    -- If header_type="enhavo" is specified, add an opening <div> to wrap custom TOC
    html:wikitext('<div id="ws-summary">') -- FIXME Bad hack, outputs unbalanced HTML
  end

  -- Additonal schema.org metadata
  container:tag("link")
           :attr("itemprop", "mainEntityOfPage")
           :attr("href", page:fullUrl(nil, "canonical"))
  container:tag("meta")
           :attr("itemprop", "inLanguage")
           :attr("content", "eo")
  if args["eldona_loko"] then
    container:tag("meta")
             :attr("itemprop", "http://purl.org/library/placeOfPublication")
             :attr("content", args["eldona_loko"]) -- FIXME Is it the best property URI and the best value format?
  end
  if args.index then
    local indexFile = mw.title.makeTitle("File", args.index)
    if indexFile ~= nil and indexFile.file.exists then
      container:tag("span")
               :attr("itemprop", "associatedMedia")
               :attr("itemscope", "")
               :attr("itemtype", "http://schema.org/MediaObject")
               :tag("link")
               :attr("itemprop", "mainEntityOfPage")
               :attr("href", indexFile:fullUrl(nil, "canonical"))
               :done()
               :tag("meta")
               :attr("itemprop", "width")
               :attr("content", indexFile.file.width)
               :done()
               :tag("meta")
               :attr("itemprop", "height")
               :attr("content", indexFile.file.height)
               :done()
               :tag("meta")
               :attr("itemprop", "fileFormat")
               :attr("content", indexFile.file.mimeType)
               :done()
    end
  end

  -- Metadata, see http://ocoins.info/ for coins.
  local coins = {}
  local uriCoins = "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A"
  coins["rft.genre"] = "unknown"
  coins["rfr_id"] = tostring(page:fullUrl(nil, "canonical"))
  local datahtml = container:tag("div")
                            :attr("id", "ws-data")
                            :addClass("ws-noexport")
                            :css("display", "none")
                            :css("speak", "none")
  if args["tipo"] then
    datahtml:node(outputMicroformatRow("type", args["tipo"]))
  end
  if args["tipo"] and args["tipo"] == "journal" then
    uriCoins = uriCoins .. "journal"
    if isTOC then
      coins["rft.genre"] = "publication"
      coins["rft.jtitle"] = cleanCoinsParameter(args["titolo"])
    else
      coins["rft.genre"] = "article"
      coins["rft.atitle"] = cleanCoinsParameter(args["titolo"])
      if args["titolo"] then
        coins["rft.jtitle"] = cleanCoinsParameter(args["titolo"])
        datahtml:node(outputMicroformatRow("periodical", cleanCoinsParameter(args["titolo"])))
      end
    end
  else
    uriCoins = uriCoins .. "book"
    if isTOC then
      coins["rft.btitle"] = cleanCoinsParameter(args["titolo"])
    else
      coins["rft.atitle"] = cleanCoinsParameter(args["titolo"])
    end
    if args["tipo"] and args["tipo"] == "book" then
      if isTOC then
        coins["rft.genre"] = "book"
      else
        coins["rft.genre"] = "bookitem"
      end
    end
  end
  datahtml:node(outputMicroformatRow("title", args["titolo"]))
  if args["aŭtoro"] then
    datahtml:node(outputMicroformatRow("author", args["aŭtoro"]))
    coins["rft.au"] = cleanCoinsParameter(args["aŭtoro"])
  end
  if args["tradukinto"] then
    datahtml:node(outputMicroformatRow("translator", args["tradukinto"]))
  end
  --if args.illustrateur then
  --  datahtml:node(outputMicroformatRow("illustrator", args.illustrateur))
  --end
  --if args.school then
  --  datahtml:node(outputMicroformatRow("school", args.school))
  --end
  if args["eldonejo"] then
    datahtml:node(outputMicroformatRow("publisher", args["eldonejo"]))
    coins["rft.pub"] = cleanCoinsParameter(args["eldonejo"])
  end
  if args["jaro"] then
    datahtml:node(outputMicroformatRow("year", args["jaro"]))
    coins["rft.date"] = args["jaro"]
  end
  if args["eldona_loko"] then
    datahtml:node(outputMicroformatRow("place", args["eldona_loko"]))
    coins["rft.place"] = args["eldona_loko"]
  end
  if args["progreso"] then
    datahtml:node(outputMicroformatRow("progress", args["progreso"]))
  end
  if args["volumo"] then
    datahtml:node(outputMicroformatRow("volume", args["volumo"]))
  end
  --if args.current then
  --  datahtml:node(outputMicroformatRow("chapter", args.current))
  --end
  if args.index then
    datahtml:node(outputMicroformatRow("scan", args.index))
    local imageTitle
    if tonumber(args.image) ~= nil then
      imageTitle = mw.title.new(args.index, "Media"):subPageTitle(args.image)
    elseif args.image ~= nil then
      imageTitle = mw.title.new(args.image, "Media")
    end
    if imageTitle ~= nil then
      datahtml:node(outputMicroformatRow("cover", imageTitle.text))
    end
  end
  if from ~= "" and to ~= "" then
    if from == to then
      datahtml:node(outputMicroformatRow("pages", from))
    else
      datahtml:node(outputMicroformatRow("pages", from .. "-" .. to))
    end
    coins["rft.spage"] = from
    coins["rft.epage"] = to
  end
  datahtml:tag("span")
          :addClass("Z3988")
          :attr("title", uriCoins .. "&" .. mw.uri.buildQueryString(coins))
          :wikitext("&nbsp;")

  return html
end

-- TODO adapt
function p.voirEditions(frame)
  local args = frame:getParent().args
  if not args[1] or args[1] == "" then
    return errorMessage("Le modèle VoirEdition prend en paramètre un lien vers la liste des éditions")
  end

  local node = mw.html.create("small")
                 :addClass("ws-noexport")
                 :css({
    ["text-align"] = "center",
    ["font-style"] = "italic"
  })
                 :attr("itemscope", "")
                 :attr("itemtype", "http://schema.org/CreativeWork")

  local itemId = mw.wikibase.getEntityIdForCurrentPage()
  if itemId ~= nil then
    node:attr("itemid", "http://www.wikidata.org/entity/" .. itemId)
  end

  node:wikitext("[[Image:List2.svg|25px|lien=]] Pour les autres éditions de ce texte, voir ")
      :wikitext(parseTitleWikitext(args[1], "exampleOfWork"))
      :wikitext(".")

  return tostring(node)
end

return p
