local scenes_manager = require "scenes._manager"

--@class MetaActorIndex
--@field value number
--@field index_brand_ nil

---@enum OPTIONS_STATE
OPTIONS_STATE = {
	NONE = 0,
	MOVE = 1,
	TALK = 2
}

---@enum BATTLE_RESULT
BATTLE_RESULT = {
	DEFEAT = 0,
	VICTORY = 1,
	DRAW = 2
}

DAY_PART_LENGTH = 3
DAY_SEGMENTS = 4
DAY_SEGMENT_LENGTH = 100
DAY_LENGTH = DAY_PART_LENGTH * DAY_SEGMENTS

function TIME_STRING (time)
	local modulo_day = math.floor(time / DAY_SEGMENT_LENGTH) % DAY_LENGTH
	local day_part = math.floor(modulo_day / DAY_PART_LENGTH)
	local day_part_segment = modulo_day % DAY_PART_LENGTH
	local name = "Night"
	if day_part == 1 then
		name = "Morning"
	elseif day_part == 2 then
		name = "Day"
	elseif day_part == 3 then
		name = "Evening"
	end
	local modifier = "Early"
	if day_part_segment == 1 then
		modifier = "Mid"
	elseif day_part_segment == 2 then
		modifier = "Late"
	end
	return string.format("%s %s", modifier, name)
end

---@alias InstructionDefinition fun(state : GameState, frame: RegisterFrame, dt: number, arg1, arg2, arg3) : boolean, boolean

---@enum TURN_STAGE
TURN_STAGE = {
	AWAIT_INPUT = 1,
	RUN_INTERPRETER = 2
}

---@class GameState
---@field selected_lineup_position number
---@field playable_actors MetaActorWrapper[]
---@field actors Actor[]
---@field main_character number
---@field main_character_actor number
---@field current_text string
---@field available_guards number[]
---@field current_guard number
---@field caravan_master number
---@field village_elder number
---@field village_girl number
---@field forest_guard number
---@field current_dialog_actor number?
---@field options_state OPTIONS_STATE
---@field collected_gemstones GemstoneWrapper[]
---@field currency number
---@field current_scene number
---@field die_on_battle_lost boolean
---@field vfx ManagerVFX
---@field current_time number
---@field programs table<PROGRAM, number>
---@field instruction_stack ParsedInstruction[]
---@field instruction_stack_top number
---@field command_buffer RegisterFrame[]
---@field command_buffer_left number
---@field command_buffer_right number
---@field command_buffer_size number
---@field instruction_set table<number, InstructionDefinition>
---@field tile_lock boolean[][]
---@field effects_queue Effect[]
---@field turn_stage TURN_STAGE
---@field location_data table<LOCATION, LocationData>
local state = {
	currency = 0,
	current_scene = 0,
	playable_actors = {},
	current_location_x = 0,
	current_location_y = 0,
	wandering = false,
	vfx = require "scenes._vfx_manager",
	story_atoms = {},
	options_state = OPTIONS_STATE.NONE,
	last_battle_awaits_topic_resolution = false,
	last_battle_result = BATTLE_RESULT.DRAW,
	current_time = 0
}


function state.load()
	assert(false)
end

function state.save()
	assert(false)
end

---comment
---@param state GameState
---@param scene number
function state.set_scene(state, scene)
	local def = scenes_manager.get(scene)
	print("Enter scene:\n", def.name)
	state.current_scene = scene
end

---@param state GameState
---@param actor_index number
---@param gemstone_index number
function state.set_gemstone_owner(state, actor_index, gemstone_index)
	-- remove from old owner if it exists
	local gemstone = state.collected_gemstones[gemstone_index]
	local old_owner = gemstone.actor
	if old_owner ~= 0 then
		-- find gemstone and remove it
		local id = 0
		for index, value in ipairs(state.playable_actors[old_owner].gemstones) do
			if value == gemstone_index then
				id = index
			end
		end
		if id ~= 0 then
			table.remove(state.playable_actors[old_owner].gemstones, id)
		end
	end

	gemstone.actor = actor_index

	if actor_index == 0 then
		return
	end
	local actor = state.playable_actors[actor_index]
	table.insert(actor.gemstones, gemstone_index)
end

return state