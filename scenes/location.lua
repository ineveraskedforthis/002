-- this scene will integrate all previous scenes


local fill_image = require "ui.fill-image"
local fill_rect = require "ui.fill-rect"
local draw_rect = require "ui.draw-rect"
local effects = require "effects._manager"


---@type IndexedTopicInstance
local back_to_utility = {
	param_index = 1,
	topic = {
		done = false,
		name = "UTILITY_back_to_action",
		params = {}
	}
}

local hp_bar = require "ui.hp-bar"

---comment
---@param actor Actor
---@param dt number
local function update_hp_view(actor, dt)
	if not actor.HP_view then
		actor.HP_view = actor.HP
	end

	if (actor.HP_view == 0) then
		actor.visible = false
	end

	for index, pending in ipairs(actor.pending_damage) do
		pending.alpha = pending.alpha - dt * 2 * (1 / (1 + index))
	end

	local count = #actor.pending_damage
	---@type number[]
	local to_remove = {}
	for i = count, 1, -1 do
		if actor.pending_damage[i].alpha < 0 then
			table.insert(to_remove, i)
		end
	end

	for index, value in ipairs(to_remove) do
		table.remove(actor.pending_damage, value)
	end

	local diff = actor.HP - actor.HP_view
	local diff_abs = math.abs(diff)
	local max_hp = TOTAL_MAX_HP(actor.definition, actor.wrapper)
	if (diff_abs < max_hp / 20) then
		actor.HP_view = actor.HP
	else
		actor.HP_view = actor.HP_view + math.max(-max_hp, math.min(max_hp, diff / diff_abs * max_hp * dt))
		-- print("NEW HP VIEW", actor.HP_view)
	end
end

local manager = require "scenes._manager"
local style = require "ui._style"
local scenes = require "scenes._ids"
local battle_manager = require "fights._battle-system"
local draw_actor = require "ui.actor"

local skills_panel = require "ui.skills-panel"

local ids = require "scenes._ids"
local id = ids.location
local def = manager.get(id)

local rect = require "ui.rect"
local button = require "ui.button"

local MAP = {}

local camera_center_x = 0
local camera_center_y = 0

local cell_width = 20
local cell_height = 20

local margin = 2

-- local shift_x = cell_height * 15
-- local shift_y = cell_width * 15

---@class EnemyPack
---@field alive boolean
---@field x number
---@field y number

local selected_x = 0
local selected_y = 0

local button = require "ui.button"
local panel = require "ui.panel"

local bg = love.graphics.newImage("assets/bg/default.jpg")


local internal_timer = 0
---@type number[]
local transition = {}
---@type boolean[]
local active_cells = {}

for i = 0, 100 do
	transition[i] = 0
	active_cells[i] = false
end

---comment
---@param render boolean
---@param click boolean
---@param x number
---@param y number
---@param width number
---@param height number
---@param mx number
---@param my number
---@param acting_actor Actor
---@param value ActiveSkill
local function skill_button(render, click, x, y, width, height, mx, my, acting_actor, value)
	local m_x, m_y = love.mouse.getPosition()

	local hovered = false

	if value.icon then
		fill_image(value.icon, x, y, width, height)
	else
		button(render, click, value.name, x, y, width, height, mx, my, false)
	end

	if rect(x, y, width, height, m_x, m_y) then
		hovered = true
		local text = value.name .. "\n"
		text = text .. value.description(acting_actor) .. "\n"
		if value.on_skill_used_sequence then
			for index, effect in ipairs(value.on_skill_used_sequence) do
				local effect_def = effects.get(effect)
				text = text .. tostring(index) .. " ".. effect_def.description .. "\n"
			end
		end
		text = text .. "When you are attacked:\n"
		if value.on_being_attacked_sequence then
			for index, effect in ipairs(value.on_being_attacked_sequence) do
				local effect_def = effects.get(effect)
				text = text .. tostring(index) .. " ".. effect_def.description .. "\n"
			end
		end
		-- love.graphics.printf(text, window_size - description_offset_x, description_offset_y, description_offset_x - style.base_margin, "left")
	end

	return hovered
