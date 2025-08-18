return {
    name = "Heavy strike",
    description = function (actor)
        return "Stuns the enemy and deals heavy damage"
    end,
    effects_sequence = {
        require "effects.heavy_atttack"
    }
}
