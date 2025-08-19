local duration = 0.4

local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

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
        origin.x = scene_data.x * (1 - progress) + get_x(origin) * progress
        origin.y = scene_data.y * (1 - progress) + get_y(origin) * progress

        return false
    end,
    scene_on_start = function (origin, target, scene_data)
        origin.visible = true
        local x = get_x(origin)
        local y = get_y(origin)
        if origin.team == 0 then
            scene_data.x = x
            scene_data.y = y + 300
        else
            scene_data.x = x
            scene_data.y = y - 300
        end
    end
}