local duration = 0.01

---@type EffectDef
return {
    description = "\n\tAdds 5% of MAX_HP as shield to random ally. Shield is limited to 2x of MAXHP",
    target_selection = function (origin)
        local potential_targets = {}
        local count = 0
        for index, value in ipairs(BATTLE) do
            if value ~= origin and value.team == origin.team then
                table.insert(potential_targets, value)
                count = count + 1
            end
        end
        local dice_roll = math.random(count)
        return potential_targets[dice_roll]
    end,
    target_effect = function (origin, target)
        ADD_SHIELD(origin, target, 0.05, 0, 2)
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