end

---comment
---@param i number
---@param x number
---@param y number
---@param w number
---@param h number
---@param active boolean
---@param reserve boolean
local function energy_point(i, x, y, w, h, active, reserve)
	-- local current_y = window_h - style.skill_button_size - style.base_margin - style.energy_point_h - style.base_margin + (row - 2) * (style.energy_point_h + 5) + shift_panel

	-- local shift_y = 0
	-- local fill = false


	local t = SMOOTHERSTEP(transition[i])

	local r = 0.2
	local g = 0.8
	local b = 1

	local fill = true

	if reserve then
		active_cells[i] = true
	end

	if active then
		love.graphics.setColor(r, g, b, 1)
		fill = true
	else
		if reserve then
			love.graphics.setColor(0.9, 0.5, 0.5, 1)
		else
			love.graphics.setColor(0.1, 0.1, 0.1, 1)
		end
	end

	-- if reserve and fill then
	-- 	fill = true
	-- 	active_cells[i] = true
	-- elseif reserve then
	-- 	fill = false
	-- 	active_cells[i] = true
	-- elseif fill then
	-- 	fill = true
	-- 	active_cells[i] = false
	-- else
	-- 	love.graphics.setColor(1, 0, 0, 1)
	-- 	fill = false
	-- 	active_cells[i] = false
	-- end

	local shrink = 5 * t
	shift_y = -3 * (4 + math.cos(internal_timer * 2 + i / 2)) * t

	if fill then
		fill_rect(
			x,
			y,
			w,
			h
		)

		if shrink > 0 then


			love.graphics.setColor(r * (1 - t), g * (1 - t) + 0.1 * t, b * (1 - t) + 0.5 * t, 1)
			fill_rect(
				x + shrink,
				y + shrink,
				w - shrink * 2,
				h - shrink * 2
			)
		end
	end

	love.graphics.setColor(0, 0, 0, 1)

	draw_rect(
		x,
		y,
		w,
		h
	)
end

---comment
---@param x number
---@param y number
---@param w number
---@param h number
---@return number
local function to_pixel_id(x, y, w, h)
	return y * w + x
end

---comment
---@param v number
---@param w number
---@param h number
---@return number
---@return number
local function from_pixel_id(v, w, h)
	return v % w, math.floor(v / w)
end

local function dist (a, b, c, d)
	return math.sqrt((a - c) * (a - c) + (b - d) * (b - d))
end

---comment
---@param heap number[]
---@param heap_last number
---@param heap_values_1 table<number, number>
---@param heap_values_2 table<number, number>
---@param ptr number
local function heap_sift_down(heap, heap_values_1, heap_values_2, heap_last, ptr)
	local c = heap[ptr]
	local v = heap_values_1[c] + heap_values_2 [c]
	---@type number
	local left_ptr = ptr * 2
	---@type number
	local right_ptr = ptr * 2 + 1

	while left_ptr <= heap_last do
		assert(c == heap[ptr])
		local l = heap[left_ptr]
		local lv = heap_values_1[l] + heap_values_2 [l]
		if right_ptr <= heap_last then
			local r  = heap[right_ptr]
			local rv = heap_values_1[r] + heap_values_2 [r]

			-- print(ptr, "p->", left_ptr, right_ptr)
			-- print(c, "h->", heap[left_ptr], heap[right_ptr])
			-- print(v, "->", lv, rv)
			if rv >= v and lv >= v then
				break
			else
				if rv > lv then
					heap[ptr] = l
					heap[left_ptr] = c
					ptr = left_ptr
				else
					heap[ptr] = r
					heap[right_ptr] = c
					ptr = right_ptr
				end
			end
		else
			-- print(v, "->", lv)
			if lv >= v then
				break
			else
				heap[ptr] = l
				heap[left_ptr] = c
				ptr = left_ptr
			end
		end

		left_ptr = ptr * 2
		right_ptr = ptr * 2 + 1
	end
