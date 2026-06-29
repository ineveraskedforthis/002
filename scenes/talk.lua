local manager = require "scenes._manager"
local style = require "ui._style"
local scenes = require "scenes._ids"
local battle_manager = require "fights._battle-system"

local id = scenes.dialog
local def = manager.get(id)

local button = require "ui.button"
local panel = require "ui.panel"

local bg = love.graphics.newImage("assets/bg/default.jpg")

---@type TopicInstance[]
local utility_options_base = {
	{
		done = false,
		name = "UTILITY_move",
		params = {}
	},

	{
		done = false,
		name = "UTILITY_talk",
		params = {}
	}
}

---@type TopicInstance
local back_to_utility = {
	done = false,
	name = "UTILITY_back_to_action",
	params = {}
}

---comment
---@param state GameState
---@param journal Journal
---@param render boolean
---@param click boolean
---@param mx number
---@param my number
local function interface(state, journal, render, click, mx, my)
	if (state.current_dialog_actor == 0) then
		state.set_scene(state, scenes.location)
		return
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bg, 0, 0, 0, 1, 1)

	local win_w, win_h, _ = love.window.getMode()

	local actor = state.playable_actors[state.current_dialog_actor]
	if (actor) then
		love.graphics.draw(actor.def.image_battle, win_w - 500, win_h - 500)
	end


	panel(render, win_w / 2 - 200, win_h - 200, 400, 200 - style.base_margin)

	style.default_font_color()
	style.conversation_font()

	-- local atom = state.story_atoms[state.current_story_atom]

	-- if atom == nil then
		-- error(state.current_story_atom .. " lacks definition.")
	-- end

	local current_text  = state.current_text
	love.graphics.printf(current_text, win_w / 2 - 200 + style.base_margin, win_h - 200 + style.base_margin, 400 - 2 * style.base_margin, "center")

	-- local options = atom.options(state, state.playable_actors[state.current_dialog_actor])

	local h = 50

	-- if (options == nil) then
		-- error(state.current_story_atom .. "lacks options")
	-- end

	---@type TopicInstance[]
	local options = {}

	if state.current_dialog_actor == nil then
		-- actions
		if state.options_state == OPTIONS_STATE.NONE then
			options =utility_options_base
		elseif state.options_state == OPTIONS_STATE.MOVE then
			options = {back_to_utility}
		elseif state.options_state == OPTIONS_STATE.TALK then
			for index, value in ipairs(state.playable_actors) do
				if value.location == state.current_location then
					local object_index = journal.actor_index_to_object_index[index]
					local object = journal.objects[object_index]
					---@type TopicInstance
					local new_option = {
						done = false,
						name = "UTILITY_talk_select",
						params = {object_index}
					}
					table.insert(options, new_option)
				end
			end
		end
	else
		-- topics relevant to this actor
		local actor_journal_index = journal.actor_index_to_object_index[state.current_dialog_actor]
		for index, value in ipairs(journal.topics) do
			if not value.done then
				local topic = journal.topic_functors[value.name]
				if topic == nil then
					error ("Missing topic " .. value.name)
				end
				for param_index, param in ipairs(value.params) do
					if param == actor_journal_index and topic.params_description[param_index].is_actor then
						table.insert(options, value)
						goto continue
					end
				end
			end
			::continue::
		end
		table.insert(options, back_to_utility)
	end

	-- print(#options)

	for index, value in ipairs(options) do
		local topic_f = journal.topic_functors[value.name]
		if (topic_f == nil) then
			error("Missing " .. value.name .. " topic functor")
		end
		local option_text = topic_f.text(state, journal, value.params)
		if button(render, click, option_text, win_w / 2 - 200, h + index * 60, 400, 50, mx, my, true) then
			topic_f.effect(state, journal, value.params)
			if not topic_f.repeatable then
				value.done = true
			end
		end
	end

	-- LOG

	panel(render, style.base_margin, style.base_margin, win_w / 2 - 200 - 2 * style.base_margin, win_h - 2 * style.base_margin)
	style.default_font_color()
	style.default_font()

	local log_x = style.base_margin * 2
	local log_y = style.base_margin * 2
	local log_w = win_w / 2 - 200 - 4 * style.base_margin


	if state.current_dialog_actor == nil then
		-- description of the location

		style.header_font()

		local journal_index = journal.location_index_to_object_index[state.current_location]
		local actor = state.playable_actors[state.current_dialog_actor]
		local journal_object = journal.objects[journal_index]
		local name = SHORT_DESCRIPTION(state, journal, journal_object)
		local location = journal.objects[journal_object.location]
		local occupation = journal_object.occupation

		love.graphics.printf(name, log_x, log_y, log_w, "center")

		log_y = log_y + style.default_font_height() * 2
		style.default_font()

		local log = ""

		for index, value in ipairs(journal.topics) do
			local functor = journal.topic_functors[value.name]
			if functor.has_journal_note and (value.done or functor.has_journal_note_even_if_not_done)  then
				local relevant = false
				local relevant_index = 0
				for index, value in ipairs(value.params) do
					if value == journal_index then
						relevant = true
						relevant_index = index
					end
				end

				if relevant then
					log = log .. "\n\t" .. journal.topic_functors[value.name].journal_text(state, journal, value.params, relevant_index)
				end
			end
		end

		love.graphics.printf(log, log_x, log_y, log_w, "left")
	else
		-- description of current dialog partner
		local journal_index = journal.actor_index_to_object_index[state.current_dialog_actor]
		local actor = state.playable_actors[state.current_dialog_actor]
		local name = journal.known_names[journal_index]
		local journal_object = journal.objects[journal_index]
		local location = journal.objects[journal_object.location]
		local occupation = journal_object.occupation

		-- header

		style.header_font()
		if name == nil then
			love.graphics.printf("Name unknown", log_x, log_y, log_w, "center")
		else
			love.graphics.printf(name, log_x, log_y, log_w, "center")
		end
		-- love.graphics.printf(SHORT_DESCRIPTION(state, journal, journal_object), log_x, log_y, log_w, "center")
		log_y = log_y + style.default_font_height() * 2

		style.default_font()

		love.graphics.printf(string.format("Gender: %s", GENDER_TO_STRING(actor.def.gender)), log_x, log_y, log_w, "left")
		log_y = log_y + style.default_font_height()

		love.graphics.printf(string.format("Occupation: %s", OCCUPATION_STRING(occupation)), log_x, log_y, log_w, "left")
		log_y = log_y + style.default_font_height()

		love.graphics.printf(string.format("Location: %s", SHORT_DESCRIPTION(state, journal, location)), log_x, log_y, log_w, "left")
		log_y = log_y + style.default_font_height()

		log_y = log_y + style.default_font_height()

		local log = ""

		-- local log_text = ""
		for index, value in ipairs(journal.topics) do
			local functor = journal.topic_functors[value.name]
			if (functor == nil) then
				error("MISSING " .. value.name .. "TOPIC FUNCTOR")
			end
			if functor.has_journal_note and (value.done or functor.has_journal_note_even_if_not_done)  then
				local relevant = false
				local relevant_index = 0
				for index, value in ipairs(value.params) do
					if value == journal_index then
						relevant = true
						relevant_index = index
					end
				end

				if relevant then
					log = log .. "\n\t" .. journal.topic_functors[value.name].journal_text(state, journal, value.params, relevant_index)
				end
			end
		end

		love.graphics.printf(log, log_x, log_y, log_w, "left")
	end


	-- love.graphics.printf(log_text, log_x, log_y, log_w, "left")


	-- if button(render, click, "Gemstones", 800, 20, 80, 30, mx, my) then
		-- state.set_scene(state, scenes.gemstones)
	-- end
end

---comment
---@param state GameState
function def.render(state, journal)
	local mx, my = love.mouse.getPosition();
	interface(state, journal, true, false, mx, my)
end

---comment
---@param state GameState
---@param x number
---@param y number
function def.on_click(state, journal, x, y)
	interface(state, journal, false, true, x, y)
end