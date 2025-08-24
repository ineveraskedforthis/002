local scenes_manager = require "scenes._manager"

---@class GameState
---@field current_lineup number[]
---@field selected_lineup_position number
---@field playable_actors MetaActorWrapper[]
---@field collected_gemstones GemstoneWrapper[]
---@field currency number
---@field current_scene number
---@field current_scripted_fight SCRIPTED_BATTLE
---@field last_battle Battle
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
		stage = require "state.battle".BATTLE_STAGE.PROCESS_EFFECTS_BEFORE_TURN,
		wave = 1
	},
	playable_actors = {},
	vfx = require "scenes._vfx_manager"
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
	print("Enter scene:", def.name)
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