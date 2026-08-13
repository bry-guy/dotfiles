# Generated from palette/sunfly.json
from __future__ import annotations

from textual.theme import BUILTIN_THEMES
from textual.theme import Theme as TextualTheme

SUNFLY_THEME_DEFS = {'sunfly': {'primary': '#004ca0',
            'secondary': '#005868',
            'warning': '#6e5000',
            'error': '#b01018',
            'success': '#006840',
            'accent': '#8a356f',
            'foreground': '#372d25',
            'background': '#f0e8da',
            'surface': '#f0e8da',
            'panel': '#8b7d6f',
            'dark': False,
            'variables': {'text': '#372d25',
                          'text-muted': '#65594e',
                          'foreground-muted': '#65594e',
                          'block-cursor-foreground': '#f8f2ea',
                          'block-cursor-background': '#004ca0',
                          'input-selection-background': '#b8d6cb',
                          'button-color-foreground': '#f8f2ea',
                          'footer-background': '#004ca0',
                          'footer-key-foreground': '#f8f2ea',
                          'footer-description-foreground': '#f8f2ea',
                          'link-color': '#004ca0',
                          'link-color-hover': '#005868'}}}


def register_sunfly_themes():
    themes = {
        name: TextualTheme(name=name, **theme_def)
        for name, theme_def in SUNFLY_THEME_DEFS.items()
    }
    BUILTIN_THEMES.update(themes)
    return themes
