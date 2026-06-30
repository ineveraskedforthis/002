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

DAY_LENGTH = 24

---@class GameState
---@field current_lineup number[]
---@field selected_lineup_position number
---@field playable_actors MetaActorWrapper[]
---@field main_character number
---@field current_text string
---@field available_guards number[]
---@field current_guard number
---@field caravan_master number
---@field village_elder number
---@field current_dialog_actor number?
---@field options_state OPTIONS_STATE
---@field collected_gemstones GemstoneWrapper[]
---@field currency number
---@field current_scene number
---@field current_scripted_fight SCRIPTED_BATTLE
---@field current_location_x number
---@field current_location_y number
---@field last_battle BattleState
---@field wandering boolean
---@field enemy_pack EnemyPack?
---@field current_story_atom string
---@field last_battle_result BATTLE_RESULT
---@field last_battle_awaits_topic_resolution boolean
---@field die_on_battle_lost boolean
---@field vfx ManagerVFX
local state = {
	currency = 0,
	current_lineup = {},
	current_scene = 0,
	last_battle = {
		actors = {},
		await_turn = false,
		effects_queue = {},
		in_progress = false,
		processing_effects = false,
		selected_actor = nil,
		stage = require "fights._stages".STOPPED,
		wave = 1
	},
	playable_actors = {},
	current_location_x = 0,
	current_location_y = 0,
	wandering = false,
	current_story_atom = "invalid",
	vfx = require "scenes._vfx_manager",
	story_atoms = {},
	options_state = OPTIONS_STATE.NONE,
	last_battle_awaits_topic_resolution = false,
	last_battle_result = BATTLE_RESULT.DRAW
}

---comment
---@param state GameState
---@param atom string
function SET_STORY_ATOM(state, atom)
	state.current_story_atom = atom
	if (state.story_atoms[state.current_story_atom] == nil) then
		print("UNKNOWN STORY ATOM:", atom)
	end
	if state.story_atoms[state.current_story_atom].initial_effect then
		state.story_atoms[state.current_story_atom].initial_effect(state, state.playable_actors[state.current_dialog_actor])
	end
end

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