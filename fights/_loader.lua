local BATTLES = require "fights._enum"

---@param state GameState
---@param index SCRIPTED_BATTLE
return function (state, index, reset_wave)
	state.current_scripted_fight = index
	if reset_wave then
		state.last_battle.wave = 1
	end
	if index == BATTLES.EASY_1 then
		return require "fights.fight-easy-1"(state)
	end
	if index == BATTLES.NORMAL_1 then
		return require "fights.fight-1"(state)
	end
	if index == BATTLES.NORMAL_2 then
		return require "fights.fight-2"(state)
	end
end