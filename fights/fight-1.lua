return function ()
	RESET_BATTLE()
	PLAYER_ENTER_BATTLE()

	if WAVE == 1 then
		local chris = GENERATE_ACTOR(require "meta-actors.chris", 1, 1)

		ENTER_BATTLE(chris, 1, false)
		SELECTED = chris
		return true
	end

	if WAVE == 2 then
		local strong_enemy = GENERATE_ACTOR(require "meta-actors.amogus", 1, 1)
		local fast_enemy = GENERATE_ACTOR(require "meta-actors.shadow", 2, 1)

		ENTER_BATTLE(strong_enemy, 1, false)
		ENTER_BATTLE(fast_enemy, 1, false)
		SELECTED = strong_enemy
		return true
	end

	if WAVE == 3 then
		---@type Actor
		local enemy = GENERATE_ACTOR(require "meta-actors.john", 1, 1)

		ENTER_BATTLE(enemy, 1, false)
		SELECTED = enemy
		return true
	end

	return false
end