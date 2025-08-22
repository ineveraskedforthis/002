local battles = require "state.battle"
local battle = require "state.battle"

---@param state GameState
return function (state)
	local battle = state.last_battle
	battles.reset_battle(battle)
	battle.in_progress = true
	battles.put_player_into_battle(state)

	print("wave", battle.wave)

	if battle.wave == 1 then
		local chris = battles.new_actor(require "meta-actors.chris", 1, 1)
		battles.add_actor_to_battle(battle, chris, false)
		return true
	end

	if battle.wave == 2 then
		local strong_enemy = battles.new_actor(require "meta-actors.amogus", 1, 1)
		local fast_enemy = battles.new_actor(require "meta-actors.shadow", 2, 1)

		battles.add_actor_to_battle(battle, strong_enemy, false)
		battles.add_actor_to_battle(battle, fast_enemy, false)
		return true
	end

	if battle.wave == 3 then
		---@type Actor
		local enemy = battles.new_actor(require "meta-actors.john", 1, 1)

		battles.add_actor_to_battle(battle, enemy, false)
		return true
	end

	return false
end