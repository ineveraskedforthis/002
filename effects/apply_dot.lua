local draw_actor = require "ui.actor"

local duration = 0.5

local actual_dot = require "effects.basic_dot"

local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

---@type EffectDef
return {
    description = "Activate old dots and apply new dot:\n\t" .. actual_dot.description,
    target_effect = function (origin, target)
        for index, value in ipairs(target.status_effects) do
            value.def.target_effect(value.origin, target)
        end
        APPLY_EFFECT(origin, target, actual_dot)
    end,
    scene_render = function (time_passed, origin, target, scene_data)
        local progress = time_passed / duration

        local origin_x = get_x(origin)
        local target_x = get_x(target)

        local origin_y = get_y(origin)
        local target_y = get_y(target)

        draw_actor(target_x, target_y, target)
        draw_actor(origin_x, origin_y, origin)

        local x = progress * target_x + (1 - progress) * origin_x
        local y = progress * target_y + (1 - progress) * origin_y

        love.graphics.circle("line", x, y, 10)
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