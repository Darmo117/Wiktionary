local m_table = require("Module:table")

local data = {
  ["défaillir"] = {
    ending = "aillir",
    endings = {}, -- TODO
  },
  ["asseoir"] = {
    ending = "asseoir",
    endings = {
      infinitif = {
        present = "asseoir",
      },
      participe = {
        present = "asseyant",
        passe = "assis",
      },
      indicatif = {
        present = { "assieds", "assieds", "assied", "asseyons", "asseyez", "asseyent" },
        imparfait = { "asseyais", "asseyais", "asseyait", "asseyions", "asseyiez", "asseyaient" },
        passeSimple = { "assis", "assis", "assit", "assîmes", "assîtes", "assirent" },
        futur = { "assiérai", "assiéras", "assiéra", "assiérons", "assiérez", "assiéront" },
      },
      subjonctif = {
        present = { "asseye", "asseyes", "asseye", "asseyions", "asseyiez", "asseyent" },
        imparfait = { "assisse", "assisses", "assît", "assissions", "assissiez", "assissent" },
      },
      conditionnel = {
        present = { "assiérais", "assiérais", "assiérait", "assiérions", "assiérions", "assiéraient" },
      },
      imperatif = {
        present = { "assieds", "asseyons", "asseyez" },
      },
    },
  },
  ["asseoir-ois"] = {
    endings = {
      infinitif = {
        present = "asseoir",
      },
      participe = {
        present = "assoyant",
        passe = "assis",
      },
      indicatif = {
        present = { "assois", "assois", "assoit", "assoyons", "assoyez", "assoient" },
        imparfait = { "assoyais", "assoyais", "assoyait", "assoyions", "assoyiez", "assoyaient" },
        passeSimple = { "assis", "assis", "assit", "assîmes", "assîtes", "assirent" },
        futur = { "assoirai", "assoiras", "assoira", "assoirons", "assoirez", "assoiront" },
      },
      subjonctif = {
        present = { "assoie", "assoies", "assoie", "assoyions", "assoyiez", "assoient" },
        imparfait = { "assisse", "assisses", "assît", "assissions", "assissiez", "assissent" },
      },
      conditionnel = {
        present = { "assoirais", "assoirais", "assoirait", "assoirions", "assoirions", "assoiraient" },
      },
      imperatif = {
        present = { "assois", "assoyons", "assoyez" },
      },
    },
  },
  ["paraître"] = {
    ending = "aître",
    endings = {}, -- TODO
  },
  ["battre"] = {
    ending = "battre",
    endings = {
      infinitif = {
        present = "battre",
      },
      participe = {
        present = "battant",
        passe = "battu",
      },
      indicatif = {
        present = { "bats", "bats", "bat", "battons", "battez", "battent" },
        imparfait = { "battais", "battais", "battait", "battions", "battiez", "battaient" },
        passeSimple = { "battis", "battis", "battit", "battîmes", "battîtes", "battirent" },
        futur = { "battrai", "battras", "battra", "battrons", "battrez", "battront" },
      },
      subjonctif = {
        present = { "batte", "battes", "batte", "battions", "battiez", "battent" },
        imparfait = { "battisse", "battisses", "battît", "battissions", "battissiez", "battissent" },
      },
      conditionnel = {
        present = { "battrais", "battrais", "battrait", "battrions", "battriez", "battraient" },
      },
      imperatif = {
        present = { "bats", "battons", "battez" },
      },
    },
  },
  ["boire"] = {
    ending = "boire",
    endings = {
      infinitif = {
        present = "boire",
      },
      participe = {
        present = "buvant",
        passe = "bu",
      },
      indicatif = {
        present = { "bois", "bois", "boit", "buvons", "buvez", "boivent" },
        imparfait = { "buvais", "buvais", "buvait", "buvions", "buviez", "buvaient" },
        passeSimple = { "bus", "bus", "but", "bûmes", "bûtes", "burent" },
        futur = { "boirai", "boiras", "boira", "boirons", "boirez", "boiront" },
      },
      subjonctif = {
        present = { "boive", "boives", "boive", "buvions", "buviez", "boivent" },
        imparfait = { "busse", "busses", "bût", "bussions", "bussiez", "bussent" },
      },
      conditionnel = {
        present = { "boirais", "boirais", "boirait", "boirions", "boiriez", "boiraient" },
      },
      imperatif = {
        present = { "bois", "buvons", "buvez" },
      }
    },
  },
  ["bouillir"] = {
    ending = "bouillir",
    endings = {
      infinitif = {
        present = "bouillir",
      },
      participe = {
        present = "bouillant",
        passe = "bouilli",
      },
      indicatif = {
        present = { "bous", "bous", "bout", "bouillons", "bouillez", "bouillent" },
        imparfait = { "bouillais", "bouillais", "bouillait", "bouillions", "bouilliez", "bouillaient" },
        passeSimple = { "bouillis", "bouillis", "bouillit", "bouillîmes", "bouillîtes", "bouillirent" },
        futur = { "bouillirai", "bouilliras", "bouillira", "bouillirons", "bouillirez", "bouilliront" },
      },
      subjonctif = {
        present = { "bouille", "bouilles", "bouille", "bouillions", "bouilliez", "bouillent" },
        imparfait = { "bouillisse", "bouillisses", "bouillît", "bouillissions", "bouillissiez", "bouillissent" },
      },
      conditionnel = {
        present = { "bouillirais", "bouillirais", "bouillirait", "bouillirions", "bouilliriez", "bouilliraient" },
      },
      imperatif = {
        present = { "bous", "bouillons", "bouillez" },
      },
    },
  },
  ["recevoir"] = {
    ending = "cevoir",
    endings = {}, -- TODO
  },
  ["clore"] = {
    ending = "clore",
    endings = {
      infinitif = {
        present = "clore",
      },
      participe = {
        present = "closant",
        passe = "clos",
      },
      indicatif = {
        present = { "clos", "clos", "clôt", "closons", "closez", "closent" },
        imparfait = { "closais", "closais", "closait", "closions", "closiez", "closaient" },
        passeSimple = { "closis", "closis", "closit", "closîmes", "closîtes", "closirent" },
        futur = { "clorai", "cloras", "clora", "clorons", "clorez", "cloront" },
      },
      subjonctif = {
        present = { "close", "closes", "close", "closions", "closiez", "closent" },
        imparfait = { "closisse", "closisses", "closît", "closissions", "closissiez", "closissent" },
      },
      conditionnel = {
        present = { "clorais", "clorais", "clorait", "clorions", "cloriez", "cloraient" },
      },
      imperatif = {
        present = { "clos", "closons", "closez" },
      },
    },
  },
  ["éclore"] = {
    ending = "clore",
    endings = {}, -- TODO
  },
  ["inclure"] = {
    ending = "clure",
    endings = {}, -- TODO
  },
  ["coudre"] = {
    ending = "coudre",
    endings = {
      infinitif = {
        present = "coudre",
      },
      participe = {
        present = "cousant",
        passe = "cousu",
      },
      indicatif = {
        present = { "couds", "couds", "coud", "cousons", "cousez", "cousent" },
        imparfait = { "cousais", "cousais", "cousait", "cousions", "cousiez", "cousaient" },
        passeSimple = { "cousis", "cousis", "cousit", "cousîmes", "cousîtes", "cousirent" },
        futur = { "coudrai", "coudras", "coudra", "coudrons", "coudrez", "coudront" },
      },
      subjonctif = {
        present = { "couse", "couses", "couse", "cousions", "cousiez", "cousent" },
        imparfait = { "cousisses", "cousisses", "cousît", "cousissions", "cousissiez", "cousissent" },
      },
      conditionnel = {
        present = { "coudrais", "coudrais", "coudrait", "coudrions", "coudriez", "coudraient" },
      },
      imperatif = { "couds", "cousons", "cousez" },
    },
  },
  ["courir"] = {
    ending = "courir",
    endings = {
      infinitif = {
        present = "courir",
      },
      participe = {
        present = "courant",
        passe = "couru",
      },
      indicatif = {
        present = { "cours", "cours", "court", "courons", "courez", "courent" },
        imparfait = { "courais", "courais", "courait", "courions", "couriez", "couraient" },
        passeSimple = { "courus", "courus", "courut", "courûmes", "courûtes", "coururent" },
        futur = { "courrai", "courras", "courra", "courrons", "courrez", "courront" },
      },
      subjonctif = {
        present = { "coure", "coures", "coure", "courions", "couriez", "courent" },
        imparfait = { "courusse", "courusses", "courût", "courussions", "courussiez", "courussent" },
      },
      conditionnel = {
        present = { "courrais", "courrais", "courrait", "courrions", "courriez", "courraient" },
      },
      imperatif = {
        present = { "cours", "courons", "courez" },
      },
    },
  },
  ["écrire"] = {
    ending = "crire",
    endings = {}, -- TODO
  },
  ["croire"] = {
    ending = "croire",
    endings = {
      infinitif = {
        present = "croire",
      },
      participe = {
        present = "croyant",
        passe = "cru",
      },
      indicatif = {
        present = { "crois", "crois", "croit", "croyons", "croyez", "croient" },
        imparfait = { "croyais", "croyais", "croyait", "croyions", "croyiez", "croyaient" },
        passeSimple = { "crus", "crus", "crut", "crûmes", "crûtes", "crurent" },
        futur = { "croirai", "croiras", "croira", "croirons", "croirez", "croiront" },
      },
      subjonctif = {
        present = { "croie", "croies", "croie", "croyions", "croyiez", "croient" },
        imparfait = { "crusse", "crusses", "crût", "crussions", "crussiez", "crussent" },
      },
      conditionnel = {
        present = { "croirais", "croirais", "croirait", "croirions", "croiriez", "croiraient" },
      },
      imperatif = {
        present = { "crois", "croyons", "croyez" },
      }
    },
  },
  ["croître"] = {
    ending = "croître",
    endings = {
      infinitif = {
        present = "croître",
      },
      participe = {
        present = "croissant",
        passe = "crû",
      },
      indicatif = {
        present = { "croîs", "croîs", "croît", "croissons", "croissez", "croissent" },
        imparfait = { "croissais", "croissais", "croissait", "croissions", "croissiez", "croissaient" },
        passeSimple = { "crûs", "crûs", "crût", "crûmes", "crûtes", "crûrent" },
        futur = { "croîtrai", "croîtrais", "croîtra", "croîtrons", "croîtrez", "croîtront" },
      },
      subjonctif = {
        present = { "croisse", "croisses", "croisse", "croissions", "croissiez", "croissent" },
        imparfait = { "crûsse", "crûsses", "crût", "crûssions", "crûssiez", "crûssent" },
      },
      conditionnel = {
        present = { "croîtrais", "croîtrais", "croîtrait", "croîtrions", "croîtriez", "croîtraient" },
      },
      imperatif = {
        present = { "croîs", "croissons", "croissez" },
      },
    },
  },
  ["cueillir"] = {
    ending = "cueillir",
    endings = {
      infinitif = {
        present = "cueillir",
      },
      participe = {
        present = "cueillant",
        passe = "cueilli",
      },
      indicatif = {
        present = { "cueille", "cueilles", "cueille", "cueillons", "cueillez", "cueillent" },
        imparfait = { "cueillais", "cueillais", "cueillait", "cueillions", "cueilliez", "cueillaient" },
        passeSimple = { "cueillis", "cueillis", "cueillit", "cueillîmes", "cueillîtes", "cueillirent" },
        futur = { "cueillerai", "cueilleras", "cueillera", "cueillerons", "cueillerez", "cueilleront" },
      },
      subjonctif = {
        present = { "cueille", "cueilles", "cueille", "cueillions", "cueilliez", "cueillent" },
        imparfait = { "cueillisse", "cueillisses", "cueillît", "cueillissions", "cueillissiez", "cueillissent" },
      },
      conditionnel = {
        present = { "cueillerais", "cueillerais", "cueillerait", "cueillerions", "cueilleriez", "cueilleraient" },
      },
      imperatif = {
        present = { "cueille", "cueillons", "cueillez" },
      },
    },
  },
  ["devoir"] = {
    ending = "devoir",
    endings = {}, -- TODO
  },
  ["dire"] = {
    ending = "dire",
    endings = {}, -- TODO
  },
  ["prédire"] = {
    ending = "dire",
    endings = {}, -- TODO
  },
  ["dormir"] = {
    ending = "dormir",
    endings = {}, -- TODO
  },
  ["tenir"] = {
    ending = "enir",
    endings = {}, -- TODO
  },
  ["faire"] = {
    ending = "faire",
    endings = {}, -- TODO
  },
  ["fuir"] = {
    ending = "fuir",
    endings = {}, -- TODO
  },
  ["peindre"] = {
    ending = "indre",
    endings = {}, -- TODO
  },
  ["confire"] = {
    ending = "ire",
    endings = {
      infinitif = {
        present = "ire",
      },
      participe = {
        present = "isant",
        passe = "it",
      },
      indicatif = {
        present = { "is", "is", "it", "isons", "isez", "isent" },
        imparfait = { "isais", "isais", "isait", "isions", "isiez", "isaient" },
        passeSimple = { "is", "is", "it", "îmes", "îtes", "irent" },
        futur = { "irai", "iras", "ira", "irons", "irez", "iront" },
      },
      subjonctif = {
        present = { "ise", "ises", "ise", "ision", "isiez", "isent" },
        imparfait = { "isse", "isses", "ît", "issions", "issiez", "issent" },
      },
      conditionnel = {
        present = { "irais", "irais", "irait", "irions", "iriez", "iraient" },
      },
      imperatif = {
        present = { "is", "isons", "isez" },
      },
    },
  },
  ["lire"] = {
    ending = "lire",
    endings = {}, -- TODO
  },
  ["mettre"] = {
    ending = "mettre",
    endings = {}, -- TODO
  },
  ["moudre"] = {
    ending = "moudre",
    endings = {}, -- TODO
  },
  ["mouvoir"] = {
    ending = "mouvoir",
    endings = {}, -- TODO
  },
  ["ouvrir"] = {
    ending = "ouvrir",
    endings = {}, -- TODO
  },
  ["plaire"] = {
    ending = "plaire",
    endings = {}, -- TODO
  },
  ["acquérir"] = {
    ending = "quérir",
    endings = {
      infinitif = {
        present = "quérir",
      },
      participe = {
        present = "quérant",
        passe = "quis",
      },
      indicatif = {
        present = { "quiers", "quiers", "quiert", "quérons", "quérez", "quièrent" },
        imparfait = { "quérais", "quérais", "quérait", "quérions", "quériez", "quéraient" },
        passeSimple = { "quis", "quis", "quit", "quîmes", "quîtes", "quirent" },
        futur = { "querrai", "querras", "querra", "querrons", "querrez", "querront" },
      },
      subjonctif = {
        present = { "quière", "quières", "quière", "quérions", "quériez", "quièrent" },
        imparfait = { "quisse", "quisses", "quît", "quissions", "quissiez", "quissent" },
      },
      conditionnel = {
        present = { "querrais", "querrais", "querrait", "querrions", "querriez", "querraient" },
      },
      imperatif = {
        present = { "quiers", "quérons", "quérez" },
      },
    },
  },
  ["vendre"] = {
    ending = "re",
    endings = {}, -- TODO
  },
  ["prendre"] = {
    ending = "rendre",
    endings = {}, -- TODO
  },
  ["rire"] = {
    ending = "rire",
    endings = {}, -- TODO
  },
  ["seoir"] = {
    ending = "seoir",
    endings = {}, -- TODO
  },
  ["servir"] = {
    ending = "servir",
    endings = {}, -- TODO
  },
  ["absoudre"] = {
    ending = "soudre",
    endings = {
      infinitif = {
        present = "soudre",
      },
      participe = {
        present = "solvant",
        passe = "sous",
      },
      indicatif = {
        present = { "sous", "sous", "sout", "solvons", "solvez", "solvent" },
        imparfait = { "solvais", "solvais", "solvait", "solvions", "solviez", "solvaient" },
        --passeSimple = {},
        futur = { "soudrai", "soudras", "soudra", "soudrons", "soudrez", "soudront" },
      },
      subjonctif = {
        present = { "solve", "solves", "solve", "solvions", "solviez", "solvent" },
        --imparfait = {},
      },
      conditionnel = {
        present = { "soudrais", "soudrais", "soudrait", "soudrions", "soudriez", "soudraient" },
      },
      imperatif = {
        present = { "sous", "solvons", "solvez" },
      },
    },
  },
  ["suivre"] = {
    ending = "suivre",
    endings = {}, -- TODO
  },
  ["sortir"] = {
    ending = "tir",
    endings = {}, -- TODO
  },
  ["traire"] = {
    ending = "traire",
    endings = {}, -- TODO
  },
  ["cuire"] = {
    ending = "uire",
    endings = {
      infinitif = {
        present = "uire",
      },
      participe = {
        present = "uisant",
        passe = "uit",
      },
      indicatif = {
        present = { "uis", "uis", "uit", "uisons", "uisez", "uisent" },
        imparfait = { "uisais", "uisais", "uisait", "uisions", "uisiez", "uisaient" },
        passeSimple = { "uisis", "uisis", "uisit", "uisîmes", "uisîtes", "uisirent" },
        futur = { "uirai", "uiras", "uira", "uirons", "uirez", "uiront" },
      },
      subjonctif = {
        present = { "uise", "uises", "uise", "uisions", "uisiez", "uisent" },
        imparfait = { "uisisse", "uisisses", "uisît", "uisissions", "uisissiez", "uisissent" },
      },
      conditionnel = {
        present = { "uirais", "uirais", "uirait", "uirions", "uiriez", "uiraient" },
      },
      imperatif = {
        present = { "uis", "uisons", "uisez" },
      },
    },
  },
  ["vaincre"] = {
    ending = "vaincre",
    endings = {}, -- TODO
  },
  ["valoir"] = {
    ending = "valoir",
    endings = {}, -- TODO
  },
  ["vivre"] = {
    ending = "vivre",
    endings = {}, -- TODO
  },
  ["voir"] = {
    ending = "voir",
    endings = {}, -- TODO
  },
  ["vêtir"] = {
    ending = "vêtir",
    endings = {}, -- TODO
  },
}

