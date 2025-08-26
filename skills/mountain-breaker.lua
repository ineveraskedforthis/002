local attack = require "effects.strong-attack"

---@type ActiveSkill
return {
	name = "Mountain Breaker",
	description = function (actor)
		return "Deal massive damage to enemy"
	end,
	on_skill_used_sequence = {
		require "effects.move_to_target",
		attack,
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 15,
	required_magic = 0,
	required_elements = {},
	cost = 2,
	allowed_weapons = {{weapon = WEAPON.SWORD, mastery = 1}},
	required_energy = 5,
	is_attack = true
}