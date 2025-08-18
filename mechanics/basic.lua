---comment
---@param a Actor
---@param b Actor
---@param effect EffectDef
function APPLY_EFFECT(a, b, effect)
    ---@type Effect
    local new_effect = {
        data = {},
        def = effect,
        origin = a,
        started = false,
        target = b,
        time_passed = 0,
        times_activated = 0
    }

    table.insert(b.status_effects, new_effect)
end

---comment
---@param a Actor
---@param b Actor
---@param attacker_atk_ratio number
---@param defender_defense_ratio number
function DEAL_DAMAGE(a, b, attacker_atk_ratio, defender_defense_ratio)
    local damage = math.floor(math.max(0, a.definition.ATK * attacker_atk_ratio - b.definition.DEF * defender_defense_ratio))
    b.HP = b.HP - damage
    ---@type PendingDamage
    local pending = {
        alpha = 1,
        value = damage
    }
    table.insert(b.pending_damage, pending)
    if b.definition.damaged_sound then
        b.definition.damaged_sound:stop()
        b.definition.damaged_sound:play()
    end
end

function SPEED_TO_ACTION_OFFSET(speed)
    return math.floor(10000 / speed)
end

---comment
---@param actor Actor
function CLEAR_PENDING_EFFECTS(actor)
    local count = #actor.pending_damage
    local to_remove = {}
    for i = count, 1, -1 do
        if actor.pending_damage[i].alpha < 0 then
            table.insert(to_remove, i)
            actor.HP_view = actor.HP_view - actor.pending_damage[i].value
        end
    end

    for index, value in ipairs(to_remove) do
        table.remove(actor.pending_damage, value)
    end
end