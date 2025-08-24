local battle_manager = require "fights._battle-system"

---@param state GameState
return function (state)
	local battle = state.last_battle

	print("wave", battle.wave)

	if battle.wave == 1 then
		battle_manager.put_player_into_battle(state)
		local chris = battle_manager.new_actor(require "meta-actors.chris", 1, 1)
		battle_manager.add_actor_to_battle(battle, chris, false)
		return true
	end

	if battle.wave == 2 then
		local strong_enemy = battle_manager.new_actor(require "meta-actors.amogus", 1, 1)
		local fast_enemy = battle_manager.new_actor(require "meta-actors.shadow", 2, 1)

		battle_manager.add_actor_to_battle(battle, strong_enemy, false)
		battle_manager.add_actor_to_battle(battle, fast_enemy, false)
		return true
	end

	if battle.wave == 3 then
		---@type Actor
		local enemy = battle_manager.new_actor(require "meta-actors.john", 1, 1)
		battle_manager.add_actor_to_battle(battle, enemy, false)
		return true
	end

	return false
end