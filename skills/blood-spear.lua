---@type ActiveSkill
return {
	name = "Blood spear",
	description = function (actor)
		return "Deals massive damage to target while consuming actor's HP"
	end,
	effects_sequence = {
		require "effects.blood-spear"
	},
	targeted = true,
	required_strength = 0,
	required_magic = 30,
	required_elements = {ELEMENT.BLOOD},
	cost = 5,
	allowed_weapons = {},
	required_energy = 0
}