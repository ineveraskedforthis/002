---@type ActiveSkill
return {
	name = "Shield",
	description = function (actor)
		return "Apply shield to allies"
	end,
	effects_sequence = {
		require "effects.shield_random_ally",
		require "effects.shield_random_ally",
		require "effects.shield_random_ally",
	},
	targeted = false,
	required_elements = {ELEMENT.PROTECTION},
	required_magic = 10,
	required_strength = 10,
	cost = 10,
	allowed_weapons = {}
}