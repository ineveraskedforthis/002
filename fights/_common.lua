local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

---comment
---@param def MetaActor
---@param pos number
---@param team number
---@param wrapper MetaActorWrapper|nil
function GENERATE_ACTOR(def, pos, team, wrapper)
	---@type Actor
	local temp = {
		HP = def.MAX_HP,
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
		wrapper = wrapper
	}

	temp.x = get_x(temp)
	temp.y = get_y(temp)

	return temp
end

function PLAYER_ENTER_BATTLE()
	for i = 1, 4 do
		if CHARACTER_LINEUP[i] ~= 0 then
			local wrapper = PLAYABLE_META_ACTORS[CHARACTER_LINEUP[i]]
			local def = wrapper.def
			ENTER_BATTLE(GENERATE_ACTOR(def, i, 0, wrapper), 0, false)
		end
	end
end

function RESET_BATTLE()
	---@type Actor[]
	BATTLE = {}
	---@type Effect[]
	EFFECTS_QUEUE = {}
	---@type Effect[]
	STATUS_EFFECT_QUEUE = {}
	SELECTED = nil
end

function SORT_BATTLE()
	table.sort(BATTLE, function (a, b)
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
end

---comment
---@param actor Actor
---@param team number
---@param was_in_battle boolean
function ENTER_BATTLE(actor, team, was_in_battle)
	local max_action_number = 0
	if not was_in_battle then
		for k, v in ipairs(BATTLE) do
			if v.action_number > max_action_number and v.HP > 0 then
				max_action_number = v.action_number
			end
		end
	end

	actor.action_number = math.floor(max_action_number * 0.5) + SPEED_TO_ACTION_OFFSET(actor.definition.SPD)
	actor.team = team
	table.insert(BATTLE, actor)
	SORT_BATTLE()

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

		table.insert(EFFECTS_QUEUE, effect)
	end
end

