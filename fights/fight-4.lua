return function ()
    ---@type Actor
    GG = GENERATE_ACTOR(require "meta-actors.main-character", 1, 0)
    CHUD = GENERATE_ACTOR(require "meta-actors.chud", 2, 0)

    ---@type Actor[]
    BATTLE = {}
    ---@type Effect[]
    EFFECTS_QUEUE = {}
    ---@type Effect[]
    STATUS_EFFECT_QUEUE = {}

    SELECTED = nil

    if WAVE == 1 then
        local chris = GENERATE_ACTOR(require "meta-actors.chris", 1, 1)

        ENTER_BATTLE(GG, 0, false)
        ENTER_BATTLE(CHUD, 0, false)
        ENTER_BATTLE(chris, 1, false)
        return
    end

    if WAVE == 2 then
        local strong_enemy = GENERATE_ACTOR(require "meta-actors.amogus", 1, 1)
        local fast_enemy = GENERATE_ACTOR(require "meta-actors.shadow", 2, 1)

        ENTER_BATTLE(GG, 0, false)
        ENTER_BATTLE(CHUD, 0, false)
        ENTER_BATTLE(strong_enemy, 1, false)
        ENTER_BATTLE(fast_enemy, 1, false)
        return
    end

    if WAVE == 3 then
        ---@type Actor
        local enemy = GENERATE_ACTOR(require "meta-actors.john", 1, 1)

        ENTER_BATTLE(GG, 0, false)
        ENTER_BATTLE(CHUD, 0, false)
        ENTER_BATTLE(enemy, 1, false)
        return
    end
end