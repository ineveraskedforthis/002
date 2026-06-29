local manager = require "scenes._manager"
local style = require "ui._style"
local scenes = require "scenes._ids"
local battle_manager = require "fights._battle-system"


local ids = require "scenes._ids"
local id = ids.game_over
local def = manager.get(id)

local button = require "ui.button"

---comment
---@param render boolean
local function interface(state, render, click, mx, my)
	if button(render, click, "Start again", 400, 400, 80, 30, mx, my, false) then
		love.load()
	end
end

function def.render(state, journal)
	local mx, my = love.mouse.getPosition();
	interface(state, true, false, mx, my)
end


function def.on_click(state, journal, x, y)
	interface(state, false, true, x, y)
end