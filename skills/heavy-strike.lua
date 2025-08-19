return {
    name = "Heavy strike",
    description = function (actor)
        return "Stun the enemy and deal heavy damage"
    end,
    effects_sequence = {
        require "effects.move_to_target",
        require "effects.heavy_atttack",
        require "effects.move_to_original_position"
    },
    targeted = true
}
