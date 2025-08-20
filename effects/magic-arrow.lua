local duration = 0.8

---@type EffectDef
return {
	description = "Deals 50% of MAG damage to target",
	target_effect = function (origin, target)
		DEAL_DAMAGE(origin, target, 0, 0.5, 0)
	end,
	scene_render = function (time_passed, origin, target, scene_data)
		local progress = time_passed / duration

		local x = progress * target.x + (1 - progress) * origin.x
		local y = progress * target.y + (1 - progress) * origin.y

		love.graphics.setColor(1, 0.5, 1, 1)
		love.graphics.circle("fill", x, y, 10)
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