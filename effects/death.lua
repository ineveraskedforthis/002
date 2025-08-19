local draw_actor = require "ui.actor"

local duration = 0.5

local actual_dot = require "effects.basic_dot"

---@type EffectDef
return {
    description = "Death",
    target_effect = function (origin, target)
    end,
    scene_render = function (time_passed, origin, target, scene_data)
        draw_actor(origin.x, origin.y, target, 1 - time_passed / duration)
    end,
    scene_update = function (time_passed, dt, origin, target, scene_data)
        if (time_passed > duration) then
            return true
        end
        origin.HP_view = origin.HP_view * (1 - time_passed / duration)
        return false
    end,
    scene_on_start = function (origin, target)
        origin.visible = false
    end
}