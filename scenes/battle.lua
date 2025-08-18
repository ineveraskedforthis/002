AWAIT_TURN = false

---@type Actor?
SELECTED = nil

---@type number
WAVE = 1

local function clear_dead()
    local removed = false
    local to_remove = 0
    for k, v in ipairs(BATTLE) do
        if v.HP <= 0 then
            removed = true
            to_remove = k
            break
        end
    end

    if removed then
        table.remove(BATTLE, to_remove)
        clear_dead()
        SELECTED = nil
    else
        return
    end
end

local function process_turn()
    ---@type Actor
    local actor = table.remove(BATTLE, 1)

    if actor.HP > 0 then
        print("readd to battle:" .. BATTLE[1].definition.name)
        ENTER_BATTLE(actor, actor.team, true)

        AWAIT_TURN = true
    end

    -- reduce action number

    local offset = -1

    for k, v in ipairs(BATTLE) do
        if v.action_number < offset or offset == -1 then
            offset = v.action_number
        end
    end

    for k, v in ipairs(BATTLE) do
        v.action_number = v.action_number - offset
    end

    clear_dead()
    SORT_BATTLE()

    -- queue all effects on new current character
    if (BATTLE[1]) then
        for index, value in ipairs(BATTLE[1].status_effects) do
            table.insert(STATUS_EFFECT_QUEUE, value)
        end
    end
end


local function update(dt)
    local battle_lost = true
    for key, value in ipairs(BATTLE) do
        if value.team == 0 and (value.HP_view == nil or value.HP_view > 0) then
            battle_lost = false
        end
    end

    if battle_lost then
        love.load()
    end

    local enemies_alive = false;

    for key, value in ipairs(BATTLE) do
        if value.team == 1 and (value.HP_view == nil or value.HP_view > 0) then
            enemies_alive = true
        end
    end

    if not enemies_alive then
        WAVE = WAVE + 1
        if not GENERATE_WAVE() then
            CURRENT_SCENE = SCENE_BATTLE_SELECTOR
        end
        return
    end

    for key, value in pairs(BATTLE) do
        if not value.HP_view then
            value.HP_view = value.HP
        end

        for index, pending in ipairs(value.pending_damage) do
            pending.alpha = pending.alpha - dt * 2 * (1 / (1 + index))
        end

        CLEAR_PENDING_EFFECTS(value)
    end

    do
        local current_effect = EFFECTS_QUEUE[1]
        if (current_effect) then
            if not current_effect.started then
                current_effect.def.scene_on_start(current_effect.origin, current_effect.target)
                current_effect.started = true
            end
            current_effect.time_passed = current_effect.time_passed + dt
            if current_effect.def.scene_update(current_effect.time_passed, dt, current_effect.origin, current_effect.target, current_effect.data) then
                table.remove(EFFECTS_QUEUE, 1)
                current_effect.def.target_effect(current_effect.origin, current_effect.target)
                if #EFFECTS_QUEUE == 0 then
                    process_turn()
                    return
                end
            else
                return
            end
        end
    end

    do
        local current_effect = STATUS_EFFECT_QUEUE[1]
        if (current_effect) then
            if not current_effect.started then
                current_effect.def.scene_on_start(current_effect.origin, current_effect.target)
                current_effect.started = true
            end
            current_effect.time_passed = current_effect.time_passed + dt
            if current_effect.def.scene_update(current_effect.time_passed, dt, current_effect.origin, current_effect.target, current_effect.data) then
                table.remove(STATUS_EFFECT_QUEUE, 1)
                current_effect.def.target_effect(current_effect.origin, current_effect.target)
            else
                return
            end
        end
    end

    if BATTLE[1].team == 1 and AWAIT_TURN then
        print("turn of " .. BATTLE[1].definition.name)
        -- AI turn
        -- attack the first target
        local target = nil

        for key, value in ipairs(BATTLE) do
            if value.team == 0 then
                target = key
                break
            end
        end

        if target then
            for index, effect in ipairs(BATTLE[1].definition.skills[1].effects_sequence) do
                ---@type Effect
                local new_effect = {
                    data = {},
                    def = effect,
                    origin = BATTLE[1],
                    target = BATTLE[target],
                    time_passed = 0,
                    started = false,
                    times_activated = 0
                }
                table.insert(EFFECTS_QUEUE, new_effect)
            end
        end

        AWAIT_TURN = false
    end
end

local style = require "ui._style"
local rect = require "ui.rect"

local function handle_click(x, y)
    if BATTLE[1].team == 0 and SELECTED and AWAIT_TURN then
        local offset_y = 50
        local offset_x = 400
        local acting_actor = BATTLE[1]
        for key, value in ipairs(acting_actor.definition.skills) do
            if rect(offset_x, offset_y, 50, 20, x, y) then
                AWAIT_TURN = false
                -- ATTACK(ACTORS[BATTLE[1].actor_id], ACTORS[SELECTED])
                for index, effect in ipairs(value.effects_sequence) do
                    ---@type Effect
                    local new_effect = {
                        data = {},
                        def = effect,
                        origin = BATTLE[1],
                        target = SELECTED,
                        time_passed = 0,
                        started = false,
                        times_activated = 0
                    }
                    table.insert(EFFECTS_QUEUE, new_effect)
                end
                break
            end
            offset_y = offset_y + 60
            for index, effect in ipairs(value.effects_sequence) do
                offset_y = offset_y + 20
            end
        end
    end

    local offset_x = 150
    local offset_y = 50

    for key, value in ipairs(BATTLE) do
        if BATTLE[key].team == 1 then
            local r_x = offset_x + (style.battle_actors_spacing + ACTOR_WIDTH) * (value.pos - 1)
            if (rect(r_x, offset_y, ACTOR_WIDTH, ACTOR_HEIGHT, x, y)) then
                SELECTED = value
            end
        end
    end
end

local main_render = require "fights.battle-render"

local function render()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(0, 0, 0, 1)

    local current_effect = EFFECTS_QUEUE[1]
    if current_effect then
        main_render(current_effect.origin, current_effect.target)
        current_effect.def.scene_render(
            current_effect.time_passed,
            current_effect.origin,
            current_effect.target,
            current_effect.data
        )
        return
    else
        main_render(nil, nil)
    end

    if not BATTLE[1] then
        love.graphics.print("YOU WON!!!", 150, 10)
        return
    end

    if BATTLE[1].team == 0 then
        love.graphics.setFont(DEFAULT_FONT)
        love.graphics.print("YOUR TURN", 150, 10)
    end


    -- draw skill buttons

    if BATTLE[1].team == 0 and SELECTED then
        local offset_y = 50
        local offset_x = 400
        local acting_actor = BATTLE[1]
        for key, value in ipairs(acting_actor.definition.skills) do
            love.graphics.rectangle("line", offset_x, offset_y, 50, 20)
            love.graphics.setFont(DEFAULT_FONT)
            love.graphics.print("Use", offset_x, offset_y)
            love.graphics.print(value.name, offset_x, offset_y + 20)
            love.graphics.print(value.description(acting_actor), offset_x, offset_y + 40)
            offset_y = offset_y + 60
            for index, effect in ipairs(value.effects_sequence) do
                love.graphics.print(tostring(index) .. " ".. effect.description, offset_x, offset_y)
                offset_y = offset_y + 20
            end
        end
    end
end

local function enter()
    WAVE = 1
    GENERATE_WAVE()
end

local scene = {
    enter = enter,
    update = update,
    render = render,
    on_click = handle_click
}

return scene