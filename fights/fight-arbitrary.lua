local battle_manager = require "fights._battle-system"

---@param state GameState
return function (state)
	local battle = state.last_battle

	print("wave", battle.wave)

	if battle.wave == 1 then
		for i =0, 5 do
			local strong_enemy = battle_manager.new_actor(require "meta-actors.amogus", 1, 1)
			battle_manager.add_actor_to_battle(battle, strong_enemy, false)
		end
		return true
	end

	return false
end