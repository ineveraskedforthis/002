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
    -- local recorded_damage = damage
    b.SHIELD = b.SHIELD - damage
    if b.SHIELD < 0 then
        damage = -b.SHIELD
        b.SHIELD = 0
    else
        damage = 0
    end
    b.HP = math.max(0, b.HP - damage)

    if b.HP == 0 then
        ---@type Effect
        local death =  {
            data = {},
            def = require "effects.death",
            origin = b,
            target = b,
            started = false,
            time_passed = 0,
            times_activated = 0
        }
        table.insert(EFFECTS_QUEUE, death)
    end

    -- print(a.definition.name .. " attacks " .. b.definition.name .. ". " .. tostring(recorded_damage) .. "DMG. " .. "HP left: " .. tostring(b.HP))
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

---@param origin Actor
---@param target Actor
---@param origin_hp_ratio number
---@param origin_defense_ratio number
---@param max_hp_ratio number
function ADD_SHIELD(origin, target, origin_hp_ratio, origin_defense_ratio, max_hp_ratio)
    local add = math.floor(origin.definition.MAX_HP * origin_hp_ratio + origin.definition.DEF * origin_defense_ratio)
    local mult = math.min(1, max_hp_ratio * target.definition.MAX_HP / target.SHIELD)
    target.SHIELD = target.SHIELD + math.floor(add * mult)
end

---@param origin Actor
---@param target Actor
---@param origin_hp_ratio number
---@param origin_atk_ratio number
function RESTORE_HP(origin, target, origin_hp_ratio, origin_atk_ratio)
    local add = math.floor(origin.definition.MAX_HP * origin_hp_ratio + origin.definition.ATK * origin_atk_ratio)
    target.HP = math.min(target.definition.MAX_HP, target.HP + add)

    ---@type PendingDamage
    local pending = {
        alpha = 1,
        value = -add
    }
    table.insert(target.pending_damage, pending)
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
            -- actor.HP_view = actor.HP_view - actor.pending_damage[i].value
        end
    end

    for index, value in ipairs(to_remove) do
        table.remove(actor.pending_damage, value)
    end
end