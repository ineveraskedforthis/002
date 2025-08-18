local draw_actor = require "ui.actor"

local duration = 0.5

local offset_target_x = 300
local offset_target_y = 300

local actual_dot = require "effects.basic_dot"

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
        local progress = time_passed / duration * time_passed / duration
        draw_actor(offset_target_x, offset_target_y, target)
        love.graphics.line(
            offset_target_x - 10,
            offset_target_y - 10,
            offset_target_x - 10 + (ACTOR_WIDTH + 20) * progress,
            offset_target_y - 10 + (ACTOR_HEIGHT + 20) * progress
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