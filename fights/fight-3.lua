local battles = require "fights._battle-system"
local enemy = require "meta-actors.creation"

---@param state GameState
return function (state)
	local battle = state.last_battle

	print("wave", battle.wave)

	if battle.wave == 1 then
		battles.put_player_into_battle(state)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 1, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 2, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 3, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 4, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 5, 1), false)
		return true
	end

	if battle.wave == 2 then
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 1, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 2, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 3, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 4, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(enemy, 5, 1), false)
		return true
	end

	return false
end