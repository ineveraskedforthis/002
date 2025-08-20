local duration = 0.5

---@type EffectDef
return {
	description = "Deals [100% of STR + 100% of MAG] damage to everyone",
	target_effect = function (origin, target)
		for index, value in ipairs(BATTLE) do
			if target.team == value.team then
				DEAL_DAMAGE(origin, value, 1, 1, 0)
			end
		end
	end,
	scene_render = function (time_passed, origin, target, scene_data)
		local progress = SMOOTHERSTEP(time_passed / duration)

		love.graphics.setColor(1, 0.0, 0.0, 1)

		local x_left = 9999
		local x_right = 0

		local y = 0
		local count = 0

		for index, value in ipairs(BATTLE) do
			if target.team == value.team and target.visible then
				x_right = math.max(value.x + 100, x_right)
				if x_left > value.x then
					x_left = value.x
				end
				y = y + value.y
				count = count + 1
			end
		end

		y = y / count

		love.graphics.rectangle("fill", x_left - 10, y + 10, (x_right - x_left) * progress, 10)
	end,
	scene_update = function (time_passed, dt, origin, target, scene_data)
		if (time_passed > duration) then
			return true
		end
		return false
	end,
	scene_on_start = function (origin, target)
		if origin.definition.attack_sound then
			origin.definition.attack_sound:stop()
			origin.definition.attack_sound:play()
		end
	end
}