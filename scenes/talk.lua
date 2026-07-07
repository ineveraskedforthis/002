local manager = require "scenes._manager"
local style = require "ui._style"
local scenes = require "scenes._ids"
local battle_manager = require "fights._battle-system"

local id = scenes.dialog
local def = manager.get(id)

local button = require "ui.button"
local panel = require "ui.panel"


---@type IndexedTopicInstance[]
local utility_options_base = {
	{
		param_index = 1,
		topic = {
			done = false,
			name = "UTILITY_move",
			params = {}
		},
	},
	{
		param_index = 1,
		topic = {
			done = false,
			name = "UTILITY_talk",
			params = {}
		}
	}

}

---@class IndexedTopicInstance
---@field topic TopicInstance
---@field param_index number

---comment
---@param state GameState
---@param journal Journal
---@param render boolean
---@param click boolean
---@param mx number
---@param my number
local function interface(state, journal, render, click, mx, my)
	local status_bar_height = 25
	local status_bar_heigth_with_margins = status_bar_height + style.base_margin * 2

	if (state.current_dialog_actor == 0) then
		state.set_scene(state, scenes.location)
		return
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bg, 0, 0, 0, 1, 1)

	local win_w, win_h, _ = love.window.getMode()

	local actor = state.playable_actors[state.current_dialog_actor]
	if (actor) then
		if actor.def.image_battle then
			love.graphics.draw(actor.def.image_battle, win_w - 500, win_h - 500)
		else
			love.graphics.draw(actor.def.image, win_w - 400, win_h - 400, 0, 4, 4)

		end
	end



	local h = 50

	---@type IndexedTopicInstance[]
	local options = {}

	if (state.last_battle_awaits_topic_resolution) then
		state.last_battle_awaits_topic_resolution = false
		if state.last_battle_result ==BATTLE_RESULT.VICTORY then
			table.insert(journal.topics, journal.new_topic_on_battle_won)
		elseif state.last_battle_result == BATTLE_RESULT.DEFEAT then
			table.insert(journal.topics, journal.new_topic_on_battle_lost)
		end
	end

	if state.current_dialog_actor == nil then
		-- actions
		if state.options_state == OPTIONS_STATE.NONE then
			for k, v in ipairs(utility_options_base) do
				table.insert(options, v)
			end

			for key, value in pairs(journal.topics) do
				local topic = journal.topic_functors[value.name]
				if
					(not value.done)
					and topic.kind ==TOPIC_KIND.ATTACK
					and value.params[1] == journal.location_index_to_object_index[state.playable_actors[state.main_character].location]
				then
					table.insert(options, {topic = value, param_index = 1})
				end
			end
		elseif state.options_state == OPTIONS_STATE.MOVE then
			for index, value in ipairs(journal.topics) do
				local functor = journal.topic_functors[value.name]
				if
					functor.kind ==TOPIC_KIND.MOVEMENT
					and value.params[1] == journal.location_index_to_object_index[state.playable_actors[state.main_character].location]
				then
					table.insert(options, {topic = value, param_index = 1})
				end
			end
			table.insert(options, back_to_utility)
		elseif state.options_state == OPTIONS_STATE.TALK then
			for index, value in ipairs(state.playable_actors) do
				if
					value.location == state.playable_actors[state.main_character].location
					and index ~= state.main_character
				then
					local object_index = journal.actor_index_to_object_index[index]
					local object = journal.objects[object_index]
					---@type IndexedTopicInstance
					local new_option = {
						param_index = 1,
						topic = {
							done = false,
							name = "UTILITY_talk_select",
							params = {object_index}
						}
					}
					table.insert(options, new_option)
				end
			end
			table.insert(options, back_to_utility)
		end
	else

	end

	-- print(#options)


	-- LOG

	panel(render, style.base_margin, style.base_margin, win_w / 2 - 200 - 2 * style.base_margin, win_h - 2 * style.base_margin - status_bar_heigth_with_margins)
	style.default_font_color()
	style.default_font()

	local log_x = style.base_margin * 2
	local log_y = style.base_margin * 2
	local log_w = win_w / 2 - 200 - 4 * style.base_margin


	if state.current_dialog_actor == nil then
		-- description of the location

		style.header_font()

		local journal_index = journal.location_index_to_object_index[state.playable_actors[state.main_character].location]
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
					log = log .. "\n\t" .. value.name .. "\t" .. journal.topic_functors[value.name].journal_text(state, journal, value.params, relevant_index)
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
				error("MISSING " .. value.name .. " TOPIC FUNCTOR")
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
