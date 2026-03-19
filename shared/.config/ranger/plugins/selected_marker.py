from ranger.core import linemode
from ranger.gui.widgets.browsercolumn import BrowserColumn, Pager, hook_before_drawing


SELECTED_MARKER = "●"


def _draw_selected_marker_display(self, marked):
    if self.main_column and self.wid > 2:
        marker = SELECTED_MARKER if marked else " "
        return [[marker, ["selected_marker"]]]
    return []


def _draw_directory_with_selected_marker(self):  # pylint: disable=too-many-locals,too-many-branches,too-many-statements
    if self.image:
        self.image = None
        self.need_clear_image = True
        Pager.clear_image(self)

    if self.level > 0 and not self.settings.preview_directories:
        return

    base_color = ["in_browser"]

    if self.fm.ui.viewmode == "multipane" and self.tab is not None:
        active_pane = self.tab == self.fm.thistab
        if active_pane:
            base_color.append("active_pane")
        else:
            base_color.append("inactive_pane")
    else:
        active_pane = False

    self.win.move(0, 0)

    if not self.target.content_loaded:
        self.color(tuple(base_color))
        self.addnstr("...", self.wid)
        self.color_reset()
        return

    if self.main_column:
        base_color.append("main_column")

    if not self.target.accessible:
        self.color(tuple(base_color + ["error"]))
        self.addnstr("not accessible", self.wid)
        self.color_reset()
        return

    if self.target.empty():
        self.color(tuple(base_color + ["empty"]))
        self.addnstr("empty", self.wid)
        self.color_reset()
        return

    self._set_scroll_begin()

    copied = [f.path for f in self.fm.copy_buffer]

    linum_text_len = len(str(self.scroll_begin + self.hei))
    linum_format = "{0:>" + str(linum_text_len) + "}"
    linum_format += " "

    selected_i = self._get_index_of_selected_file()
    for line in range(self.hei):
        i = line + self.scroll_begin

        try:
            drawn = self.target.files[i]
        except IndexError:
            break

        selected = selected_i == i
        tagged = self.fm.tags and drawn.realpath in self.fm.tags
        if tagged:
            tagged_marker = self.fm.tags.marker(drawn.realpath)
        else:
            tagged_marker = " "

        metadata = None
        current_linemode = drawn.linemode_dict[drawn.linemode]
        if current_linemode.uses_metadata:
            metadata = self.fm.metadata.get_metadata(drawn.path)
            if not all(getattr(metadata, tag) for tag in current_linemode.required_metadata):
                current_linemode = drawn.linemode_dict[linemode.DEFAULT_LINEMODE]

        metakey = hash(repr(sorted(metadata.items()))) if metadata else 0
        key = (
            self.wid,
            selected,
            drawn.marked,
            self.main_column,
            drawn.path in copied,
            tagged_marker,
            drawn.infostring,
            drawn.vcsstatus,
            drawn.vcsremotestatus,
            self.target.has_vcschild,
            self.fm.do_cut,
            current_linemode.name,
            metakey,
            active_pane,
            self.settings.line_numbers,
            self.main_column,
        )

        if key in drawn.display_data:
            if self.main_column and self.settings.line_numbers != "false":
                line_number_text = self._format_line_number(linum_format, i, selected_i)
                drawn.display_data[key][0][0] = line_number_text

            self.execute_curses_batch(line, drawn.display_data[key])
            self.color_reset()
            continue

        text = current_linemode.filetitle(drawn, metadata)

        if drawn.marked and (self.main_column or self.settings.display_tags_in_all_columns):
            text = " " + text

        predisplay_left = []
        predisplay_right = []
        space = self.wid

        if self.settings.line_numbers != "false":
            if self.main_column and space - linum_text_len > 2:
                line_number_text = self._format_line_number(linum_format, i, selected_i)
                predisplay_left.append([line_number_text, []])
                space -= linum_text_len
                space -= 1

        selected_marker = self._draw_selected_marker_display(drawn.marked)
        selected_marker_len = self._total_len(selected_marker)
        if space - selected_marker_len > 2:
            predisplay_left += selected_marker
            space -= selected_marker_len

        tagmark = self._draw_tagged_display(tagged, tagged_marker)
        tagmarklen = self._total_len(tagmark)
        if space - tagmarklen > 2:
            predisplay_left += tagmark
            space -= tagmarklen

        vcsstring = self._draw_vcsstring_display(drawn)
        vcsstringlen = self._total_len(vcsstring)
        if space - vcsstringlen > 2:
            predisplay_right += vcsstring
            space -= vcsstringlen

        infostring = []
        infostringlen = 0
        try:
            infostringdata = current_linemode.infostring(drawn, metadata)
            if infostringdata:
                infostring.append([" " + infostringdata + " ", ["infostring"]])
        except NotImplementedError:
            infostring = self._draw_infostring_display(drawn, space)
        if infostring:
            infostringlen = self._total_len(infostring)
            if space - infostringlen > 2:
                predisplay_right = infostring + predisplay_right
                space -= infostringlen

        textstring = self._draw_text_display(text, space)
        textstringlen = self._total_len(textstring)
        predisplay_left += textstring
        space -= textstringlen

        assert space >= 0, (
            "Error: there is not enough space to write the text. "
            "I have computed spaces wrong."
        )
        if space > 0:
            predisplay_left.append([" " * space, []])

        this_color = base_color + list(drawn.mimetype_tuple) + self._draw_directory_color(i, drawn, copied)
        display_data = []
        drawn.display_data[key] = display_data

        drawn, this_color = hook_before_drawing(drawn, this_color)

        predisplay = predisplay_left + predisplay_right
        for txt, color in predisplay:
            attr = self.settings.colorscheme.get_attr(*(this_color + color))
            display_data.append([txt, attr])

        self.execute_curses_batch(line, display_data)
        self.color_reset()


BrowserColumn._draw_selected_marker_display = _draw_selected_marker_display
BrowserColumn._draw_directory = _draw_directory_with_selected_marker
