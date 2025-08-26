---@type ActiveSkill
return {
	name = "Light poison",
	description = function (actor)
		return "Enemy starts taking damage over time"
	end,
	on_skill_used_sequence = {
		require "effects.apply_dot"
	},
	targeted = true,
	required_strength = 5,
	required_magic = 10,
	required_elements = {ELEMENT.CHAOS},
	cost = 5,
	allowed_weapons = {},
	required_energy = 1,
	is_attack = true
}