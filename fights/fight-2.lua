return function ()
    RESET_BATTLE()
    PLAYER_ENTER_BATTLE()

    if WAVE == 1 then
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 1, 1), 1, false)
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 2, 1), 1, false)
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 3, 1), 1, false)
        return true
    end

    if WAVE == 2 then
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 1, 1), 1, false)
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 2, 1), 1, false)
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf-leader", 3, 1), 1, false)
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 4, 1), 1, false)
        ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 5, 1), 1, false)
        return true
    end

    return false
end