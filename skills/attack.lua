local attack = require "effects.basic_attack"

return {
    name = "Attack",
    description = function (actor)
        return "Attacks the target enemy"
    end,
    effects_sequence = {
        attack, attack
    }
}