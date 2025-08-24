local clear = require "table.clear"
local effects_manager = require "effects._manager"

local BATTLE_STAGE = require "fights._stages"
local BATTLE_SYSTEM_RESPONSE = require "fights._response"

---@class BattleState
---@field actors Actor[]
---@field effects_queue Effect[]
---@field selected_actor Actor?
---@field in_progress boolean
---@field wave number
---@field stage BATTLE_STAGE

local manager = {}

---@param state GameState
---@param battle BattleState
---@param effect Effect
local function handle_singular_effect(state, battle, effect)
	local def = effects_manager.get(effect.def)

	if def.multi_target_selection then
		local targets = def.multi_target_selection(state, battle, effect.origin)
		for index, value in ipairs(targets) do
			def.target_effect(state, battle, effect.origin, value, effect.data)
		end
	else
		def.target_effect(state, battle, effect.origin, effect.target, effect.data)
	end
end

---comment
---@param state GameState
---@param battle BattleState
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
		-- effect time run out, we can perform actual effect and delete effect from queue

		table.remove(battle.effects_queue, 1)
		handle_singular_effect(state, battle, current_effect)
	end

	return false
end

---@param state GameState
---@param battle BattleState
---@param dt number
---@return BATTLE_SYSTEM_RESPONSE
local function process_new_wave(state, battle, dt)
	if update_effects(state, battle, dt) then
		manager.process_turn(state, battle, true)
		battle.stage = BATTLE_STAGE.PROCESS_EFFECTS_BEFORE_TURN
	end
	return BATTLE_SYSTEM_RESPONSE.OK
end

---@return BATTLE_SYSTEM_RESPONSE
local function process_after_turn(state, battle, dt)
	if update_effects(state, battle, dt) then
		battle.stage = BATTLE_STAGE.PROCESS_TURN
	end

	return BATTLE_SYSTEM_RESPONSE.OK
end

---@param battle BattleState
local function update_action_values(battle)
	local offset = -1

	for k, v in ipairs(battle.actors) do
		if v.HP > 0 and v.action_number < offset or offset == -1 then
			offset = v.action_number
		end
	end

	for k, v in ipairs(battle.actors) do
		v.action_number = v.action_number - offset
	end
end

---@param battle BattleState
local function sort_battle(battle)
	table.sort(battle.actors, function (a, b)
		if (b.HP == 0 and a.HP == 0) then
			return a.definition.name < b.definition.name
		end
		if (b.HP == 0) then
			return true
		end
		if (a.HP == 0) then
			return false
		end
		return a.action_number < b.action_number
	end)

	for index, value in ipairs(battle.actors) do
		value.battle_order = index
	end
end

