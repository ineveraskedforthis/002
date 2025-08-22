local battles = require "state.battle"

local wolf = require "meta-actors.wolf"

---@param state GameState
return function (state)
	local battle = state.last_battle
	battles.reset_battle(battle)

	battle.in_progress = true
	battles.put_player_into_battle(state)

	if battle.wave == 1 then
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 1, 1), false)
		battles.add_actor_to_battle(battle, battles.new_actor(wolf, 2, 1), false)
		return true
	end

	return false
end