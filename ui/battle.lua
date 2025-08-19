local style = require "ui._style"
local offset_x = 150
local offset_y_team_0 = 400
local offset_y_team_1 = 50

return {
	---@param actor Actor
	get_x = function(actor)
		return offset_x + (style.battle_actors_spacing + ACTOR_WIDTH) * (actor.pos - 1)
	end,

	---@param actor Actor
	get_y = function(actor)
		if actor.team == 0 then
			return offset_y_team_0
		else
			return offset_y_team_1
		end
	end
}