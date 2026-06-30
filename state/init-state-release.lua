local ids = require "scenes._ids"
local battles_manager = require "fights._battle-system"

---comment
---@param state GameState
---@param def MetaActor
---@param factions FACTION[]
---@return MetaActorWrapper, number
local function register_actor(
	state,
	def,
	factions
)
	---@type MetaActorWrapper
	local added = {
		def = def,
		unlocked = true,
		lineup_position = 0,
		experience = 0,
		additional_weapon_mastery = 0,
		level = 0,
		skill_points = 0,
		skills = {},
		gemstones = {},
		trust = 0,
		factions = factions,
		location = LOCATION.CITY,
		occupation = OCCUPATION_TYPE.NONE,
		wares = {},
		additional_MAG = 0,
		dead = false
	}

	table.insert(state.playable_actors, added)

	local index = #state.playable_actors

	for _, value in ipairs(factions) do
		if value == FACTION.CITY_GUARD then
			table.insert(state.available_guards, index)
		end
	end

	state.current_guard = state.available_guards[1]

	return state.playable_actors[index], index
end

---@param state GameState
return function (state)
	state.playable_actors = {}
	state.currency = 5
	state.set_scene(state, ids.dialog)
	state.current_dialog_actor = nil
	SET_STORY_ATOM(state, "game_start")
	state.last_battle.wave = 1
	state.available_guards = {}
	state.current_guard = 1
	state.current_time =0

	state.options_state = OPTIONS_STATE.NONE

	state.current_text = "Finally, you have arrived to the gates. A lone watchman guards the gates while a small caravan stays nearby."

	battles_manager.stop_battle(state, state.last_battle)

	local main_character, gg_index = register_actor(
		state,
		require "meta-actors.main-character",
		{}
	)
	main_character.lineup_position = 1
	main_character.trust = 100
	state.main_character = gg_index

	local caravan_master, caravan_master_index = register_actor(
		state,
		require "meta-actors.caravan-master",
		{}
	)
	state.caravan_master = caravan_master_index
	caravan_master.location = LOCATION.AT_CITY_GATES
	caravan_master.occupation = OCCUPATION_TYPE.MERCHANT
	caravan_master.wares[1] = {
		amount = 10,
		commodity = COMMODITY.LUXURY_CLOTH,
		price = 10
	}

	local font = register_actor(
		state,
		require "meta-actors.font",
		{FACTION.CITY_GUARD}
	)
	font.location = LOCATION.AT_CITY_GATES
	font.occupation = OCCUPATION_TYPE.GUARD

	local fire_mage = register_actor(
		state,
		require "meta-actors.fire-mage",
		{FACTION.MAGE_GUILD}
	)

	local healer = register_actor(
		state,
		require "meta-actors.basic-healer",
		{FACTION.MAGE_GUILD}
	)

	local forest_guard, forest_guard_index = register_actor (
		state,
		require "meta-actors.guard-forest",
		{FACTION.MERCENARIES}
	)
	state.forest_guard =forest_guard_index
	forest_guard.location = LOCATION.ESTATE_LORD_B_GUARDHOUSE_NEAR_FOREST

	local great_mage, qq = register_actor(
		state,
		require "meta-actors.trong",
		{FACTION.MAGE_GUILD}
	)
	great_mage.lineup_position = 3

	local poisoner, poisoner_index = register_actor(
		state,
		require "meta-actors.flower",
		{FACTION.HIGHWAY_JESTERS}
	)
	poisoner.location = LOCATION.FOREST_VILLAGE
	poisoner.occupation = OCCUPATION_TYPE.FOREST_VILLAGER
	state.village_girl = poisoner_index

	local poisoner_2, poisoner_2_index = register_actor(
		state,
		require "meta-actors.chud",
		{FACTION.HIGHWAY_JESTERS}
	)
	poisoner_2.location = LOCATION.FOREST_VILLAGE
	poisoner_2.occupation = OCCUPATION_TYPE.FOREST_VILLAGE_ELDER
	state.village_elder = poisoner_2_index

	local light_master, q = register_actor(
		state,
		require "meta-actors.rebe",
		{FACTION.ORDER_OF_LIGHT}
	)
	light_master.lineup_position = 2

	local blood_mage = register_actor(
		state,
		require "meta-actors.mohi",
		{FACTION.ROGUE_MAGES}
	)

	--[[
	---@type GemstoneWrapper[]
	state.collected_gemstones = {
		{
			actor = 0,
			def = require "gemstones.scavenger"
		},
		{
			actor = 0,
			def = require "gemstones.stoneheart"
		}
	}

	state.set_gemstone_owner(state, 1, 1)
	state.set_gemstone_owner(state, 1, 2)
	--]]

	state.current_lineup = {
		1,
		0,
		0,
		0
	}
end