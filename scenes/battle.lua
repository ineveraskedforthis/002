local manager = require "scenes._manager"
local style = require "ui._style"

local ids = require "scenes._ids"
local id = ids.battle
local def = manager.get(id)

local rect = require "ui.rect"
local skills_panel = require "ui.skills-panel"

local effects_manager = require "effects._manager"
local battle_manager = require "fights._battle-system"
local main_render = require "fights.battle-render"
local battle_loader = require "fights._loader"

local BATTLE_SYSTEM_RESPONSE = require "fights._response"

---comment
---@param actor Actor
---@param dt number
local function update_hp_view(actor, dt)
	if not actor.HP_view then
		actor.HP_view = actor.HP
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
	end
end

local battle_actor_widget = require "ui.actor"

local await_input = false

function def.update(state, dt)
	local battle = state.last_battle
	skills_panel.update(state, dt)

	for key, value in ipairs(battle.actors) do
		if (value.visible) then
			battle_actor_widget.update(state, battle, dt)
		end
	end

	for _, value in ipairs(battle.actors) do
		update_hp_view(value, dt)
	end

	local res = battle_manager.update_battle_state(state, battle, dt)
	if res == BATTLE_SYSTEM_RESPONSE.AWAIT_USER_INPUT then
		await_input = true
	else
		await_input = false
	end
	if res == BATTLE_SYSTEM_RESPONSE.REQUEST_NEW_WAVE then
		battle.wave = battle.wave + 1
		local battle_in_progress = battle_loader(
			state, state.current_scripted_fight, false
		)
		if not battle_in_progress then
			battle_manager.stop_battle(state, battle)
			state.set_scene(state, ids.select_battle)
		else
			battle_manager.begin_new_wave(state, battle)
		end
	end
	if res == BATTLE_SYSTEM_RESPONSE.BATTLE_WON then
		battle_manager.stop_battle(state, battle)
		state.set_scene(state, ids.select_battle)
	end
	if res == BATTLE_SYSTEM_RESPONSE.BATTLE_LOST then
		battle_manager.stop_battle(state, battle)
		love.load()
	end
end


function def.on_click(state, x, y)
	local battle = state.last_battle
	local offset_x = 150
	local offset_y = 50

	for key, value in ipairs(battle.actors) do
		if battle.actors[key].team == 1 and battle.actors[key].HP > 0 and battle.actors[key].visible then
			local rx, ry, w, h = battle_actor_widget.get_rect(state, battle, value.x, value.y, value)
			if (rect(rx, ry, w, h, x, y)) then
				battle.selected_actor = value
			end
		end
	end
	skills_panel.on_click(state, battle, x, y)
end



function def.render(state)
	style.basic_bg_color()
	style.basic_element_color()

	main_render(state, state.last_battle)

	local effect = state.last_battle.effects_queue[1]
	if effect then
		local def = effects_manager.get(effect.def)
		def.scene_render(
			state, state.last_battle,
			effect.time_passed,
			effect.origin,
			effect.target,
			effect.data
		)
		return
	end


	if await_input then
		style.default_font()
		love.graphics.print("YOUR TURN", 150, 10)
	end

	-- draw skill buttons
	skills_panel.render(state.last_battle)
end