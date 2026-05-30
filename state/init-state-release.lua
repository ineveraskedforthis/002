local ids = require "scenes._ids"
local battles_manager = require "fights._battle-system"

---@param state GameState
return function (state)
	state.currency = 5
	state.set_scene(state, ids.dialog)
	state.current_dialog_actor = 9
	state.current_story_atom = "greeting"
	state.last_battle.wave = 1
	battles_manager.stop_battle(state, state.last_battle)

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
			gemstones = {},
			trust = 100
		},
		{
			def = require "meta-actors.chud",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {},
			trust = 0
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
			gemstones = {},
			trust = 0
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
			gemstones = {},
			trust = 0
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
			gemstones = {},
			trust = 0
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
			gemstones = {},
			trust = 0
		},
		{
			def = require "meta-actors.trong",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {},
			trust = 0
		},
		{
			def = require "meta-actors.flower",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {},
			trust = 0
		},
		{
			def = require "meta-actors.font",
			unlocked = false,
			lineup_position = 0,
			experience = 0,
			additional_weapon_mastery = 0,
			level = 0,
			skill_points = 0,
			skills = {},
			gemstones = {},
			trust = 0
		},
	}

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

	state.current_lineup = {
		1,
		0,
		0,
		0
	}
end