return function ()
	RESET_BATTLE()
	PLAYER_ENTER_BATTLE()

	if WAVE == 1 then
		local selected_wolf = GENERATE_ACTOR(require "meta-actors.wolf", 1, 1)
		SELECTED = selected_wolf
		ENTER_BATTLE(selected_wolf, 1, false)
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 2, 1), 1, false)
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 3, 1), 1, false)
		return true
	end

	if WAVE == 2 then
		local boss_wolf = GENERATE_ACTOR(require "meta-actors.wolf-leader", 3, 1)
		SELECTED = boss_wolf
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 1, 1), 1, false)
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 2, 1), 1, false)
		ENTER_BATTLE(boss_wolf, 1, false)
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 4, 1), 1, false)
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 5, 1), 1, false)
		return true
	end

	return false
end