data["absoudre-1990"] = m_table.deepcopy(data["absoudre"])
data["absoudre-1990"].endings.participe.passe = "sout"

data["assoir"] = m_table.deepcopy(data["asseoir"])
data["assoir"].ending = "assoir"
data["assoir"].endings.infinitif.present = "assoir"

data["assoir-ois"] = m_table.deepcopy(data["asseoir-ois"])
data["assoir-ois"].ending = "assoir"
data["assoir-ois"].endings.infinitif.present = "assoir"

data["croitre"] = m_table.deepcopy(data["croître"])
data["croitre"].ending = "croitre"
data["croitre"].endings.infinitif.present = "croitre"
data["croitre"].endings.indicatif.futur = { "croitrai", "croitras", "croitra", "croitrons", "croitrez", "croitront" }
data["croitre"].endings.conditionnel.present = { "croitrais", "croitrais", "croitrait", "croitrions", "croitriez", "croitraient" }

data["cuire-îmes"] = m_table.deepcopy(data["cuire"])
data["cuire-îmes"].endings.indicatif.passeSimple = { "cuis", "cuis", "cuit", "cuîmes", "cuîtes", "cuirent" }
data["cuire-îmes"].endings.subjonctif.imparfait = { "cuisse", "cuisses", "cuît", "cuissions", "cuissiez", "cuissent" }

