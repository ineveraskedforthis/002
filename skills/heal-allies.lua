return {
	name = "Heal allies",
	description = function (actor)
		return "Heal all allies"
	end,
	effects_sequence = {
		require "effects.heal_allies",
	},
	targeted = false,
	required_strength = 0,
	required_magic = 10,
	required_elements = {ELEMENT.RESTORATION}
}