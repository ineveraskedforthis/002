local duration = 0.01

---@type EffectDef
return {
	description = "\n\tDeals 100% of MAG as damage ignoring defense",
	target_effect = function (origin, target)
		DEAL_DAMAGE(origin, target, 0, 1, 0)
	end,
	scene_render = function (time_passed, origin, target, scene_data)
	end,
	scene_update = function (time_passed, dt, origin, target, scene_data)
		if (time_passed > duration) then
			return true
		end
		return false
	end,
	scene_on_start = function (origin, target)
	end,
	max_times_activated = 200
}