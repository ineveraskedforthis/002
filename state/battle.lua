local clear = require "table.clear"

local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

---@class Battle
---@field actors Actor[]
---@field effects_queue Effect[]
---@field selected_actor Actor?
---@field in_progress boolean
---@field wave number
---@field stage BATTLE_STAGE


local namespace = {}

---comment
---@param battle Battle
function namespace.reset_battle(battle)
	clear(battle.actors)
	clear(battle.effects_queue)
	battle.selected_actor = nil
	battle.in_progress = false
	battle.stage = namespace.BATTLE_STAGE.PROCESS_TURN
end

local available_id = 0

---comment
---@param def MetaActor
---@param pos number
---@param team number
---@param wrapper MetaActorWrapper|nil
function namespace.new_actor(def, pos, team, wrapper)
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
function namespace.put_player_into_battle(state)
	for i = 1, 4 do
		if state.current_lineup[i] ~= 0 then
			local wrapper = state.playable_actors[state.current_lineup[i]]
			local def = wrapper.def
			local actor = namespace.new_actor(def, i, 0, wrapper)
			namespace.add_actor_to_battle(state.last_battle, actor, false)
		end
	end
end

---@param battle Battle
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
---@param battle Battle
---@param actor Actor
---@param was_in_battle boolean
function namespace.add_actor_to_battle(battle, actor, was_in_battle)
	assert(battle.in_progress)

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
	end
end

---@param battle Battle
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

---@param state GameState
---@param battle Battle
function namespace.process_turn(state, battle)
	local can_proceed = false
	while not can_proceed do
		---@type Actor
		local actor = table.remove(battle.actors, 1)
		if actor.HP > 0 then
			print("readd to battle:" .. actor.definition.name)
			namespace.add_actor_to_battle(battle, actor, true)
			can_proceed = true
		end
	end

	update_action_values(battle)
	sort_battle(battle)

	-- queue all effects on new current character
	if (battle.actors[1]) then
		ON_TURN_START(state, battle, battle.actors[1])
	end
end

---@enum BATTLE_STAGE
namespace.BATTLE_STAGE = {
	PROCESS_EFFECTS_BEFORE_TURN = 1,
	AWAIT_TURN = 2,
	PROCESS_EFFECTS_AFTER_TURN = 3,
	PROCESS_TURN = 4
}

return namespace