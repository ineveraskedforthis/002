local manager = require "scenes._manager"
local style = require "ui._style"
local battles = require "state.battle"
local battle_loader = require "fights._loader"

local ids = require "scenes._ids"
local id = ids.battle
local def = manager.get(id)

local rect = require "ui.rect"
local skills_panel = require "ui.skills-panel"

local effects_manager = require "effects._manager"

---@param battle Battle
local function update_selection(battle)
	local selected = battle.selected_actor

	if selected and selected.HP > 0 and selected.visible then
		return
	end

	for index, actor in ipairs(battle.actors) do
		if actor.team == 1 and actor.HP > 0 and actor.visible then
			print("select", actor.definition.name)
			battle.selected_actor = actor
		end
	end
end

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

---comment
---@param state GameState
---@param battle Battle
---@param dt number
local function update_effects(state, battle, dt)
	local current_effect = battle.effects_queue[1]
	if current_effect == nil then
		return true
	end

	local def = effects_manager.get(current_effect.def)
	if not current_effect.started then
		def.scene_on_start(state, battle, current_effect.origin, current_effect.target, current_effect.data)
		current_effect.started = true
	end
	current_effect.time_passed = current_effect.time_passed + dt
	if def.scene_update(state, battle, current_effect.time_passed, dt, current_effect.origin, current_effect.target, current_effect.data) then
		table.remove(battle.effects_queue, 1)
		if def.multi_target_selection then
			local targets = def.multi_target_selection(state, battle, current_effect.origin)
			for index, value in ipairs(targets) do
				def.target_effect(state, battle, current_effect.origin, value, current_effect.data)
			end
		else
			def.target_effect(state, battle, current_effect.origin, current_effect.target, current_effect.data)
		end
	end

	return false
end

---comment
---@param state GameState
---@param battle Battle
local function update_ai_turn(state, battle)
	---@type number?
	local target = nil

	local used_skill = battle.actors[1].definition.inherent_skills[1]


	if used_skill.targeted then
		---@type number[]
		local potential_targets = {}
		local count = 0
		for key, value in ipairs(battle.actors) do
			if value.team == 0 and value.HP > 0 then
				table.insert(potential_targets, key)
				count = count + 1
			end
		end
		local index = love.math.random(1, count)
		target = potential_targets[index]
	end

	if target or (not used_skill.targeted) then
		for index, effect in ipairs(used_skill.effects_sequence) do
			local selected_target = nil
			local def = effects_manager.get(effect)
			if def.target_selection then
				selected_target = def.target_selection(state, battle, battle.actors[1])
			else
				selected_target = battle.actors[target]
			end

			if (selected_target) then
				---@type Effect
				local new_effect = {
					data = {},
					def = effect,
					origin = battle.actors[1],
					target = selected_target,
					time_passed = 0,
					started = false,
					times_activated = 0
				}
				table.insert(battle.effects_queue, new_effect)
			end
		end
	end
end

local battle_actor_widget = require "ui.actor"

function def.update(state, dt)
	local battle = state.last_battle
	skills_panel.update(state, dt)

	for key, value in ipairs(battle.actors) do
		if (value.visible) then
			battle_actor_widget.update(state, battle, dt)
		end
	end

	-- select something
	update_selection(battle)

	for _, value in ipairs(battle.actors) do
		update_hp_view(value, dt)
	end

	if battle.stage == battles.BATTLE_STAGE.PROCESS_EFFECTS_AFTER_TURN then
		if not update_effects(state, battle, dt) then
			return
		else
			battle.stage = battles.BATTLE_STAGE.PROCESS_TURN
		end
	end

	if battle.stage == battles.BATTLE_STAGE.PROCESS_TURN then
		battles.process_turn(state, state.last_battle)
		battle.stage = battles.BATTLE_STAGE.PROCESS_EFFECTS_BEFORE_TURN
	end

	if battle.stage == battles.BATTLE_STAGE.PROCESS_EFFECTS_BEFORE_TURN then
		if not update_effects(state, battle, dt) then
			return
		else
			battle.stage = battles.BATTLE_STAGE.AWAIT_TURN
		end
	end

	if battle.stage == battles.BATTLE_STAGE.AWAIT_TURN then
		local battle_lost = true
		for key, value in ipairs(battle.actors) do
			if value.team == 0 and (value.HP_view == nil or value.HP_view > 0) then
				battle_lost = false
			end
		end

		if battle_lost then
			print("battle lost")
			battle.in_progress = false
			love.load()
		end

		local enemies_alive = false;

		for key, value in ipairs(battle.actors) do
			if value.team == 1 and (value.HP_view == nil or value.HP_view > 0) then
				enemies_alive = true
			end
		end

		if not enemies_alive then
			battle.wave = battle.wave + 1
			if not battle_loader(state, state.current_scripted_fight, false) then
				battle.in_progress = false
				battle.wave = 1
				state.set_scene(state, ids.select_battle)
			end
			return
		end

		local current_actor = battle.actors[1]

		if current_actor.team == 1 and current_actor.HP > 0 then
			update_ai_turn(state, battle)
			battle.stage = battles.BATTLE_STAGE.PROCESS_EFFECTS_AFTER_TURN
		end
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

local main_render = require "fights.battle-render"

function def.render(state)
	style.basic_bg_color()
	style.basic_element_color()

	main_render(state.last_battle)

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


	if state.last_battle.actors[1].team == 0 then
		style.default_font()
		love.graphics.print("YOUR TURN", 150, 10)
	end

	-- draw skill buttons
	skills_panel.render(state.last_battle)
end