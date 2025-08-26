---@type ActiveSkill
return {
	name = "Flicker strike",
	description = function (actor)
		return "Jump around and deal damage"
	end,
	on_skill_used_sequence = {
		require "effects.flicker-strike",
	},
	targeted = true,
	required_strength = 10,
	required_magic = 25,
	required_elements = {ELEMENT.LIGHT},
	cost = 5,
	allowed_weapons = {{weapon = WEAPON.SWORD, mastery = 1}},
	required_energy = 5,
	is_attack = true
}
