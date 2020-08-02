import pywikibot as pwb
import mwparserfromhell as mwp
import re


def contains_lemma_sections(section):
    """
    Vérifie s'il existe une section de lemme.
    :param section: la section en espéranto
    :return: True s'il existe une section de lemme
    """
    level_3_sections = section.get_sections(levels=[3])
    get_heading_template = lambda s: s.filter_headings()[0].title.filter_templates()[0]
    is_lemma_section = lambda s: s.has_param(2) and s.get(2) == "eo" and not s.has_param(3)
    return len(list(filter(is_lemma_section, map(get_heading_template, level_3_sections)))) != 0


def format_etymology(section):
    need_etymology = contains_lemma_sections(section)
    has_etymology = "{{S|étymologie}}" in section
    diff_comments = []

    if need_etymology and has_etymology:
        etym_sections = section.get_sections(matches=r"{{S\|étymologie}}")
        if len(etym_sections) != 1:
            raise Exception(f"Wrong number of etymology sections! ({len(etym_sections)})")
        etym_section = etym_sections[0]
        if "{{date|" not in etym_section and "{{siècle|" not in etym_section:
            if ": " in etym_section:
                etym_section.insert_after(": ", " {{date|lang=eo}} ")
            else:
                etym_section.insert_after(":", " {{date|lang=eo}} ")
        if "{{étyl|" in etym_section and ("{{R|" not in etym_section and
                                          "réfnéc" not in etym_section and
                                          "refnec" not in etym_section and
                                          "source?" not in etym_section and
                                          "réf ?" not in etym_section and
                                          "référence nécessaire" not in etym_section):
            etym_section.replace(etym_section.filter_templates()[-1],
                                 "{{réfnéc|lang=eo|" + str(etym_section.filter_templates()[-1]) + "}}")
    elif need_etymology and not has_etymology:
        section.insert_after("== {{langue|eo}} ==\n",
                             "=== {{S|étymologie}} ===\n: {{date|lang=eo}} {{ébauche-étym|eo}}\n\n")
    elif not need_etymology and has_etymology:
        for etym_section in section.get_sections(matches=r"{{S\|étymologie}}"):
            section.remove(etym_section)

    return diff_comments


def format_verb_lemma(section):
    diff_comments = []

    if "{{eo-verbe}}" not in section:
        section.insert_after("===\n", "{{eo-verbe}}\n")

    for template in section.filter_templates():
        if template.name in ["eo-conj", "eo-conj-intrans", "eo-comprac", "eo-ss", "eo-ss", "eo-motrac",
                             "eo-co nj-intacc"]:
            section.remove(template)

        if template.name == "pron":
            pron = str(template.get(1))

            syllabs = pron.split(".")

            if len(syllabs) > 1:
                for i, syllab in enumerate(syllabs):
                    if (i == len(syllabs) - 2) != (syllab[0] == "ˈ"):
                        section.replace(template, str(template) + " {{?|syllabation|eo}}")
                        break

            pron2 = pron.translate(pron.maketrans({"ɛ": "e", "ɾ": "r", "ɔ": "o"}))

            if pron2 != pron:
                template.add(1, pron2)

    star_line = [l for l in str(section).split("\n") if l.startswith("'''")][0]

    match = re.fullmatch(r"'''(.*)''' ?(?:{{pron\|([^|]*)\|eo}})? ?(.*?) ?({{conjugaison\|eo}})?", star_line)
    word = match[1]
    pron = match[2]
    valence = match[3] or "{{valence ?|eo}}"
    section.replace(star_line, f"'''{word}''' {{{{pron|{pron}|eo}}}} " + valence + " {{conjugaison|eo}}")

    lines = str(section).split("\n")
    for i in range(len(lines)):
        if re.search("^# ?", lines[i]) and (not re.search("^#\* ?", lines[i + 1]) or "{{source|" not in section):
            section.replace(lines[i], lines[i] + "\n#* {{ébauche-exe|eo}}")
        elif re.search("^#\* ?''", lines[i]) and not re.search("^#\*: ?", lines[i + 1]):
            section.replace(lines[i], lines[i] + "\n#*: {{trad-exe|eo}}")

    return diff_comments


def format_level_3_section(eo_section, section):
    diff_comments = []
    template = section.filter_headings()[0].title.filter_templates()[0]
    if str(template) == "{{S|étymologie}}":
        diff_comments.extend(format_etymology(eo_section))
    elif template.has_param(1) and template.get(1) == "verbe" and not template.has_param(3):
        diff_comments.extend(format_verb_lemma(section))
    else:
        print("Unknown section:", template)
    return diff_comments


def format_article(article):
    diff_comments = []
    parsed = mwp.parse(article.text)
    level_2_sections = parsed.get_sections(levels=[2])
    eo_section = [s for s in level_2_sections if "{{langue|eo}}" in s.filter_headings()[0]][0]

    for level_3_section in eo_section.get_sections(levels=[3]):
        diff_comments.extend(format_level_3_section(eo_section, level_3_section))

    if str(parsed) != article.text:
        article.text = str(parsed)
        # print(article.text)
        # print("Formatage de l'entrée en espéranto : " + " ; ".join(diff_comments))
        article.save("Formatage de l'entrée en espéranto.", botflag=True)
        return True
    return False


site = pwb.Site(user="LeptiBot")

eo_category = pwb.Category(site, "Verbes en espéranto")

for article in eo_category.articles():
    if format_article(article):
        break
