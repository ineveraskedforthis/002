local draw_actor = require "ui.actor"

local duration = 0.5

local get_x = require "ui.battle".get_x
local get_y = require "ui.battle".get_y

---@type EffectDef
return {
    description = "Deals 75% of ATK as damage",
    target_effect = function (origin, target)
        DEAL_DAMAGE(origin, target, 0.75, 1)
    end,
    scene_render = function (time_passed, origin, target, scene_data)
        local progress = time_passed / duration

        local progress_movement = math.min(1, progress * 3)
        local progress_attack = math.min(1, math.max(0, progress - 0.33) * 3)
        local progress_attack = progress_attack * progress_attack

        local progress_jump_back = math.max(0, progress - 0.66) * 3

        local origin_x = get_x(origin)
        local target_x = get_x(target)

        local origin_y = get_y(origin)
        local target_y = get_y(target)

        draw_actor(target_x, target_y, target)

        local x = progress_movement * target_x + (1 - progress_movement) * origin_x
        local y = progress_movement * target_y + (1 - progress_movement) * origin_y

        if origin.team == 0 then
            y = y + ACTOR_HEIGHT
        else
            y = y - ACTOR_HEIGHT
        end

        x = x * (1 - progress_jump_back) + progress_jump_back * origin_x
        y = y * (1 - progress_jump_back) + progress_jump_back * origin_y

        draw_actor(x, y, origin)

        if (progress_attack > 0) then
            love.graphics.line(
                target_x - 10,
                target_y - 10,
                target_x - 10 + (ACTOR_WIDTH + 20) * progress_attack,
                target_y - 10 + (ACTOR_HEIGHT + 20) * progress_attack
            )
        end
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