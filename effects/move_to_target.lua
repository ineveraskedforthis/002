local duration = 0.4

---@type EffectDef
return {
    description = "Move to target",
    target_effect = function (origin, target)
    end,
    scene_render = function (time_passed, origin, target, scene_data)
    end,
    scene_update = function (time_passed, dt, origin, target, scene_data)
        if (time_passed > duration) then
            return true
        end

        local progress = SMOOTHERSTEP(time_passed / duration)

        local shift_y = ACTOR_HEIGHT * 1.5
        if target.team == 0 then
            shift_y = - ACTOR_HEIGHT * 1.5
        end
        origin.x = scene_data.start_x * (1 - progress) + target.x * progress
        origin.y = scene_data.start_y * (1 - progress) + (target.y + shift_y) * progress

        return false
    end,
    scene_on_start = function (origin, target, scene_data)
        scene_data.start_x = origin.x
        scene_data.start_y = origin.y
    end
}