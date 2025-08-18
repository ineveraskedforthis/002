---comment
---@param def MetaActor
function GENERATE_ACTOR(def, pos, team)
    ---@type Actor
    local temp = {
        HP = def.MAX_HP,
        action_number = 0,
        definition = def,
        pending_damage = {},
        pos = pos,
        status_effects = {},
        team = team,
    }

    return temp
end

function SORT_BATTLE()
    table.sort(BATTLE, function (a, b)
        return a.action_number < b.action_number
    end)
end

---comment
---@param actor Actor
---@param team number
---@param was_in_battle boolean
function ENTER_BATTLE(actor, team, was_in_battle)
    local max_action_number = 0
    if not was_in_battle then
        for k, v in ipairs(BATTLE) do
            if v.action_number > max_action_number then
                max_action_number = v.action_number
            end
        end
    end

    actor.action_number = max_action_number + SPEED_TO_ACTION_OFFSET(actor.definition.SPD)
    actor.team = team
    table.insert(BATTLE, actor)
    SORT_BATTLE()
end