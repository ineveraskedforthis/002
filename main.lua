---@class Actor
---@field MAX_HP number
---@field HP number
---@field ATK number
---@field DEF number
---@field SPD number
---@field name string

---@class BattleOrder
---@field actor_id number
---@field action_number number
---@field team number


---comment
---@param a Actor
---@param b Actor
function ATTACK(a, b)
    local damage = math.max(0, a.ATK - b.DEF)
    b.HP = b.HP - damage
end

function SPEED_TO_ACTION_OFFSET(speed)
    return math.floor(10000 / speed)
end

AWAIT_TURN = false

function REMOVE_DEAD()
    local removed = false
    local to_remove = 0
    for k, v in ipairs(BATTLE) do
        if ACTORS[v.actor_id].HP <= 0 then
            removed = true
            to_remove = k
            break
        end
    end

    if removed then
        print("remove:" .. ACTORS[BATTLE[to_remove].actor_id].name)
        table.remove(BATTLE, to_remove)
        REMOVE_DEAD()
    else
        return
    end
end

function PROCESS_BATTLE()
    local actor_index = BATTLE[1].actor_id
    local team = BATTLE[1].team
    table.remove(BATTLE, 1)

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

    if ACTORS[actor_index].HP > 0 then
        print("readd to battle:" .. ACTORS[actor_index].name)
        ENTER_BATTLE(actor_index, team, true)

        AWAIT_TURN = true
    end

    REMOVE_DEAD()
end

---comment
---@param actor_index number
---@param team number
---@param was_in_battle boolean
function ENTER_BATTLE(actor_index, team, was_in_battle)
    local max_action_number = 0
    if not was_in_battle then
        for k, v in ipairs(BATTLE) do
            if v.action_number > max_action_number then
                max_action_number = v.action_number
            end
        end
    end

    ---@type BattleOrder
    local new_turn = {
        actor_id = actor_index,
        action_number = max_action_number + SPEED_TO_ACTION_OFFSET(ACTORS[actor_index].SPD),
        team = team
    }

    table.insert(BATTLE, new_turn)
    table.sort(BATTLE, function (a, b)
        return a.action_number < b.action_number
    end)
end

function love.load()
    -- set up actoes

    ---@type Actor
    GG = {
        MAX_HP = 100,
        HP = 100,
        ATK = 50,
        DEF = 0,
        SPD = 100,
        name = "Main Character"
    }

    ---@type Actor
    BASIC_ENEMY_1 = {
        MAX_HP = 100,
        HP = 100,
        ATK = 15,
        DEF = 0,
        SPD = 75,
        name = "Basic Enemy"
    }

    ---@type Actor
    BASIC_ENEMY_2 = {
        MAX_HP = 100,
        HP = 100,
        ATK = 15,
        DEF = 0,
        SPD = 75,
        name = "Basic Enemy"
    }

    ---@type Actor[]
    ACTORS = {
        GG,
        BASIC_ENEMY_1,
        BASIC_ENEMY_2
    }

    GG_INDEX = 1
    BASIC_ENEMY_INDEX = 2

    ---@type BattleOrder[]
    BATTLE = {}

    SELECTED = 0

    ENTER_BATTLE(1, 0, false)
    ENTER_BATTLE(2, 1, false)
    ENTER_BATTLE(3, 1, false)
end

function love.update(dt)
    if BATTLE[1].team == 1 and AWAIT_TURN then
        print("turn of " .. ACTORS[BATTLE[1].actor_id].name)
        -- AI turn

        -- attack the first target

        local target = nil

        for key, value in ipairs(BATTLE) do
            if value.team == 0 then
                target = ACTORS[value.actor_id]
            end
        end

        if target then
            ATTACK(ACTORS[BATTLE[1].actor_id], target)
        end

        AWAIT_TURN = false

        PROCESS_BATTLE()
    end
end

local character_width = 50
local character_height = 70
local spacing = 30

local function rect(rx, ry, rw, rh, x, y)
    if x < rx then
        return false
    end
    if x > rx + rw then
        return false
    end
    if y < ry then
        return false
    end
    if y > ry + rh then
        return false
    end

    return true
end

function love.draw()
    love.graphics.setBackgroundColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, 1)

    if BATTLE[1].team == 0 then
        love.graphics.print("YOUR TURN", 150, 10)
    end

    -- draw player's team

    local offset_x = 150
    local offset_y = 400

    for key, value in ipairs(BATTLE) do
        if BATTLE[key].team == 0 then
            local actor = ACTORS[BATTLE[key].actor_id]
            love.graphics.print(actor.name, offset_x, offset_y - 20)
            love.graphics.rectangle("line", offset_x, offset_y, character_width, character_height)
            love.graphics.print(tostring(actor.HP) .. "/" .. tostring(actor.MAX_HP), offset_x, offset_y + character_height + 2)

            offset_x = offset_x + spacing + character_width
        end
    end

    -- draw enemy team

    local offset_x = 150
    local offset_y = 50

    for key, value in ipairs(BATTLE) do
        if value.team == 1 then
            if SELECTED == value.actor_id then
                love.graphics.rectangle("line", offset_x - 4, offset_y - 4, character_width + 8, character_height + 8)
            end
            local actor = ACTORS[value.actor_id]
            love.graphics.print(actor.name, offset_x, offset_y - 20)
            love.graphics.rectangle("line", offset_x, offset_y, character_width, character_height)
            love.graphics.print(tostring(actor.HP) .. "/" .. tostring(actor.MAX_HP), offset_x, offset_y + character_height + 2)

            offset_x = offset_x + spacing + character_width
        end
    end


    --- draw battle order

    love.graphics.print("ACTION BAR", 0, 0)

    local offset_x = 20
    local offset_y = 20

    for key, value in ipairs(BATTLE) do
        love.graphics.rectangle("line", offset_x, offset_y, 70, 30)
        love.graphics.print(tostring(value.action_number), offset_x + 2, offset_y + 2)

        offset_y = offset_y + 20 + 10
    end


    -- draw buttons

    love.graphics.rectangle("line", 400, 50, 50, 20)
    love.graphics.print("attack", 400, 50)
end

function love.mousepressed(x, y, button, istouch, presses)

    if BATTLE[1].team == 0 and SELECTED ~= 0 then
        if rect(400, 50, 100, 50, x, y) then
            AWAIT_TURN = false
            ATTACK(ACTORS[BATTLE[1].actor_id], ACTORS[SELECTED])
            PROCESS_BATTLE()
        end
    end

    local offset_x = 150
    local offset_y = 50

    for key, value in ipairs(BATTLE) do
        if BATTLE[key].team == 1 then
            if (rect(offset_x, offset_y, character_width, character_height, x, y)) then
                SELECTED = value.actor_id
            end
            offset_x = offset_x + spacing + character_width
        end
    end
end