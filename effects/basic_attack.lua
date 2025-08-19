local duration = 0.6

---@type EffectDef
return {
	description = "Deals 100% of STR as damage.",
	target_effect = function (origin, target)
		DEAL_DAMAGE(origin, target, 1, 0, 1)
	end,
	scene_render = function (time_passed, origin, target, scene_data)
		local progress = SMOOTHERSTEP(time_passed / duration)

		love.graphics.line(
			target.x - 10,
			target.y - 10,
			target.x - 10 + (ACTOR_WIDTH + 20) * progress,
			target.y - 10 + (ACTOR_HEIGHT + 20) * progress
		)
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