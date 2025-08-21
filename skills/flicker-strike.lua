return {
	name = "Flicker strike",
	description = function (actor)
		return "Jump around and deal damage"
	end,
	effects_sequence = {
		require "effects.flicker-strike",
		require "effects.move_to_original_position"
	},
	targeted = true,
	required_strength = 10,
	required_magic = 25,
	required_elements = {ELEMENT.LIGHT},
	cost = 5,
	allowed_weapons = {WEAPON.SWORD}
}
