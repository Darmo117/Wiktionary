groups = {
    'format': 'Format',
    'insert': 'Insérer',
    'size': 'Taille',
    'links': 'Liens',
    'section_templates': 'Patrons',
    'messages': 'Messages',
    'headers': 'Bandeaux',
    'html_tags': 'Balises',
}

buttons = [
    {
        'tagOpen': '’',
        'imageFileName': '5/57/Apostrophe.png',
        'imageFileNameOOUI': '8/88/Upper_single_apostrophe_toolbar_symbol.png',
        'tooltip': 'Apostrophe typographique',
        'buttonId': 'apos',
        'group': 'format',
    },
    {
        'tagOpen': '&nbsp;',
        'imageFileName': '5/55/Button_nbsp_1.png',
        'tooltip': 'Espace insécable',
        'buttonId': 'nbsp',
        'group': 'format',
    },
    {
        'tagOpen': '« ',
        'tagClose': ' »',
        'imageFileName': '2/26/Button_latinas.png',
        'imageFileNameOOUI': 'a/ac/Norwegian_quote_sign.png',
        'tooltip': 'Guillemets français',
        'buttonId': 'fr-quotes',
        'group': 'format',
    },
    {
        'tagOpen': '#REDIRECT{{',
        'tagClose': '}}',
        'imageFileName': '4/47/Button_redir.png',
        'tooltip': 'Redirection',
        'buttonId': 'redirect',
        'toolbarIgnore': True,
    },
    {
        'tagOpen': '{{w|',
        'tagClose': '}}',
        'imageFileName': 'c/cb/Button_wikipedia.png',
        'imageFileNameOOUI': 'thumb/1/14/OOjs_UI_icon_logo-wikipedia.svg',
        'tooltip': 'Lien vers Wikipédia',
        'buttonId': 'link-wp',
        'group': 'links',
    },
    {
        'tagOpen': '{{subst:' + 'Merci IP|',
        'tagClose': '}}~~' + '~~',
        'imageFileName': '1/12/Button_accueilA.png',
        'imageFileNameOOUI': 'thumb/b/bf/Twemoji12_1f603.svg',
        'tooltip': 'Merci IP',
        'buttonId': 'thanks-ip',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Bienvenue}}~~' + '~~',
        'imageFileName': 'e/eb/Button_accueilB.png',
        'imageFileNameOOUI': 'thumb/a/aa/Twemoji12_1f642.svg',
        'tooltip': 'Bienvenue',
        'buttonId': 'welcome',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Débutant}}~~' + '~~',
        'imageFileName': 'a/a7/Button_smiley3.png',
        'imageFileNameOOUI': 'thumb/d/db/OOjs_UI_icon_error.svg',
        'tooltip': 'Débutant',
        'buttonId': 'beginner',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Vandale}}~~' + '~~',
        'imageFileName': '3/3b/Button_crocs.png',
        'imageFileNameOOUI': 'thumb/c/ca/OOjs_UI_icon_error-progressive.svg',
        'tooltip': 'Vandale',
        'buttonId': 'vandal',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Vandale2}}~~' + '~~',
        'imageFileName': 'e/ec/Button_aviso.png',
        'imageFileNameOOUI': 'thumb/4/4e/OOjs_UI_icon_error-destructive.svg',
        'tooltip': 'Vandale 2',
        'buttonId': 'vandal2',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Bloqué|2 ',
        'tagClose': 'h|Vandalisme}}~~' + '~~',
        'imageFileName': '3/3f/Button_attendre.png',
        'imageFileNameOOUI': 'thumb/5/53/OOjs_UI_icon_cancel-destructive.svg',
        'tooltip': 'Bloqué',
        'buttonId': 'vandal3',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Spam}}~~' + '~~',
        'imageFileName': '6/6d/Button_exclamation_1.png',
        'imageFileNameOOUI': 'thumb/3/3b/OOjs_UI_icon_alert-warning.svg',
        'tooltip': 'Spam',
        'buttonId': 'spam',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Spam2}}~~' + '~~',
        'imageFileName': '3/33/Button_exclamation.png',
        'imageFileNameOOUI': 'thumb/f/f6/OOjs_UI_icon_alert-destructive.svg',
        'tooltip': 'Spam 2',
        'buttonId': 'spam2',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Copyvio}}~~' + '~~',
        'imageFileName': 'c/c9/Button_copy_vio.png',
        'imageFileNameOOUI': 'thumb/7/7e/Orange_copyright.svg',
        'tooltip': 'Copyvio',
        'buttonId': 'copyvio',
        'group': 'messages',
    },
    {
        'tagOpen': '{{subst:' + 'Copyvio2}}~~' + '~~',
        'imageFileName': '7/72/Button_copy_vio_plagio.png',
        'imageFileNameOOUI': 'thumb/1/1d/Red_copyright.svg',
        'tooltip': 'Copyvio 2',
        'buttonId': 'copyvio2',
        'group': 'messages',
    },
    {
        'tagOpen': '{{supp|',
        'tagClose': '}}',
        'imageFileName': 'f/f3/Button_broom2.png',
        'imageFileNameOOUI': 'thumb/d/de/OOjs_UI_icon_trash-destructive.svg',
        'tooltip': 'Suppression rapide',
        'buttonId': 'delete',
        'group': 'headers',
    },
    {
        'tagOpen': '{{subst:' + 'suppression à débattre|',
        'tagClose': '}}~~' + '~~',
        'imageFileName': '9/9f/Button_broom3.png',
        'imageFileNameOOUI': 'thumb/3/3f/OOjs_UI_icon_trash.svg',
        'tooltip': 'Proposition de suppression',
        'buttonId': 'delete-proposition',
        'group': 'headers',
    },
    {
        'tagOpen': '== {{langue|fr}} ==\n=== {{S|étymologie}} ===\n{{ébauche-étym|fr}}\n:',
        'tagClose': " {{date|?}}/{{siècle|?}}\n=== {{S|nom|fr}} ===\n{{fr-rég|}}\n'''{{subst:" + "PAGENAME}}''' {{pron||fr}} {{genre ?}}\n#\n#* ''''\n==== {{S|variantes orthographiques}} ====\n==== {{S|synonymes}} ====\n==== {{S|antonymes}} ====\n==== {{S|dérivés}} ====\n==== {{S|apparentés}} ====\n==== {{S|vocabulaire}} ====\n==== {{S|hyperonymes}} ====\n==== {{S|hyponymes}} ====\n==== {{S|méronymes}} ====\n==== {{S|holonymes}} ====\n==== {{S|traductions}} ====\n{{trad-début}}\n{{ébauche-trad}}\n{{trad-fin}}\n=== {{S|prononciation}} ===\n* {{pron||fr}}\n* {{écouter|<!--  précisez svp la ville ou la région -->||audio=|lang=}}\n==== {{S|homophones|fr}} ====\n==== {{S|paronymes}} ====\n=== {{S|anagrammes}} ===\n=== {{S|voir aussi}} ===\n* {{WP}}\n=== {{S|références}} ===\n{{clé de tri}}",
        'imageFileName': '3/32/Button_anular_voto.png',
        'imageFileNameOOUI': 'thumb/8/81/OOjs_UI_icon_stripeFlow-ltr.svg',
        'tooltip': 'Patron long',
        'buttonId': 'long-template',
        'group': 'section_templates',
    },
    {
        'tagOpen': '== {{langue|fr}} ==\n=== {{S|étymologie}} ===\n{{ébauche-étym' + '\|fr}}\n\n=== {{S|nom|fr}} ===\n{{fr-rég\|}}\n\'\'\'{{subst:' + 'PAGENAME}}\'\'\' {{m}}\n# ',
        'tagClose': '\n\n==== {{S|traductions}} ====\n{{trad-début}}\n{{ébauche-trad}}\n* {{T|en}} : {{trad|en|}}\n{{trad-fin}}\n\n=== {{S|voir aussi}} ===\n* {{WP}}',
        'imageFileName': 'a/a7/Francefilm.png',
        'imageFileNameOOUI': 'thumb/7/71/OOjs_UI_icon_stripeSummary-ltr.svg',
        'tooltip': 'Patron court',
        'buttonId': 'short-template',
        'group': 'section_templates',
    },
    {
        'tagOpen': '=== {{S|références}} ===\n{{Références}}',
        'imageFileName': '6/64/Buttonrefvs8.png',
        'imageFileNameOOUI': 'thumb/9/9c/OOjs_UI_icon_reference.svg',
        'tooltip': 'Références',
        'buttonId': 'references',
        'group': 'section_templates',
    },
    {
        'tagOpen': '{{source| {{ouvrage| url= | titre= | prénom1= | nom1= | éditeur= | année= }} }}',
        'imageFileName': 'e/ef/Button_cite_book.png',
        'imageFileNameOOUI': 'thumb/5/5b/OOjs_UI_icon_quotesAdd-ltr.svg',
        'tooltip': 'Source d’exemple',
        'buttonId': 'source',
        'group': 'insert',
    },
    {
        'tagOpen': '{{Autres projets\n|w=',
        'tagClose': '\n|b=\n|v=\n|n=\n|s=\n|q=\n|commons=\n|wikispecies=\n|m=\n}}',
        'imageFileName': '4/4c/Button_interprojet.png',
        'imageFileNameOOUI': 'thumb/4/40/Network_sans.svg',
        'tooltip': 'Autres projets',
        'buttonId': 'other-projects',
        'group': 'links',
    },
]

for b in buttons:
    fname = b['imageFileName']
    iname = f'[[File:{fname[fname.rindex("/") + 1:]}|23px]]'
    fname2 = b['imageFileNameOOUI'] if 'imageFileNameOOUI' in b else ''
    iname2 = f'[[File:{fname2[fname2.rindex("/") + 1:]}|24px]]' if fname2 else (
        '-' if 'toolbarIgnore' in b and b['toolbarIgnore'] else iname
    )
    print(
        f'|-\n| {iname} || {iname2} ||  || {groups[b["group"]] if "group" in b else "-"} || {"oui" if "toolbarIgnore" in b and b["toolbarIgnore"] else "non"}')
