local ids = require "scenes._ids"
local battles_manager = require "fights._battle-system"

---comment
---@param state GameState
---@param def MetaActor
---@param factions FACTION[]
---@return MetaActorWrapper, number, number
local function register_actor(
	state,
	def,
	factions, x, y
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
		dead = false,
		actor_index = 0
	}

	table.insert(state.playable_actors, added)

	local index = #state.playable_actors

	for _, value in ipairs(factions) do
		if value == FACTION.CITY_GUARD then
			table.insert(state.available_guards, index)
		end
	end

	state.current_guard = state.available_guards[1]

	table.insert(state.actors, require "effects-campaign.create-actor-table"(def, added, x, y))
	added.actor_index = #state.actors

	return state.playable_actors[index], index, added.actor_index
end


---@class LocationData
---@field image_day love.Image
---@field image_night love.Image
---@field x number
---@field y number
---@field movement_mask love.ImageData

---@param filename string
---@return LocationData
local function load_location_data(filename)
	local image_day = love.graphics.newImage(string.format("assets/locations/%s/day.png", filename))
	local image_night = love.graphics.newImage(string.format("assets/locations/%s/night.png", filename))
	local mask  = love.image.newImageData(string.format("assets/locations/%s/mask.png", filename))
	local x, y = image_day:getDimensions()
	return {
		image_day = image_day,
		image_night = image_night,
		x = x,
		y = y,
		movement_mask = mask
	}
end

---@param state GameState
return function (state)

	state.location_data = {}
	state.location_data[LOCATION.AT_CITY_GATES] = load_location_data("at_gates")

	require "scripting.instructions._load_instruction_set"(state)
	require "scripting.instructions._load_instruction_stack"(state)

	state.turn_stage = TURN_STAGE.AWAIT_INPUT

	state.playable_actors = {}
	state.currency = 5
	state.set_scene(state, ids.location)
	state.current_dialog_actor = nil
	state.available_guards = {}
	state.current_guard = 1
	state.current_time =0
	state.actors = {}

	state.tile_lock = {}
	for i = 0, 500, 1 do
		state.tile_lock[i] = {}
		for j = 0, 500, 1 do
			state.tile_lock[i][j] = false
		end
	end

	state.command_buffer = {}
	state.command_buffer_left = 0
	state.command_buffer_right = 0
	state.command_buffer_size = 4048

	state.effects_queue = {}

	state.options_state = OPTIONS_STATE.NONE

	state.current_text = "Finally, you have arrived to the gates. A lone watchman guards the gates while a small caravan stays nearby."

	local main_character, gg_index, gg_actor_index = register_actor(
		state,
		require "meta-actors.main-character",
		{}, 230, 230
	)
	main_character.lineup_position = 1
	main_character.trust = 100
	state.main_character_actor = gg_actor_index
	state.main_character = gg_index

	local caravan_master, caravan_master_index = register_actor(
		state,
		require "meta-actors.caravan-master",
		{}, 330, 180
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
		{FACTION.CITY_GUARD}, 180, 120
	)
	font.location = LOCATION.AT_CITY_GATES
	font.occupation = OCCUPATION_TYPE.GUARD

	local fire_mage = register_actor(
		state,
		require "meta-actors.fire-mage",
		{FACTION.MAGE_GUILD}, 100, 100
	)

	local healer = register_actor(
		state,
		require "meta-actors.basic-healer",
		{FACTION.MAGE_GUILD}, 100, 100
	)

	local forest_guard, forest_guard_index = register_actor (
		state,
		require "meta-actors.guard-forest",
		{FACTION.MERCENARIES}, 100, 100
	)
	state.forest_guard =forest_guard_index
	forest_guard.location = LOCATION.ESTATE_LORD_B_GUARDHOUSE_NEAR_FOREST

	local great_mage, qq = register_actor(
		state,
		require "meta-actors.trong",
		{FACTION.MAGE_GUILD}, 100, 100
	)
	great_mage.lineup_position = 3

	local poisoner, poisoner_index = register_actor(
		state,
		require "meta-actors.flower",
		{FACTION.HIGHWAY_JESTERS}, 100, 100
	)
	poisoner.location = LOCATION.FOREST_VILLAGE
	poisoner.occupation = OCCUPATION_TYPE.FOREST_VILLAGER
	state.village_girl = poisoner_index

	local poisoner_2, poisoner_2_index = register_actor(
		state,
		require "meta-actors.chud",
		{FACTION.HIGHWAY_JESTERS}, 100, 100
	)
	poisoner_2.location = LOCATION.FOREST_VILLAGE
	poisoner_2.occupation = OCCUPATION_TYPE.FOREST_VILLAGE_ELDER
	state.village_elder = poisoner_2_index

	local light_master, q = register_actor(
		state,
		require "meta-actors.rebe",
		{FACTION.ORDER_OF_LIGHT}, 100, 100
	)
	light_master.lineup_position = 2

	local blood_mage = register_actor(
		state,
		require "meta-actors.mohi",
		{FACTION.ROGUE_MAGES}, 100, 100
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
end