---@type ActiveSkill
return {
	name = "Light poison",
	description = function (actor)
		return "Enemy starts taking damage over time"
	end,
	effects_sequence = {
		require "effects.apply_dot"
	},
	targeted = true,
	required_strength = 10,
	required_magic = 10,
	required_elements = {ELEMENT.CHAOS},
	cost = 5,
	allowed_weapons = {}
}