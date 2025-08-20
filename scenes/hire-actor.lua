
local pull_in_progress = false
local pull_progress = 0
local turn_over_progress = 0
local pulled = false
---@type number
local pulled_character = 0
local pull_away_in_progress = false
local pull_away_progress = 0

local function reset()
	pull_in_progress = false
	pull_progress = 0
	turn_over_progress = 0
	---@type number
	pulled_character = 0
	pull_away_in_progress = false
	pull_away_progress = 0
	pulled = false
end

local render_meta_actor = require "ui.meta-actor"


local function render()
	if pull_in_progress then
		if pull_progress < 1 then
			love.graphics.rectangle("line", 400 + pull_progress * 120 - ACTOR_WIDTH, 210, ACTOR_WIDTH, ACTOR_HEIGHT)
		elseif turn_over_progress < 0.5 then
			local w = ACTOR_WIDTH * (0.5 - turn_over_progress) * 2
			love.graphics.rectangle("line", 400 + pull_progress * 120 - ACTOR_WIDTH, 210, w, ACTOR_HEIGHT)
		else
			local w = ACTOR_WIDTH * (turn_over_progress - 0.5) * 2
			local x = 400 + pull_progress * 120 - ACTOR_WIDTH - w
			local y = 210 + pull_away_progress * 400
			if pulled_character ~= 0 then
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.draw(PLAYABLE_META_ACTORS[pulled_character].def.image, x, y, 0, w / ACTOR_WIDTH, 1)
			end
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("line", x, y, w, ACTOR_HEIGHT)
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 200, 200, 200, 200)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("line", 200, 200, 200, 200)
	love.graphics.print("GET CHARACTER", 250, 250)

	love.graphics.rectangle("line", 200, 500, 100, 20)
	love.graphics.print("return", 200, 500)
end

local function update(dt)
	if pull_in_progress then
		if pull_progress < 1 then
			pull_progress = math.min(1, pull_progress + dt * 2)
			-- print(pull_progress, turn_over_progress)
		elseif turn_over_progress < 1 then
			turn_over_progress = math.min(1, turn_over_progress + dt * 2)
			-- print(pull_progress, turn_over_progress)
			if turn_over_progress > 0.5 and pulled_character == 0 then
				pulled_character = love.math.random(1, #PLAYABLE_META_ACTORS)
				if not pulled then
					print("pull")
					if PLAYABLE_META_ACTORS[pulled_character].unlocked then
						ADD_EXP(PLAYABLE_META_ACTORS[pulled_character], 5)
					else
						PLAYABLE_META_ACTORS[pulled_character].unlocked = true
					end
					pulled = true
				end
			end
		end
	end

	if (pull_away_in_progress) then
		pull_away_progress = math.min(1, pull_away_progress + dt * 4)

		if pull_away_progress >= 1 then
			reset()
			pull_in_progress = true
		end
	end
end

local rect = require "ui.rect"


local function handle_click(x, y)
	if not pull_in_progress and rect(200, 200, 200, 200, x, y) and CURRENCY > 0 then
		pull_in_progress = true
		---@type number
		CURRENCY = CURRENCY - 1
	end

	if pull_in_progress and turn_over_progress == 1 and rect(200, 200, 200, 200, x, y) and CURRENCY > 0  then
		pull_away_in_progress = true
		CURRENCY = CURRENCY - 1
	end

	if pull_in_progress and pull_progress == 1 and turn_over_progress == 1 then
		if rect(200, 500, 100, 20, x, y) then
			CURRENT_SCENE = SCENE_BATTLE_SELECTOR
		end
	end
end

local scene = {
	update = update,
	render = render,
	on_click = handle_click
}

return scene