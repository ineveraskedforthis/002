---@type ActiveSkill
return {
	name = "Heal allies",
	description = function (actor)
		return "Heal all allies"
	end,
	on_skill_used_sequence = {
		require "effects.heal_allies",
	},
	targeted = false,
	required_strength = 0,
	required_magic = 10,
	required_elements = {ELEMENT.RESTORATION},
	cost = 5,
	allowed_weapons = {},
	required_energy = 1,
	is_attack = false
}