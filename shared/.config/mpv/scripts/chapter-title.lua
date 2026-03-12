local function show_chapter_title()
	local chapter = mp.get_property_number("chapter", -1)
	if chapter < 0 then
		return
	end

	local title = mp.get_property("chapter-metadata/by-key/title", "")
	if title == "" then
		title = mp.get_property("chapter-list/" .. chapter .. "/title", "")
	end
	if title == "" then
		title = ("Chapter %d"):format(chapter + 1)
	end

	mp.osd_message(title, 2)
	print(("chapter=%d title=%s"):format(chapter, title))
end

mp.register_event("file-loaded", function()
	mp.add_timeout(0.1, show_chapter_title)
end)

mp.observe_property("chapter", "native", function()
	show_chapter_title()
end)
