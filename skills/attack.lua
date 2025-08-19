local attack = require "effects.basic_attack"

return {
    name = "Attack",
    description = function (actor)
        return "Attack the target enemy"
    end,
    effects_sequence = {
        attack, attack
    },
    targeted = true
}