end

---@param heap number[]
---@param heap_last number
---@param heap_values_1 table<number, number>
---@param heap_values_2 table<number, number>
---@param ptr number
local function heap_sift_up(heap, heap_values_1, heap_values_2, heap_last, ptr)
	local up_ptr = math.floor((ptr - 1) / 2) + 1
	local up = heap[up_ptr]
	local up_v = heap_values_1[up] + heap_values_2[up]
	local c = heap[ptr]
	local cv = heap_values_1[c] + heap_values_2[c]
	while ptr > 1 and up_v > cv do
		heap[up_ptr] = c
		heap[ptr] = up

		ptr = up_ptr
		up_ptr = math.floor((ptr - 1) / 2) + 1
		up = heap[up_ptr]
		up_v = heap_values_1[up] + heap_values_2[up]
	end
	return ptr
end

---comment
---@param start_x number
---@param start_y number
---@param end_x number
---@param end_y number
---@param w number
---@param h number
---@param movement_mask love.ImageData
---@return number[]
local function path(start_x, start_y, end_x, end_y, w, h, movement_mask)

	---@type table<number, boolean>
	local seen = {}

	---@type table<number, number>
	local prev = {}

	local hope = true

	---@type table<number, number>
	local current_distance = {}
	---@type table<number, number>
	local current_heuristic = {}

	local start = to_pixel_id(start_x, start_y, w, h)

	---@type number[]
	local heap = {}
	heap[1] = start
	---@type number
	local heap_last = 1
	current_distance[start] = 0
	current_heuristic[start] = dist(start_x, start_y, end_x, end_y)
	prev[start] = start
	seen[start] = true

	local end_pixel = to_pixel_id(end_x, end_y, w, h)

	local path_found = false

	while hope and heap_last > 0 do
		-- pop element from the heap
		local current = heap[1]
		local x, y =from_pixel_id(current, w, h)
		-- print(x, y)
		if current == end_pixel then
			path_found = true
			break
		end

		-- pop
		-- print("POP_TOP_AND_PUSH_BACK_TO_TOP", heap[heap_last])
		heap[1] = heap[heap_last]
		heap_last = heap_last  - 1
		heap_sift_down(heap, current_distance, current_heuristic, heap_last, 1)

		-- do
		-- 	local heap_min = heap[1]
		-- 	local min_index = 1

		-- 	print("AFTER POP")

		-- 	for index, value in ipairs(heap) do
		-- 		if current_distance[heap_min] + current_heuristic[heap_min] > current_distance[value] + current_heuristic[value] then
		-- 			heap_min = value
		-- 			min_index = index
		-- 		end
		-- 	end


		-- 	for index, value in ipairs(heap) do
		-- 		for index2, value2 in ipairs(heap) do
		-- 			if index ~= index2 and index <= heap_last and index2 <= heap_last then
		-- 				assert(value ~= value2)
		-- 			end
		-- 		end
		-- 	end

		-- 	print(min_index, heap_last)
		-- 	assert(min_index == 1)
		-- end

		for i = -1, 1 do
			for j = -1, 1 do
				local xp = x + i
				local yp = y + j

				if xp >= 0 and yp >= 0 and xp < w and yp < h and movement_mask:getPixel(xp, yp) > 0 then
					local next = to_pixel_id(xp, yp, w, h)
					if not seen[next] then
						seen[next] = true
						current_distance[next] = current_distance[current] + dist(0, 0, i, j) * (1 + (1 - movement_mask:getPixel(xp, yp)) * 10)
						current_heuristic[next] = dist(xp, yp, end_x, end_y) * 0.5
						prev[next] = current

						heap_last = heap_last + 1
						heap[heap_last] = next
						local next_ptr = heap_sift_up(heap, current_distance, current_heuristic, heap_last, heap_last)
						heap_sift_down(heap, current_distance, current_heuristic, heap_last, next_ptr)

						-- local heap_min = heap[1]
						-- local min_index = 1


						-- print("AFTER PUSH")
						-- for index, value in ipairs(heap) do
						-- 	for index2, value2 in ipairs(heap) do
						-- 		if index ~= index2 and index <= heap_last and index2 <= heap_last then
						-- 			assert(value ~= value2)
						-- 		end
						-- 	end
						-- end

						-- for index, value in ipairs(heap) do
						-- 	if current_distance[heap_min] + current_heuristic[heap_min] > current_distance[value] + current_heuristic[value] then
						-- 		heap_min = value
						-- 		min_index = index
						-- 	end
						-- end

						-- print(min_index, heap_last)

						-- assert(min_index == 1)

						-- for index, value in ipairs(heap) do
						-- 	print("H", index, current_distance[value], current_heuristic[value], current_distance[value] + current_heuristic[value])
						-- end
					end
				end
			end
		end
	end

	print("path found")

	local reverse_path = {}
	if path_found then
		table.insert(reverse_path, end_pixel)
		local current = end_pixel
		while current ~= start do
			current = prev[current]
			table.insert(reverse_path, current)
		end
	end
	local size_path = #reverse_path
	local direct_path = {}
	for i = 1, size_path do
		local p = reverse_path[size_path - i + 1]
		local px, py = from_pixel_id(p, w, h)
		table.insert(direct_path, px)
		table.insert(direct_path, py)
	end

	return direct_path
