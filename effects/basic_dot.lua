local draw_actor = require "ui.actor"

local duration = 0.01

local offset_target_x = 300
local offset_target_y = 300

---@type EffectDef
return {
    description = "\n\tDeals 30% of ATK as damage\n\tignores defense",
    target_effect = function (origin, target)
        DEAL_DAMAGE(origin, target, 0.30, 0)
    end,
    scene_render = function (time_passed, origin, target, scene_data)
        draw_actor(offset_target_x, offset_target_y, target)
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