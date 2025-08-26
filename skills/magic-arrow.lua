---@type ActiveSkill
return {
	name = "Magic Arrow",
	description = function (actor)
		return "Deals a bit of damage to target"
	end,
	on_skill_used_sequence = {
		require "effects.magic-arrow"
	},
	targeted = true,
	required_strength = 0,
	required_magic = 10,
	required_elements = {},
	cost = 5,
	allowed_weapons = {},
	required_energy = 1,
	is_attack = true
}