end

local status_bar_height = 25
local status_bar_heigth_with_margins = status_bar_height + style.base_margin
local g_1_w = 300
local g_1_1_h = 400
local g_2_w = 500

local current_path = {}
local selected_actor = nil

---@param state GameState
---@param journal Journal
---@param render boolean
---@param click boolean
---@param mx number
---@param my number
local function interface(state, journal, render, click, mx, my)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bg, 0, 0, 0, 1, 1)

	local w_h = love.graphics.getHeight()
	local w_w = love.graphics.getWidth()
	local g_1_2_h = w_h - g_1_1_h - style.base_margin * 3 - status_bar_heigth_with_margins

	-- panel(render, w_w - 500, w_h - 500, 500, 500)
	local player_actor = state.actors[state.main_character_actor]


	if (selected_actor) then
		local value = state.actors[selected_actor]
		love.graphics.setColor(1, 1, 1, 1)
		if value.definition.image_battle then
			love.graphics.draw(value.definition.image_battle, w_w - 500, w_h - 500)
		else
			love.graphics.draw(value.definition.image, w_w - 400, w_h - 400, 0, 4, 4)
		end
	end

	panel(render, w_w - 400, w_h - 200, 300 - style.base_margin, 100)
	style.default_font_color()
	style.conversation_font()

	local current_text  = state.current_text
	love.graphics.printf(current_text, w_w - 400 + style.base_margin, w_h - 200 + style.base_margin, 300 - 2 * style.base_margin, "center")


	local selected_meta_wrapper = nil
	for index, value in pairs(state.playable_actors) do
		if value.actor_index == selected_actor then
			selected_meta_wrapper = index
		end
	end

	if selected_actor then
		local value = state.actors[selected_actor]
		local level = nil
		if selected_meta_wrapper then
			level = state.playable_actors[selected_meta_wrapper].level
		end
		hp_bar(w_w - 400, w_h - 75, 300, 20, value.HP, value.HP_view, TOTAL_MAX_HP(value.definition), value.SHIELD, false, nil)
	end


	do
		-- Log
		local log_x = style.base_margin * 2
		local log_y = style.base_margin * 2
		local log_w = g_1_w - style.base_margin * 4

		panel(render, style.base_margin, style.base_margin, g_1_w, g_1_1_h)
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

	end
	panel(render, style.base_margin, style.base_margin * 2 + g_1_1_h , g_1_w, g_1_2_h)

	do
		local left = g_1_w + style.base_margin * 2
		local top = style.base_margin
		-- Map
		local time = state.current_time

		local day_time = time % (DAY_LENGTH * DAY_SEGMENT_LENGTH)
		local day_progress = day_time / (DAY_LENGTH * DAY_SEGMENT_LENGTH)

		local day_ratio = math.sin(day_progress * math.pi)

		local location_data = state.location_data[LOCATION.AT_CITY_GATES]

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(location_data.image_night, left, top)
		love.graphics.setColor(1, 1, 1, day_ratio * day_ratio)
		love.graphics.draw(location_data.image_day, left, top)

		for index, value in ipairs(state.actors) do
			if value.visible and value.wrapper.location == state.playable_actors[state.main_character].location then
				local x = value.view_x
				local y = value.view_y
				-- local tile_x = shift_x + tile_i * cell_width - camera_center_x
				-- local tile_y = shift_y + tile_j * cell_height - camera_center_y
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.rectangle("fill", left + x - 10, top + y - 10, 20, 20)
			end
		end

		-- panel(render, g_1_w + style.base_margin * 2, style.base_margin, g_2_w, g_1_1_h)
		local shift_x = g_1_w + style.base_margin * 2 + g_2_w / 2
		local shift_y = style.base_margin + g_1_1_h / 2
		local center_x = math.floor(camera_center_x / cell_width)
		local center_y = math.floor(camera_center_y / cell_height)
		if click and rect(left, top, g_2_w, g_1_1_h, mx, my) then
			local talk = false
			for index, value in ipairs(state.actors) do
				if not value.visible then
					goto continue
				end
				if (value.wrapper.location ~= state.playable_actors[state.main_character].location) then
					goto continue
				end

				if (dist(value.x, value.y, mx - left, my - top) < 20) then
					if index == selected_actor then
						talk = true
					else
						selected_actor = index
						state.current_dialog_actor = nil
						return
					end
				end

				::continue::
			end

			if not talk then
				selected_actor = nil
			end

			if state.current_dialog_actor then
				state.current_dialog_actor = nil
				return
			end

			selected_x = mx - left
			selected_y = my - top

			local x = state.actors[state.main_character_actor].x
			local y = state.actors[state.main_character_actor].y
			current_path = path(x, y, selected_x, selected_y, location_data.x, location_data.y, location_data.movement_mask)

			-- clean buffer:
			if state.command_buffer_left ~= state.command_buffer_right then
				state.command_buffer_right = (state.command_buffer_left + 1) % state.command_buffer_size
			end

			if #current_path > 0 then

				local last = #current_path - 1
				local last_x = current_path[1]
				local last_y = current_path[2]

				local offset = 0
				if talk then
					offset = -20
				end

				for i = 11, #current_path + offset, 10 do
					state.command_buffer[state.command_buffer_right] = {
						acting_actor = state.main_character,
						stack_pointer = state.programs[PROGRAM.MOVE],
						target_actor = state.main_character,
						target_x = current_path[i],
						target_y = current_path[i + 1],
						timer = 0,
						origin_x = current_path[i - 10],
						origin_y = current_path[i - 9]
					}
					last_x  = current_path[i]
					last_y = current_path[i + 1]
					state.command_buffer_right = (state.command_buffer_right + 1) % state.command_buffer_size
				end

				if (last + offset > 1) then
					state.command_buffer[state.command_buffer_right] = {
						acting_actor = state.main_character,
						stack_pointer = state.programs[PROGRAM.MOVE],
						target_actor = state.main_character,
						target_x = current_path[last + offset ],
						target_y = current_path[last + offset  + 1],
						timer = 0,
						origin_x = last_x,
						origin_y = last_y
					}
					state.command_buffer_right = (state.command_buffer_right + 1) % state.command_buffer_size
				end

				if talk then
					state.command_buffer[state.command_buffer_right] = {
						acting_actor = state.main_character,
						stack_pointer = state.programs[PROGRAM.TALK],
						target_actor = selected_actor,
						target_x = selected_x,
						target_y = selected_y,
						timer = 0,
						origin_x = player_actor.x,
						origin_y = player_actor.y
					}
					state.command_buffer_right = (state.command_buffer_right + 1) % state.command_buffer_size
				end
			end
		end

		-- for i = 1, #current_path do
		-- end

		love.graphics.setColor(1, 0, 0, 1)
		for i = 3, #current_path, 2 do
			love.graphics.points(left + current_path[i - 2], top + current_path[i - 1])
		end
	end

	do
		local left = g_1_w + style.base_margin * 2
		local top =style.base_margin * 2 + g_1_1_h

		if state.current_dialog_actor == nil then
			-- Actions
			-- panel(render, left, top, g_2_w, g_1_2_h)
			local main_character = state.main_character
			local main_actor = state.actors[main_character]
			local actor = state.actors[state.main_character_actor]

			local reserve_points = 0
			local offset_y = top + 60
			local skill_button_width = 60
			local skill_button_height = 40
			local current_x = left + style.base_margin
			for key, value in ipairs(actor.definition.inherent_skills) do
				if skill_button(render, click, current_x, offset_y, skill_button_width, skill_button_height, mx, my, actor, value) then
					reserve_points = value.required_energy
					if click then
						print(value.program, state.programs[value.program])
						local ta = selected_actor
						if (ta == nil) then
							ta = state.main_character
						end

						state.command_buffer[state.command_buffer_right] = {
							acting_actor = state.main_character,
							stack_pointer = state.programs[value.program],
							target_actor = ta,
							target_x = selected_x,
							target_y = selected_y,
							timer = 0,
							origin_x = actor.x,
							origin_y = actor.y
						}
						state.command_buffer_right = (state.command_buffer_right + 1) % state.command_buffer_size
					end
				end
				current_x = current_x + style.skill_button_size
			end
			if (actor.wrapper) then
				for key, value in ipairs(actor.wrapper.skills) do
					if skill_button(render, click, current_x, offset_y, skill_button_width, skill_button_height, mx, my, actor, value) then
						reserve_points = value.required_energy
						if click and (not value.targeted or (selected_actor ~= nil and state.actors[selected_actor].visible)) then
							-- print(value.program, state.programs[value.program])
							local ta = selected_actor
							if (ta == nil) then
								ta = state.main_character
							end
							state.command_buffer[state.command_buffer_right] = {
								acting_actor = state.main_character,
								stack_pointer = state.programs[value.program],
								target_actor = ta,
								target_x = selected_x,
								target_y = selected_y,
								timer = 0,
								origin_x = actor.x,
								origin_y = actor.y
							}
							state.command_buffer_right = (state.command_buffer_right + 1) % state.command_buffer_size
						end
					end
					---@type number
					current_x = current_x + style.skill_button_size

				end
			end

			local shift = math.max(0, actor.energy - reserve_points)

			if click then
			else
				local row = 0
				local column = 0
				local w = 20
				local h = 20
				for raw_i = 0, 24, 1 do
					local i = raw_i + 1
					-- if i <= 10 then
						-- row = 0
					-- else
						-- row = 1
					-- end
					column = raw_i
					-- column = (i - 1) % 10
					local reserved = i > shift and i - shift <= reserve_points
					local current = i <= actor.energy
					energy_point(
						i,
						left + column * w,
						top + row * h,
						w, h,
						current, reserved
					)
				end
				-- skills_panel.render(state.last_battle, main_actor, 200, -status_bar_heigth_with_margins)

				hp_bar(left + style.base_margin, top + h + style.base_margin, g_2_w - style.base_margin * 2, 20, player_actor.HP, player_actor.HP_view, TOTAL_MAX_HP_ACTOR(player_actor), player_actor.SHIELD, false, nil)

			end
		else
			local options = {}
			-- topics relevant to this actor
			local actor_journal_index = journal.actor_index_to_object_index[state.current_dialog_actor]
			for index, value in ipairs(journal.topics) do
				local topic = journal.topic_functors[value.name]
				if not value.done then
					if topic == nil then
						error ("Missing topic " .. value.name)
					end
					for param_index, param in ipairs(value.params) do
						if
							param == actor_journal_index
							and topic.params_description[param_index].is_actor
							and topic.has_option(state, journal, value.params, param)
						then
							table.insert(options, {topic = value, param_index = param_index})
							goto continue
						end
					end
				end
				::continue::
			end
			table.insert(options, back_to_utility)

			for index, value in ipairs(options) do
				local topic_f = journal.topic_functors[value.topic.name]
				if (topic_f == nil) then
					error("Missing " .. value.topic.name .. " topic functor")
				end
				local option_text = topic_f.option_text(state, journal, value.topic.params, value.param_index)
				if button(render, click, option_text, left, top + (index - 1) * 60, 400, 50, mx, my, true) then
					topic_f.effect(state, journal, value.topic.params, value.param_index)
					if not topic_f.repeatable then
						value.topic.done = true
					end
				end
			end
		end
	end


	if (selected_meta_wrapper ~= nil) then
		-- Target journal entry
		local log_x = g_1_w + g_2_w + style.base_margin * 4
		local log_y = style.base_margin * 2
		local log_w = w_w - g_1_w - g_2_w - style.base_margin * 4

		panel(render, g_1_w + g_2_w + style.base_margin * 3, style.base_margin, w_w - g_1_w - g_2_w - style.base_margin * 4, 210 )

		local journal_index = journal.actor_index_to_object_index[selected_meta_wrapper]

		local actor = state.playable_actors[selected_meta_wrapper]
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
	end



	do
		-- Status bar
		local status_x = style.base_margin
		local status_y = w_h - status_bar_heigth_with_margins
		panel(render, status_x, status_y, w_w - style.base_margin * 2, status_bar_height)
		local status_string = string.format("%d coins. %s", state.currency, TIME_STRING(state.current_time))
		love.graphics.print(status_string, status_x + style.base_margin, status_y)
	end

