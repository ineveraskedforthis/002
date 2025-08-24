local draw_actor = require "ui.actor"
local manager = require "effects._manager"
local duration = 0.1
local id, def = manager.new_effect(duration)

function def.target_effect(state, battle, origin, target, data)
	if target.team == 1 then
		for _, value in ipairs(battle.actors) do
			if value.team == 0 and value.wrapper then
				-- todo: variable experience
				ADD_EXP(value.wrapper, 1)
			end
		end
		state.currency = state.currency + 1
	end
end

function def.scene_render(state, battle, time_passed, origin, target, scene_data)
	draw_actor.render(state, battle, origin.x, origin.y, target, 1 - time_passed / duration)
end

function def.scene_update(state, battle, time_passed, dt, origin, target, scene_data)
	if (time_passed > duration) then
		return true
	end
	origin.HP_view = origin.HP_view * (1 - time_passed / duration)
	return false
end

function def.scene_on_start(state, battle, origin, target)
	origin.visible = false
end

return id