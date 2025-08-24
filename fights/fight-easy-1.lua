local battles = require "fights._battle-system"

local wolf = require "meta-actors.wolf"

---@param state GameState
return function (state)
	local battle = state.last_battle

	if battle.wave == 1 then
		battles.put_player_into_battle(state)
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 1, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 2, 1), false)
		return true
	end

	return false
end