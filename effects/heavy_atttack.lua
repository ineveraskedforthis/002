local duration = 1.0

---@type EffectDef
return {
	description = "Deals 150% of ATK as damage and delays target's action",
	target_effect = function (origin, target)
		DEAL_DAMAGE(origin, target, 1.5, 0, 1)
		target.action_number = target.action_number + SPEED_TO_ACTION_OFFSET(target.definition.SPD)
	end,
	scene_render = function (time_passed, origin, target, scene_data)
		local progress = SMOOTHERSTEP(time_passed / duration * time_passed / duration)

		love.graphics.line(
			target.x - 10,
			target.y - 10,
			target.x - 10 + (ACTOR_WIDTH + 20) * progress,
			target.y - 10 + (ACTOR_HEIGHT + 20) * progress
		)

		love.graphics.line(
			target.x - 10 - 3,
			target.y - 10 + 3,
			target.x - 10 - 3 + (ACTOR_WIDTH + 20) * progress,
			target.y - 10 + 3 + (ACTOR_HEIGHT + 20) * progress
		)

		love.graphics.line(
			target.x - 10 + 3,
			target.y - 10 - 3,
			target.x - 10 + 3 + (ACTOR_WIDTH + 20) * progress,
			target.y - 10 - 3 + (ACTOR_HEIGHT + 20) * progress
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