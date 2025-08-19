return {
	name = "Shield",
	description = function (actor)
		return "Apply shield to the target"
	end,
	effects_sequence = {
		require "effects.shield_random_ally",
		require "effects.shield_random_ally",
		require "effects.shield_random_ally",
		require "effects.shield_random_ally",
		require "effects.shield_random_ally"
	},
	targeted = false
}