require "types"
require "mechanics.basic"
require "scenes._loader"
require "story.game-start"

local scene_manager = require "scenes._manager"


function CLAMP(x, a, b)
	if (x < a) then
		return a
	end
	if (x > b) then
		return b
	end
	return x
end

---comment
---@param t number
---@return number
function SMOOTHSTEP(t)
	return t * t * (3 - 2 * t)
end

---@param x number
---@return number
function SMOOTHERSTEP(x)
	return x * x * x * (x * (6 * x - 15) + 10);
end

---@type GameState
local state = require "state.state"

require "story.game-start"(state)

local style = require "ui._style"

function love.load()
	require "state.init-state-release"(state)
	love.window.setMode( 1280, 720, {msaa = 8} )
end

function love.update(dt)
	state.vfx.update(dt)
	scene_manager.get(state.current_scene).update(state, dt)
end

function love.draw()
	style.basic_bg_color()
	scene_manager.get(state.current_scene).render(state)
	state.vfx.render()
	-- love.graphics.print(state.currency .. " points", 5, 700)
end

function love.mousepressed(x, y, button, istouch, presses)
	scene_manager.get(state.current_scene).on_click(state, x, y)
end