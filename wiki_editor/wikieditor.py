import re
import typing as typ
import webbrowser

import PyQt5.QtCore as QtC
import PyQt5.QtGui as QtG
import PyQt5.QtWidgets as QtW


class WikiEditor(QtW.QTextEdit):
    def __init__(self, special_variables: typ.Sequence[str]):
        super().__init__()
        self.__highlighting = False
        self.__special_variables = tuple(special_variables)
        self.setLineWrapMode(QtW.QTextEdit.NoWrap)
        self.setMouseTracking(True)
        # noinspection PyUnresolvedReferences
        self.textChanged.connect(self.__syntax_highlight)

    def mouseReleaseEvent(self, e: QtG.QMouseEvent):
        super().mouseReleaseEvent(e)
        link = self.anchorAt(e.pos())
        if link != '' and e.modifiers() == QtC.Qt.ControlModifier:
            webbrowser.open_new_tab(link)

    def mouseMoveEvent(self, e: QtG.QMouseEvent):
        super().mouseMoveEvent(e)
        link = self.anchorAt(e.pos())
        pointer_cursor = link != '' and e.modifiers() == QtC.Qt.ControlModifier
        self.viewport().setCursor(QtG.QCursor(QtC.Qt.PointingHandCursor if pointer_cursor else QtC.Qt.IBeamCursor))

    def __syntax_highlight(self):
        if not self.__highlighting:
            self.__highlighting = True
            page_code = self.toPlainText()
            page_code = page_code.replace('<', '&lt;').replace('>', '&gt;')
            for variable in self.__special_variables:
                page_code = page_code.replace(variable, f'<span class="variable">{variable}</span>')
            page_code = re.sub(r'{{(\s*)(.+?)(\s*)(\|.*?)?}}',
                               r'<a href="https://fr.wiktionary.org/wiki/Modèle:\2" '
                               r'class="model">{{\1<span class="model-name">\2</span>\3\4}}</a>',
                               page_code, flags=re.M)
            page_code = re.sub(r'(?<!\[)\[(\s*)(https?://[^[\s]+?)(\s.*?)?]',
                               r'<a href="\2" class="link">[\1<span class="target">\2</span>\3]</a>',
                               page_code, flags=re.M)
            page_code = re.sub(r'\[\[(\s*)(.+?)(\s*)(\|.*?)?]]',
                               r'<a href="https://fr.wiktionary.org/wiki/\2" class="link">'
                               r'[[\1<span class="target">\2</span>\3\4]]</a>',
                               page_code, flags=re.M)
            page_code = re.sub(r'&lt;(/?\w+?|\w+?\s*/?)&gt;',
                               r'<span class="html-tag">&lt;\1&gt;</span>',
                               page_code)
            page_code = re.sub(r'(=={1,6}|^\s*:+\*?|^\s*;|^\s*#+\*?|^\s*\*+)', r'<span class="operator">\1</span>',
                               page_code, flags=re.M)
            html = f"""<html>
            <head>
                <style>
                    * {{font-family: Consolas; font-size: 12px; background-color: #272822;}}
                    body {{color: #a9b7c6;}}
                    a {{text-decoration: none;}}
                    .variable {{color: #eb4b64; font-weight: bold;}}
                    .model {{color: #a7ec21;}} .model-name {{text-decoration: underline;}}
                    .link {{color: #1290c3;}} .target {{text-decoration: underline;}}
                    .operator {{color: #ff80ff; font-weight: bold;}}
                    .html-tag {{color: #e67b0a; font-weight: bold;}}
                </style>
            </head><body><pre>{page_code}</pre></body></html>"""
            cursor = self.textCursor()
            pos = cursor.position()
            self.setHtml(html)
            cursor.setPosition(pos)
            self.setTextCursor(cursor)
            self.__highlighting = False
