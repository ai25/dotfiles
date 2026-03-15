local state = {
	active = false,
	pending = false,
	timer = nil,
	prev_pause = nil,
	prev_direction = nil,
}

local function restore()
	if state.timer ~= nil then
		state.timer:kill()
		state.timer = nil
	end

	if not state.active then
		state.pending = false
		return
	end

	if state.prev_direction ~= nil then
		mp.set_property("play-direction", state.prev_direction)
	end
	if state.prev_pause ~= nil then
		mp.set_property_native("pause", state.prev_pause)
	end

	state.active = false
	state.pending = false
	state.prev_pause = nil
	state.prev_direction = nil
end

local function start_reverse()
	if not state.pending or state.active then
		return
	end

	state.timer = nil
	state.active = true
	state.prev_pause = mp.get_property_native("pause")
	state.prev_direction = mp.get_property("play-direction")

	mp.set_property("play-direction", "backward")
	mp.set_property_native("pause", false)
end

mp.add_key_binding(",", "hold-reverse", function(event)
	if event.event == "down" then
		if state.pending or state.active then
			return
		end

		state.pending = true
		state.timer = mp.add_timeout(0.18, start_reverse)
	elseif event.event == "up" or event.canceled then
		if state.pending and not state.active then
			if state.timer ~= nil then
				state.timer:kill()
				state.timer = nil
			end
			state.pending = false
			mp.command("frame-back-step")
			return
		end

		restore()
	end
end, { complex = true })
