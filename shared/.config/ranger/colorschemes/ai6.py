from ranger.colorschemes.default import Default
from ranger.gui.color import BRIGHT, cyan


class Scheme(Default):
    def use(self, context):
        fg, bg, attr = Default.use(self, context)

        if context.in_browser and context.media and context.image:
            fg = cyan + BRIGHT

        return fg, bg, attr
