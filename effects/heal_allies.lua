local draw_actor = require "ui.actor"

local duration = 0.01

local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

---@type EffectDef
return {
    description = "\n\tRestores 30% (of origin's MAX_HP) HP of all allies.",
    multitarget = true,
    multi_target_selection = function (origin)
        local targets = {}
        for index, value in ipairs(BATTLE) do
            if value.team == origin.team then
                table.insert(targets, value)
            end
        end
        return targets
    end,
    target_effect = function (origin, target)
        RESTORE_HP(origin, target, 0.3, 0)
    end,
    scene_render = function (time_passed, origin, target, scene_data)
        local origin_x = get_x(origin)
        local target_x = get_x(target)

        local origin_y = get_y(origin)
        local target_y = get_y(target)

        draw_actor(target_x, target_y, target)
        draw_actor(origin_x, origin_y, origin)
    end,
    scene_update = function (time_passed, dt, origin, target, scene_data)
        if (time_passed > duration) then
            return true
        end
        return false
    end,
    scene_on_start = function (origin, target)
    end,
}