end

function def.render(state, journal)
	local mx, my = love.mouse.getPosition();
	-- local window_h = love.graphics.getHeight()
	interface(state, journal, true, false, mx, my)
	-- draw_actor.render(state, 30, window_h - 150, state.main_character_actor, 1, false)


	local shift_x = g_1_w + style.base_margin * 2
	local shift_y = style.base_margin

	for actor_index, actor in ipairs(state.actors) do

		local x = shift_x + actor.view_x - camera_center_x
		local y = shift_y + actor.view_y - camera_center_y

		for index, value in ipairs(actor.pending_damage) do
			if not value.particle_exist then
				local rgb = {1, 0, 0}
				if value.value <= 0 then
					rgb = {0, 1, 0}
				end
				state.vfx.new_text(
					tostring(math.abs(value.value)), rgb,
					x, y,
					love.math.randomNormal() * 20,
					-20,
					math.log(math.abs(value.value) + 1, 3),
					4
				)
				value.particle_exist = true
			end
		end
	end
end


function def.on_click(state, journal, x, y)
	interface(state, journal, true, true, x, y)
end

---@param state GameState
---@param effect Effect
local function handle_singular_effect(state, effect)
	local def = effects.get(effect.def)

	if def.multi_target_selection then
		local targets = def.multi_target_selection(state, effect.origin)
		for index, value in ipairs(targets) do
			def.target_effect(state, effect.origin, value, effect.data)
		end
	else
		def.target_effect(state, effect.origin, effect.target, effect.data)
	end
