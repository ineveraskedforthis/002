---@class Scene
---@field name string
---@field reset fun(state: GameState)
---@field render fun(state: GameState)
---@field update fun(state: GameState, dt: number)
---@field on_click fun(state: GameState, x: number, y: number)

local manager = {}

---@type Scene[]
local scenes = {}
local available_id = 1

function manager.new_scene(name)
	---@type Scene
	local def = {
		name = name,
		reset = function (state)
		end,
		on_click = function (state, x, y)
		end,
		render = function (state )
		end,
		update = function (state, dt)
		end
	}
	table.insert(scenes, def)
	available_id = available_id + 1
	return available_id - 1
end

function manager.get(id)
	return scenes[id]
end

return manager