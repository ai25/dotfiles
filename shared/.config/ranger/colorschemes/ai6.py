from ranger.colorschemes.default import Default
from ranger.gui.color import BRIGHT, black, bold, cyan, default, dim, red, reverse, white


class Scheme(Default):
    def use(self, context):
        fg, bg, attr = Default.use(self, context)
        original_fg = fg

        if context.in_browser and (context.cut or context.copied):
            attr |= bold
            fg = black + BRIGHT

            if BRIGHT == 0:
                attr |= dim
                fg = white

            if context.selected:
                attr &= ~reverse
                bg = original_fg if original_fg != default else white

        elif context.in_browser and context.media and context.image and not context.selected:
            fg = cyan + BRIGHT

        if getattr(context, "selected_marker", False):
            if attr & reverse:
                attr &= ~reverse
                bg = fg if fg != default else white

            fg = red + BRIGHT
            attr |= bold

        return fg, bg, attr
