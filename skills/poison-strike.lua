return {
    name = "Light poison",
    description = function (actor)
        return "Enemy starts taking damage over time"
    end,
    effects_sequence = {
        require "effects.apply_dot"
    },
    targeted = true
}