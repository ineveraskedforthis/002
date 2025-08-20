ACTOR_WIDTH = 50
ACTOR_HEIGHT = 70

---@param colors table[]
local function gradient_h(colors)
	local result = love.image.newImageData(#colors, 1)
	for i, color in ipairs(colors) do
		local x, y = i - 1, 0
		print(x, y)
		result:setPixel(x, y, color[1], color[2], color[3], color[4] or 1)
	end
	local result_image = love.graphics.newImage(result)
	result_image:setFilter('linear', 'linear')
	return result_image
end

local function draw_image_in_rect(img, x, y, w, h, r, ox, oy, kx, ky)
	return love.graphics.draw(img, x, y, r, w / img:getWidth(), h / img:getHeight(), ox, oy, kx, ky)
end

local hp_gradient_ally = gradient_h({{0.7, 0.9, 0.8}, {100 / 255, 190 / 255, 175 / 255}})
local hp_gradient_enemy = gradient_h({{0.95, 0.1, 0.05}, {1, 0.11, 0.05}})

---comment
---@param x number
---@param y number
---@param w number
---@param h number
---@param hp number
---@param hp_view number
---@param max_hp number
---@param shield number
---@param team number
local function hp_bar(x, y, w, h, hp, hp_view, max_hp, shield, team)
	local outerouter = 1
	local outer = 1
	local shield_offset = 1
	local fill = 1
	local inner = 1

	-- outer outer border
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x, y, w, h)

	-- outer border
	love.graphics.setColor(0.29, 0.35, 0.32)
	love.graphics.rectangle("fill", x + outerouter, y + outerouter, w - outerouter * 2, h - outerouter * 2)

	-- betweeen border fill
	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.rectangle("fill", x + outer + outerouter, y + outer + outerouter, w - (outer + outerouter) * 2, h - (outer + outerouter) * 2)

	-- shield
	local shield_ratio = math.min(1, shield / max_hp / 10)
	love.graphics.setColor(0.95, 0.95, 1)
	love.graphics.rectangle("fill", x + shield_offset, y + shield_offset, (w - shield_offset * 2) * shield_ratio, h - shield_offset * 2)

	-- inner border
	do
		love.graphics.setColor(0.1, 0.15, 0.1)
		local margin = outer + fill
		local _x = x + margin
		local _y = y + margin
		local _w = w - 2 * margin
		local _h = h - 2 * margin

		love.graphics.rectangle("fill", _x, _y, _w, _h)
	end

	-- hp bar
	do
		local hp_ratio_actual = hp / max_hp
		local hp_ratio_view = hp_view / max_hp
		local margin = outer + fill + inner
		local _x = x + margin
		local _y = y + margin
		local _w = w - 2 * margin
		local _h = h - 2 * margin
		love.graphics.setColor(1, 1, 1)
		if team == 1 then
			draw_image_in_rect(hp_gradient_enemy, _x, _y, _w * hp_ratio_actual, _h, 0)
		else
			draw_image_in_rect(hp_gradient_ally, _x, _y, _w * hp_ratio_actual, _h, 0)
		end

		if team == 1 then
			love.graphics.setColor(1, 0.8, 0.8, 1)
		else
			love.graphics.setColor(0.35, 0.45, 0.4)
		end

		if hp_ratio_view > hp_ratio_actual then
			love.graphics.rectangle("fill", _x + _w * hp_ratio_actual, _y, _w * (hp_ratio_view - hp_ratio_actual), _h)
		else
			love.graphics.rectangle("fill", _x + _w * hp_ratio_view, _y, _w * (hp_ratio_actual - hp_ratio_view), _h)
		end
	end
end

---comment
---@param x number
---@param y number
---@param actor Actor
return function (x, y, actor, alpha)
	if not alpha then
		alpha = 1
	end
	if SELECTED == actor then
		love.graphics.rectangle("line", x - 4, y - 4, ACTOR_WIDTH + 8, ACTOR_HEIGHT + 8)
	end
	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.setFont(DEFAULT_FONT)
	love.graphics.printf(actor.definition.name, x - 10, y - 20, ACTOR_WIDTH + 20, "center")
	love.graphics.setColor(1, 1, 1, alpha)
	love.graphics.draw(actor.definition.image, x, y, 0)
	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.rectangle("line", x, y, ACTOR_WIDTH, ACTOR_HEIGHT)

	local margin = 5

	local hp_bar_left = x - 8
	local hp_bar_width = ACTOR_WIDTH + 16

	local max_hp = TOTAL_MAX_HP(actor.definition, actor.wrapper)

	-- draw shield
	hp_bar(
		hp_bar_left, y + ACTOR_HEIGHT + margin, hp_bar_width, 12,
		actor.HP, actor.HP_view or actor.HP, max_hp, actor.SHIELD,
		actor.team
	)

	love.graphics.setColor(0, 0, 0, alpha)

	if (actor.SHIELD > 0) then
		love.graphics.printf(tostring(math.floor(actor.HP)) .. " + " .. tostring(actor.SHIELD), x, y + ACTOR_HEIGHT + margin + 20, ACTOR_WIDTH, "center")
	else
		love.graphics.printf(tostring(math.floor(actor.HP)), x, y + ACTOR_HEIGHT + margin + 20, ACTOR_WIDTH, "center")
	end

	for index, value in ipairs(actor.pending_damage) do
		local a = value.alpha
		love.graphics.setFont(BIG_FONT)
		love.graphics.setColor(0, 0, 0, a)
		local text_border = 1
		love.graphics.print(tostring(value.value), x - text_border, y - 50 * (1 - a))
		love.graphics.print(tostring(value.value), x, y - 50 * (1 - a) + text_border)
		love.graphics.print(tostring(value.value), x + text_border, y - 50 * (1 - a))
		love.graphics.print(tostring(value.value), x, y - 50 * (1 - a) - text_border)
		if value.value > 0 then
			love.graphics.setColor(1, 0, 0, a)
		else
			love.graphics.setColor(0, 1, 0, a)
		end
		love.graphics.print(tostring(value.value), x, y - 50 * (1 - a))
	end
end