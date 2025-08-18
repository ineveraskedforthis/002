return {
    name = "Heavy strike",
    description = function (actor)
        return "Stun the enemy and deal heavy damage"
    end,
    effects_sequence = {
        require "effects.heavy_atttack"
    }
}
