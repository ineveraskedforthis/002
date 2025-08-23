local attack = require "effects.basic_attack"

---@type ActiveSkill
return {
	name = "Attack",
	description = function (actor)
		return "Attack the target enemy"
	end,
	effects_sequence = {
		require "effects.move_to_target",
		attack, attack,
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 5,
	required_magic = 0,
	required_elements = {},
	cost = 2,
	allowed_weapons = {},
	required_energy = 0,
}