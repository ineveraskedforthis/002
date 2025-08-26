local attack = require "effects.basic_attack"

---@type ActiveSkill
return {
	name = "Counter Attack",
	description = function (actor)
		return "Attack enemy which attempted to attack you"
	end,
	on_being_attacked_sequence = {
		require "effects.move_to_target",
		attack,
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 15,
	required_magic = 0,
	required_elements = {},
	cost = 5,
	allowed_weapons = {{weapon = WEAPON.SWORD, mastery = 1}, {weapon = WEAPON.DAGGER, mastery = 1}},
	required_energy = 0,
	is_attack = true
}