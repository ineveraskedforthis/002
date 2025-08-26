local attack = require "effects.poison-strike"

---@type ActiveSkill
return {
	name = "Explode poison",
	description = function (actor)
		return "Explodes all poison applied to enemy"
	end,
	on_skill_used_sequence = {
		require "effects.move_to_target",
		attack,
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 15,
	required_magic = 5,
	required_elements = {ELEMENT.CHAOS},
	cost = 10,
	allowed_weapons = {{weapon = WEAPON.DAGGER, mastery = 0}, {weapon = WEAPON.SWORD, mastery = 0}},
	required_energy = 4,
	is_attack = true
}