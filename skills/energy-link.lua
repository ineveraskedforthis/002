---@type ActiveSkill
return {
	name = "Energy link",
	description = function (actor)
		return "Launch a link which damages target and jumps in random directions. Restore energy on killing enemy"
	end,
	on_skill_used_sequence = {
		require "effects.energy-link"
	},
	targeted = true,
	required_strength = 0,
	required_magic = 30,
	required_elements = {ELEMENT.ELECTRO},
	cost = 5,
	allowed_weapons = {},
	required_energy = 6,
	is_attack = true
}
