local attack = require "effects.poison-attack"

---@type ActiveSkill
return {
	name = "Poison attack",
	description = function (actor)
		return "Attack the target enemy"
	end,
	on_skill_used_sequence = {
		require "effects.move_to_target",
		attack,
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 15,
	required_magic = 0,
	required_elements = {ELEMENT.CHAOS},
	cost = 2,
	allowed_weapons = {{weapon = WEAPON.DAGGER, mastery = 0}, {weapon = WEAPON.SWORD, mastery = 0}},
	required_energy = 0,
	is_attack = true
}