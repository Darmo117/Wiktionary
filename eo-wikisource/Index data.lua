local p = {}

local wikidataTypeToIndexType = {
  ['Q3331189'] = 'book',
  ['Q1238720'] = 'journal',
  ['Q28869365'] = 'journal',
  ['Q191067'] = 'journal',
  ['Q23622'] = 'dictionary',
  ['Q187685'] = 'phdthesis'
}

local indexToWikidata = {
  -- titolo, tipo and bildo are special cases
  --['sous_titre'] = 'P1680',
  --['volume'] = 'P478',
  ['aŭtoro'] = 'P50',
  ['tradukinto'] = 'P655',
  --['editeur_scientifique'] = 'P98',
  --['illustrateur'] = 'P110',
  ['eldonejo'] = 'P123',
  --['lieu'] = 'P291',
  ['jaro'] = 'P577',
  --['epigraphe'] = 'P7150',
}

--- Fetch data from index page and Wikidata element.
--- @param frame table The frame from the transclusion page.
--- @return table A table with two keys: args = the index/Wikidata values, item = the Wikidata item.
function p.indexDataWithWikidata(frame)
  local args = frame.args
  local item

  if args.wikidata_item and args.wikidata_item ~= '' then
    item = mw.wikibase.getEntity(args.wikidata_item)
    if item == nil then
      mw.addWarning(mw.ustring.format(
          "La Vikidatumoj-idendigilo [[d:%s|%s]] en la wikidata_item parametro de la Indekso: paĝo ŝajnas nevalidan.",
          args.wikidata_item, args.wikidata_item
      ))
    end
  end

  local argsWithMeta = {}
  local argsCache = {}
  -- we lazily load attributes (in order to avoid extra costly functions if the data is actually not used)
  setmetatable(argsWithMeta, {
    __index = function(_, arg)
      if not argsCache[arg] then
        -- we load in cache
        argsCache[arg] = '' -- dummy value to say we already looked for the value
        if args[arg] and args[arg] ~= '' then
          if args[arg] ~= '-' or arg == 'from' or arg == 'to' then
            -- we ignore the value "-" except for "from" and "to"
            argsCache[arg] = args[arg]
          end
        elseif item then
          -- we load from Wikidata
          argsCache[arg] = ''
          if arg == 'tipo' then
            for _, statement in pairs(item:getBestStatements('P31')) do
              if statement.mainsnak.datavalue ~= nil then
                local typeId = statement.mainsnak.datavalue.value
                if wikidataTypeToIndexType[typeId] then
                  argsCache.type = wikidataTypeToIndexType[typeId]
                end
              end
            end
          elseif arg == 'bildo' then
            for _, statement in pairs(item:getBestStatements('P18')) do
              if statement.mainsnak.datavalue.value ~= nil then
                argsCache.image = statement.mainsnak.datavalue.value
              end
            end
          elseif arg == 'titolo' then
            local value = item:formatStatements('P1476')['value']
            if value == '' then
              value = item:getLabel() or ''
            end
            if value ~= '' then
              local siteLink = item:getSitelink()
              if siteLink then
                value = '[[' .. siteLink .. '|' .. value .. ']]'
              end
              argsCache.titre = value .. '&nbsp;[[File:OOjs UI icon edit-ltr.svg|Vidi kaj redakti datumojn en Vikidatumoj|10px|baseline|class=noviewer|link=d:' .. item.id .. '#P1476]]'
            end
          elseif indexToWikidata[arg] then
            local propertyId = indexToWikidata[arg]
            local value = item:formatStatements(propertyId)["value"]
            if value ~= '' then
              argsCache[arg] = value .. '&nbsp;[[File:OOjs UI icon edit-ltr.svg|Vidi kaj redakti datumojn en Vikidatumoj|10px|baseline|class=noviewer|link=d:' .. item.id .. '#' .. propertyId .. ']]'
            end
          end
        end
      end
      if argsCache[arg] == '' then
        return nil
      else
        return argsCache[arg]
      end
    end
  })

  return {
    args = argsWithMeta,
    item = item,
  }
end

return p
