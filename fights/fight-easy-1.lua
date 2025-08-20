return function ()
	RESET_BATTLE()
	PLAYER_ENTER_BATTLE()

	if WAVE == 1 then
		SELECTED = GENERATE_ACTOR(require "meta-actors.wolf", 1, 1)
		ENTER_BATTLE(SELECTED, 1, false)
		ENTER_BATTLE(GENERATE_ACTOR(require "meta-actors.wolf", 2, 1), 1, false)
		return true
	end

	return false
end