---comment
---@param battle BattleState
---@param actor Actor
---@param was_in_battle boolean
function manager.add_actor_to_battle(battle, actor, was_in_battle)
	assert(battle.in_progress)

	print("adding new actor to battle:", actor.definition.name)

	local max_action_number = 0
	if not was_in_battle then
		for k, v in ipairs(battle.actors) do
			if v.action_number > max_action_number and v.HP > 0 then
				max_action_number = v.action_number
			end
		end
	end

	actor.action_number = math.floor(max_action_number * 0.5) + SPEED_TO_ACTION_OFFSET(actor.definition.SPD)
	print("new action number:", actor.action_number)
	table.insert(battle.actors, actor)
	sort_battle(battle)

	if (not was_in_battle) then
		---@type Effect
		local effect = {
			data = {},
			def = require "effects.enter_battle",
			origin = actor,
			target = actor,
			started = false,
			time_passed = 0,
			times_activated = 0
		}

		table.insert(battle.effects_queue, effect)
		print(#battle.effects_queue)
	end
end



---@param state GameState
---@param battle BattleState
---@param do_not_remove_first_actor boolean
---@return BATTLE_SYSTEM_RESPONSE
function manager.process_turn(state, battle, do_not_remove_first_actor)
	print("process turn")

	local can_proceed = do_not_remove_first_actor
	while not can_proceed do
		local actor = battle.actors[1]
		table.remove(battle.actors, 1)
		if actor.HP > 0 then
			print("readd to battle:" .. actor.definition.name)
			manager.add_actor_to_battle(battle, actor, true)
			can_proceed = true
		end
	end

	update_action_values(battle)
	sort_battle(battle)

	-- queue all effects on new current character
	if (battle.actors[1]) then
		ON_TURN_START(state, battle, battle.actors[1])
	end

	battle.stage = BATTLE_STAGE.PROCESS_EFFECTS_BEFORE_TURN

	return BATTLE_SYSTEM_RESPONSE.OK
end

---@param state GameState
---@param battle BattleState
---@param dt number
---@return BATTLE_SYSTEM_RESPONSE
local function process_before_turn(state, battle, dt)
	if update_effects(state, battle, dt) then
		battle.stage = BATTLE_STAGE.AWAIT_TURN
	end

	return BATTLE_SYSTEM_RESPONSE.OK
end

---@param state GameState
---@param battle BattleState
local function battle_lost(state, battle)
	local result = true
	for key, value in ipairs(battle.actors) do
		if value.team == 0 and (value.HP_view == nil or value.HP_view > 0) then
			result = false
		end
	end

	return result
end


---@param state GameState
---@param battle BattleState
function manager.stop_battle(state, battle)
	clear(battle.actors)
	clear(battle.effects_queue)
	battle.in_progress = false
	battle.selected_actor = nil
	battle.wave = 1
	battle.stage = BATTLE_STAGE.STOPPED
end

---@param state GameState
---@param battle BattleState
function manager.start_battle(state, battle)
	clear(battle.actors)
	clear(battle.effects_queue)
	battle.in_progress = true
	battle.selected_actor = nil
	battle.wave = 1
	battle.stage = BATTLE_STAGE.NEW_WAVE
end

---@param state GameState
---@param battle BattleState
function manager.begin_new_wave(state, battle)
	battle.stage = BATTLE_STAGE.NEW_WAVE
	battle.selected_actor = nil
end

---@param state GameState
---@param battle BattleState
local function enemies_exist(state, battle)
	local result = false;
	for key, value in ipairs(battle.actors) do
		if value.team == 1 and (value.HP_view == nil or value.HP_view > 0) then
			result = true
		end
	end

	return result
end

---comment
---@param state GameState
---@param battle BattleState
---@param skill ActiveSkill
local function get_skill_target(state, battle, skill)
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
	return potential_targets[index]
end

---comment
---@param state GameState
---@param battle BattleState
local function update_ai_turn(state, battle)
	---@type number?
	local target_index = 0

	local used_skill = battle.actors[1].definition.inherent_skills[1]
	if used_skill.targeted then
		target_index = get_skill_target(state, battle, used_skill)
	end

	if target_index == 0 and used_skill.targeted then
		return
	end

	local origin = battle.actors[1]
	local target = battle.actors[target_index]
	USE_SKILL(state, battle, origin, target, used_skill)
end

---@param state GameState
---@param battle BattleState
---@return BATTLE_SYSTEM_RESPONSE
local function process_await_turn(state, battle)
	if battle_lost(state, battle) then
		return BATTLE_SYSTEM_RESPONSE.BATTLE_LOST
	end

	if not enemies_exist(state, battle) then
		return BATTLE_SYSTEM_RESPONSE.REQUEST_NEW_WAVE
	end

	local current_actor = battle.actors[1]
	if current_actor.team == 1 and current_actor.HP > 0 then
		update_ai_turn(state, battle)
		battle.stage = BATTLE_STAGE.PROCESS_EFFECTS_AFTER_TURN
		return BATTLE_SYSTEM_RESPONSE.OK
	end

	return BATTLE_SYSTEM_RESPONSE.AWAIT_USER_INPUT
end

---@param battle BattleState
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

---@param state GameState
---@param battle BattleState
---@param dt number
---@return BATTLE_SYSTEM_RESPONSE
function manager.update_battle_state(state, battle, dt)
	if battle.selected_actor == nil then
		update_selection(battle)
	elseif battle.selected_actor.HP <= 0 or not battle.selected_actor.visible then
		update_selection(battle)
	end

	if battle.stage == BATTLE_STAGE.NEW_WAVE then
		return process_new_wave(state, battle, dt)
	end

	if battle.stage == BATTLE_STAGE.PROCESS_EFFECTS_AFTER_TURN then
		return process_after_turn(state, battle, dt)
	end

	if battle.stage == BATTLE_STAGE.PROCESS_TURN then
		return manager.process_turn(state, state.last_battle, false)
	end

	if battle.stage == BATTLE_STAGE.PROCESS_EFFECTS_BEFORE_TURN then
		return process_before_turn(state, battle, dt)
	end

	if battle.stage == BATTLE_STAGE.AWAIT_TURN then
		return process_await_turn(state, battle)
	end

	return BATTLE_SYSTEM_RESPONSE.ERROR
end


local available_id = 0
local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

---comment
---@param def MetaActor
---@param pos number
---@param team number
---@param wrapper MetaActorWrapper|nil
function manager.new_actor(def, pos, team, wrapper)
	---@type Actor
	local temp = {
		HP = TOTAL_MAX_HP(def, wrapper),
		SHIELD = 0,
		action_number = 0,
		definition = def,
		pending_damage = {},
		pos = pos,
		status_effects = {},
		team = team,
		x = 0,
		y = 0,
		visible = false,
		wrapper = wrapper,
		energy = def.max_energy,
		battle_id = available_id,
		battle_order = 0,
		w = 0,
		h = 0,
	}

	available_id = available_id + 1

	temp.x = get_x(temp)
	temp.y = get_y(temp)

	return temp
end

---comment
---@param state GameState
function manager.put_player_into_battle(state)
	for i = 1, 4 do
		if state.current_lineup[i] ~= 0 then
			local wrapper = state.playable_actors[state.current_lineup[i]]
			local def = wrapper.def
			local actor = manager.new_actor(def, i, 0, wrapper)
			manager.add_actor_to_battle(state.last_battle, actor, false)
		end
	end
end

return manager