end

function def.update(state, journal, dt)

	---@type number
	internal_timer = internal_timer + dt
	for index, value in ipairs(transition) do
		if active_cells[index] then
			transition[index] = math.min(1, transition[index] + dt)
		else
			transition[index] = math.max(0, transition[index] - dt)
		end
	end

	for _, value in ipairs(state.actors) do
		update_hp_view(value, dt)
	end
	draw_actor.update(dt)

	if state.turn_stage ==TURN_STAGE.AWAIT_INPUT then

		-- drain command buffer
		local main_actor = state.actors[state.main_character_actor]
		if
			state.command_buffer_right ~= state.command_buffer_left
			and main_actor.stack_top == 0
		then
			local frame_to_copy = state.command_buffer[state.command_buffer_left]

			local target_actor_is_alive = frame_to_copy.target_actor and state.actors[frame_to_copy.target_actor].HP > 0
			local origin_actor_is_alive = frame_to_copy.acting_actor and state.actors[frame_to_copy.acting_actor].HP > 0

			if (target_actor_is_alive and origin_actor_is_alive) then
				main_actor.stack_top = 1
				main_actor.stack[1] = {
					acting_actor = frame_to_copy.acting_actor,
					stack_pointer = frame_to_copy.stack_pointer,
					target_x = frame_to_copy.target_x,
					target_y = frame_to_copy.target_y,
					target_actor = frame_to_copy.target_actor,
					timer = frame_to_copy.timer,
					origin_x = frame_to_copy.origin_x,
					origin_y = frame_to_copy.origin_y
				}
			end

			state.command_buffer_left = (state.command_buffer_left + 1) % state.command_buffer_size
		end

		local switch_stage = true

		for index, value in ipairs(state.actors) do
			if value.stack_top == 0 and index ~= state.main_character_actor then
				value.stack_top = 1
				value.stack[1] = {
					acting_actor = index,
					stack_pointer = state.programs[PROGRAM.WAIT],
					target_x = value.x,
					target_y = value.y,
					target_actor = index,
					timer = 0,
					origin_x = value.x,
					origin_y = value.y
				}
			end
			if value.stack_top == 0 then
				switch_stage = false
			end
		end

		if switch_stage then
			state.turn_stage = TURN_STAGE.RUN_INTERPRETER
		end

	elseif state.turn_stage ==TURN_STAGE.RUN_INTERPRETER then
		local switch_stage = false
		-- run interpreter
		state.current_time = state.current_time + dt * 100
		for index, value in ipairs(state.actors) do
			if value.stack_top > 0 then
				local ready = true
				local ret = false
				while ready and not ret do
					local frame = value.stack[value.stack_top]
					local current_instruction = state.instruction_stack[frame.stack_pointer]
					ready, ret = state.instruction_set[current_instruction[1]](state, frame, dt, current_instruction[2], current_instruction[3], current_instruction[4])
					if ready then
						frame.stack_pointer = frame.stack_pointer + 1
					end
					if ret then
						value.stack_top = value.stack_top - 1
					end
				end
			else
				switch_stage = true
			end
		end
		if switch_stage then
			state.turn_stage = TURN_STAGE.AWAIT_INPUT
		end
	end

	---Effects
	local current_effect = state.effects_queue[1]
	if current_effect ~= nil then
		local def = effects.get(current_effect.def)

		if not current_effect.started then
			def.scene_on_start(state, current_effect.origin, current_effect.target, current_effect.data)
			current_effect.started = true
		end

		current_effect.time_passed = current_effect.time_passed + dt

		if not def.do_not_skip then
			local origin_dead = current_effect.origin.HP <= 0
			local target_dead = current_effect.target.HP <= 0

			if origin_dead or target_dead then
				table.remove(state.effects_queue, 1)
			end
		end

		if def.scene_update(state, current_effect.time_passed, dt, current_effect.origin, current_effect.target, current_effect.data) then
			-- effect time run out, we can perform actual effect and delete effect from queue
			table.remove(state.effects_queue, 1)
			handle_singular_effect(state, current_effect)
		end
	end
end