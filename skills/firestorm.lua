---@type ActiveSkill
return {
	name = "Firestorm",
	description = function (actor)
		return "Deals a lot of aoe damage"
	end,
	effects_sequence = {
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage",
		require "effects.firestorm-stage"
	},
	targeted = true,
	required_strength = 0,
	required_magic = 50,
	required_elements = {ELEMENT.FIRE},
	cost = 75
}