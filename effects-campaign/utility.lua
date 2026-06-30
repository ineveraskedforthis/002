local ids = require "scenes._ids"

---comment
---@param state GameState
---@param result BATTLE_RESULT
function ON_BATTLE_END(state, result)
	state.current_scene = ids.dialog
	state.last_battle_awaits_topic_resolution = true
	state.last_battle_result = result
end