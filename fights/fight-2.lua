local battles = require "fights._battle-system"
local wolf = require "meta-actors.wolf"

---@param state GameState
return function (state)
	local battle = state.last_battle

	print("wave", battle.wave)

	if battle.wave == 1 then
		battles.put_player_into_battle(state)
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 1, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 2, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 3, 1), false)
		return true
	end

	if battle.wave == 2 then
		local boss_wolf = battles.new_actor(require "meta-actors.wolf-leader", 3, 1)

		battles.add_actor_to_battle(battle, battles.new_actor(require "meta-actors.wolf", 1, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(require "meta-actors.wolf", 2, 1), false)
		battles.add_actor_to_battle(battle, boss_wolf, false)
		battles.add_actor_to_battle(battle, battles.new_actor(require "meta-actors.wolf", 4, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(require "meta-actors.wolf", 5, 1), false)
		return true
	end

	return false
end