local ids = require "scenes._ids"

---@param state GameState
return function (state)
	state.currency = 5
	state.set_scene(state, ids.select_battle)

	state.playable_actors = {
		{
			def = require "meta-actors.main-character",
			unlocked = true,
			lineup_position = 1,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.chud",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 10,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.basic-healer",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.fire-mage",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.rebe",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		},
		{
			def = require "meta-actors.mohi",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {}
		}
	}

	---@type GemstoneWrapper[]
	state.collected_gemstones = {
		{
			actor = 0,
			def = require "gemstones.scavenger"
		}
	}

	state.set_gemstone_owner(state, 1, 1)

	state.current_lineup = {
		1,
		0,
		0,
		0
	}
end