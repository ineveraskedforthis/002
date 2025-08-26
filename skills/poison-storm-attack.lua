local attack = require "effects.poison-attack"

---@type ActiveSkill
return {
	name = "Poison flurry",
	description = function (actor)
		return "Attack the target enemy 5 times"
	end,
	on_skill_used_sequence = {
		require "effects.move_to_target",
		attack, attack, attack, attack, attack,
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 15,
	required_magic = 0,
	required_elements = {ELEMENT.CHAOS},
	cost = 2,
	allowed_weapons = {{weapon = WEAPON.DAGGER, mastery = 1}},
	required_energy = 4,
	is_attack = true
}