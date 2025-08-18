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

function PLAYER_ENTER_BATTLE()
    for i = 1, 4 do
        if CHARACTER_LINEUP[i] ~= 0 then
            local def = PLAYABLE_META_ACTORS[CHARACTER_LINEUP[i]].def
            ENTER_BATTLE(GENERATE_ACTOR(def, i, 0), 0, false)
        end
    end
end

function RESET_BATTLE()
    ---@type Actor[]
    BATTLE = {}
    ---@type Effect[]
    EFFECTS_QUEUE = {}
    ---@type Effect[]
    STATUS_EFFECT_QUEUE = {}
    SELECTED = nil
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

    actor.action_number = math.floor(max_action_number * 0.5) + SPEED_TO_ACTION_OFFSET(actor.definition.SPD)
    actor.team = team
    table.insert(BATTLE, actor)
    SORT_BATTLE()
end

