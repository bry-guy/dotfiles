from __future__ import annotations

from textual.theme import BUILTIN_THEMES
from textual.theme import Theme as TextualTheme

MOONFLY_THEME = {
    "primary": "#74b2ff",
    "secondary": "#79dac8",
    "warning": "#c6c684",
    "error": "#ff5189",
    "success": "#36c692",
    "accent": "#cf87e8",
    "foreground": "#bdbdbd",
    "background": "#080808",
    "surface": "#121212",
    "panel": "#1c1c1c",
    "dark": True,
    "variables": {
        "text": "#bdbdbd",
        "text-muted": "#949494",
        "foreground-muted": "#949494",
        "block-cursor-foreground": "#080808",
        "block-cursor-background": "#74b2ff",
        "input-selection-background": "#24344d",
        "button-color-foreground": "#080808",
        "footer-background": "#74b2ff",
        "footer-key-foreground": "#080808",
        "footer-description-foreground": "#080808",
        "link-color": "#74b2ff",
        "link-color-hover": "#79dac8",
    },
}


def register_adaptive_themes():
    theme = TextualTheme(name="moonfly", **MOONFLY_THEME)
    BUILTIN_THEMES.update({theme.name: theme})
    return {theme.name: theme}
