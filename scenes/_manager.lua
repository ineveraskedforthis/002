---@class Scene
---@field name string
---@field reset fun(state: GameState, journal: Journal)
---@field render fun(state: GameState, journal: Journal)
---@field update fun(state: GameState, journal: Journal, dt: number)
---@field on_click fun(state: GameState, journal: Journal, x: number, y: number)

local manager = {}

---@type Scene[]
local scenes = {}
local available_id = 1

function manager.new_scene(name)
	---@type Scene
	local def = {
		name = name,
		reset = function (state, journal)
		end,
		on_click = function (state, journal, x, y)
		end,
		render = function (state, journal)
		end,
		update = function (state, journal, dt)
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