return data

--[[
absoudre
acquérir
aller
asseoir
avoir
battre
bienvenir
boire
bouillir
braire
bruire
chaloir
choir
clore
confire
coudre
courir
croire
croître
cueillir
cuire
défaillir
dépourvoir
devoir
dire
dormir
échoir
éclore
écrire
s’ensuivre
être
faillir
faire
falloir
férir
frire
fuir
gésir
inclure
s’intrure
issir
lire
malfaire
maudire
mettre
moudre
mourir
mouvoir
naître
occire
ouïr
ouvrir
paître
paraître
peindre
plaire
pleuvoir
pourvoir
pouvoir
prédire
prendre
prévaloir
prévoir
quérir
ravoir
recevoir
reclure
repaître
résoudre
rire
saillir
savoir
seoir
servir
sortir
sourdre
suivre
surseoir
taire
tenir
traire
vaincre
valoir
vendre
vêtir
vivre
voir
vouloir
]]--
--[[
-aillir   (défaillir)
-asseoir  (asseoir)
-aître    (paraître)
-battre   (battre)
-boire    (boire)
-bouillir (bouillir)
-cevoir   (recevoir)
-clore    (clore)
-clore    (éclore)
-clure    (inclure)
-coudre   (coudre)
-courir   (courir)
-crire    (écrire)
-croire   (croire)
-croître  (croître)
-cueillir (cueillir)
-devoir   (devoir)
-dire     (dire)
-dire     (prédire)
-dormir   (dormir)
-enir     (tenir)
-faire    (faire)
-fuir     (fuir)
-indre    (peindre)
-ire      (confire)
-lire     (lire)
-mettre   (mettre)
-moudre   (moudre)
-mouvoir  (mouvoir)
-ouvrir   (ouvrir)
-plaire   (plaire)
-quérir   (acquérir)
-re       (vendre)
-rendre   (prendre)
-rire     (rire)
-seoir    (seoir)
-servir   (servir)
-soudre   (absoudre)
-suivre   (suivre)
-tir      (sortir)
-traire   (traire)
-uire     (cuire)
-vaincre  (vaincre)
-valoir   (valoir)
-vivre    (vivre)
-voir     (voir)
-vêtir    (vêtir)
--]]
