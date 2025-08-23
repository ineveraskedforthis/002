---@type ActiveSkill
return {
	name = "Flame sweep",
	description = function (actor)
		return "Strikes all enemies"
	end,
	effects_sequence = {
		require "effects.move_to_target",
		require "effects.flame-sweep",
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 30,
	required_magic = 15,
	required_elements = {},
	cost = 5,
	allowed_weapons = {WEAPON.SWORD},
	required_energy = 3
}
