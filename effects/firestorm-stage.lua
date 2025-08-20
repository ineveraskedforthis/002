local duration = 0.5

---@type EffectDef
return {
	description = "Deals [50% of MAG] damage to everyone",
	target_effect = function (origin, target)
		for index, value in ipairs(BATTLE) do
			if target.team == value.team then
				DEAL_DAMAGE(origin, value, 0, 0.5, 0)
			end
		end
	end,
	scene_render = function (time_passed, origin, target, scene_data)
		local progress = time_passed / duration
		local fall = 300 + SMOOTHERSTEP(progress * progress) * (-300)
		love.graphics.setColor(1, 0.4, 0.4, progress + 0.1)
		for index, value in ipairs(BATTLE) do
			if target.team == value.team and target.HP > 0 then
				love.graphics.circle("fill", value.x, value.y + fall, 10)
			end
		end
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