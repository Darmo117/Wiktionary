local m_langs = require("Module:langues")

local p = {}

local topCategoryName = "Personnes ayant un intérêt ou parlant %s"

local levelCategoriesNames = {
  ["Personnes ayant un intérêt ou parlant (.+)"] = {
    desc = "Ces personnes parlent %s à différents niveaux."
  },
  ["Personnes ne parlant pas (.+) mais s’y intéressant"] = {
    level = "0",
    desc = "Ces personnes ont déclaré ne pas parler %s.",
  },
  ['Personnes ayant un niveau débutant en (.+)'] = {
    level = "1",
    desc = "Ces personnes ont déclaré avoir un niveau débutant en %s.",
  },
  ["Personnes ayant un niveau intermédiaire en (.+)"] = {
    level = "2",
    desc = "Ces personnes ont déclaré avoir un niveau intermédiaire en %s.",
  },
  ["Personnes ayant un niveau avancé en (.+)"] = {
    level = "3",
    desc = "Ces personnes ont déclaré avoir un niveau avancé en %s.",
  },
  ["Personnes ayant un niveau très avancé en (.+)"] = {
    level = "4",
    desc = "Ces personnes ont déclaré avoir un niveau très avancé en %s.",
  },
  ["Personnes parlant nativement en (.+)"] = {
    level = "N",
    desc = "Ces personnes ont déclaré parler nativement en %s.",
  },
}

local function _description(title)
  for k, v in pairs(levelCategoriesNames) do
    local langName = mw.ustring.match(title, "^" .. k .. "$")
    if langName then
      local desc = mw.ustring.format(v.desc, langName)
      local level = v.level
      local code = m_langs._getLanguageCode(langName)
      local categoryName = mw.ustring.format(topCategoryName, langName)

      local res = desc
      if level then
        res = res .. mw.ustring.format("\n\nCode Babel&nbsp;: <code>%s-%s</code>\n[[Catégorie:%s|%s]]",
            code, level, categoryName, langName .. "-" .. level)
      else
        res = res .. mw.ustring.format("\n[[Catégorie:Wiktionnaristes par langue|%s]]", langName)
      end

      return res
    end
  end

  return '<span style="color: red; font-weight: bold">Le titre de la page ne correspond pas aux critères.</span>'
end

function p.description(frame)
  return _description(mw.title.getCurrentTitle().text)
end

return p
