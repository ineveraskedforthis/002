---@type ActiveSkill
return {
	name = "Fireball",
	description = function (actor)
		return "Deals damage"
	end,
	effects_sequence = {
		require "effects.fireball"
	},
	targeted = true,
	required_strength = 0,
	required_magic = 20,
	required_elements = {ELEMENT.FIRE},
	cost = 2
}