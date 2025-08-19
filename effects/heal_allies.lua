local duration = 0.01

---@type EffectDef
return {
    description = "\n\tRestores 150% (of origin's MAG) HP of all allies.",
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
        RESTORE_HP(origin, target, 1.5)
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
}