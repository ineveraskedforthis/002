---@type ActiveSkill
return {
	name = "Flame sweep",
	description = function (actor)
		return "Strikes all enemies"
	end,
	on_skill_used_sequence = {
		require "effects.move_to_target",
		require "effects.flame-sweep",
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 30,
	required_magic = 15,
	required_elements = {},
	cost = 5,
	allowed_weapons = {{weapon = WEAPON.SWORD, mastery = 0}},
	required_energy = 3,
	is_attack = true
}
