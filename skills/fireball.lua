---@type ActiveSkill
return {
	name = "Fireball",
	description = function (actor)
		return "Deals aoe damage"
	end,
	on_skill_used_sequence = {
		require "effects.fireball"
	},
	targeted = true,
	required_strength = 0,
	required_magic = 20,
	required_elements = {ELEMENT.FIRE},
	cost = 5,
	allowed_weapons = {},
	required_energy = 3,
	is_attack = true
}