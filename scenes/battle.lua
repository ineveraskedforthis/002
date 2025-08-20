AWAIT_TURN = false

---@type Actor?
SELECTED = nil

---@type number
WAVE = 1

-- local function clear_dead()
--	 local removed = false
--	 local to_remove = 0
--	 for k, v in ipairs(BATTLE) do
--		 if v.HP <= 0 then
--			 removed = true
--			 to_remove = k
--			 break
--		 end
--	 end

--	 if removed then
--		 local kill_effect =
--		 table.remove(BATTLE, to_remove)
--		 clear_dead()
--		 SELECTED = nil
--	 else
--		 return
--	 end
-- end

local function process_turn()
	local can_proceed = false
	while not can_proceed do
		---@type Actor
		local actor = table.remove(BATTLE, 1)
		if actor.HP > 0 then
			print("readd to battle:" .. BATTLE[1].definition.name)
			ENTER_BATTLE(actor, actor.team, true)
			can_proceed = true
		end
	end

	-- reduce action number

	local offset = -1

	for k, v in ipairs(BATTLE) do
		if v.HP > 0 and v.action_number < offset or offset == -1 then
			offset = v.action_number
		end
	end

	for k, v in ipairs(BATTLE) do
		v.action_number = v.action_number - offset
	end

	-- clear_dead()
	SORT_BATTLE()

	-- queue all effects on new current character
	if (BATTLE[1]) then
		for index, value in ipairs(BATTLE[1].status_effects) do
			table.insert(STATUS_EFFECT_QUEUE, value)
		end
	end
end


local function update(dt)

	if SELECTED.HP <= 0 or not SELECTED.visible then
		-- select the first enemy target
		for index, value in ipairs(BATTLE) do
			if value.team == 1 and (value.HP > 0 and value.visible) then
				SELECTED = value
			end
		end
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

	for key, value in ipairs(BATTLE) do
		if value.HP_view == nil then
			value.HP_view = value.HP
		end

		local diff = value.HP - value.HP_view
		local diff_abs = math.abs(diff)
		local max_hp = TOTAL_MAX_HP(value.definition, value.wrapper)
		if (diff_abs < max_hp / 20) then
			value.HP_view = value.HP
		else
			value.HP_view = value.HP_view + math.max(-max_hp, math.min(max_hp, diff * dt))
		end
	end

	local no_running_effects = true

	do
		local current_effect = EFFECTS_QUEUE[1]
		if (current_effect) then
			no_running_effects = false
			if not current_effect.started then
				current_effect.def.scene_on_start(current_effect.origin, current_effect.target, current_effect.data)
				current_effect.started = true
			end
			current_effect.time_passed = current_effect.time_passed + dt
			if current_effect.def.scene_update(current_effect.time_passed, dt, current_effect.origin, current_effect.target, current_effect.data) then
				table.remove(EFFECTS_QUEUE, 1)
				if current_effect.def.multitarget then
					local targets = current_effect.def.multi_target_selection(current_effect.origin)
					for index, value in ipairs(targets) do
						current_effect.def.target_effect(current_effect.origin, value)
					end
				else
					current_effect.def.target_effect(current_effect.origin, current_effect.target)
				end
			end
			return
		end
	end

	do
		local current_effect = STATUS_EFFECT_QUEUE[1]
		if (current_effect) then
			no_running_effects = false
			if not current_effect.started then
				current_effect.def.scene_on_start(current_effect.origin, current_effect.target, current_effect.data)
				current_effect.started = true
			end
			current_effect.time_passed = current_effect.time_passed + dt
			if current_effect.def.scene_update(current_effect.time_passed, dt, current_effect.origin, current_effect.target, current_effect.data) then
				table.remove(STATUS_EFFECT_QUEUE, 1)
				current_effect.def.target_effect(current_effect.origin, current_effect.target)
			end
			return
		end
	end

	if no_running_effects and not AWAIT_TURN then
		process_turn()
		AWAIT_TURN = true
	end

	-- now, when all effects are resolved, we can update the battle state

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

	if BATTLE[1].team == 1 and AWAIT_TURN and BATTLE[1].HP > 0 then
		print("turn of " .. BATTLE[1].definition.name)
		-- AI turn
		-- attack the first target


		---@type number?
		local target = nil

		local used_skill = BATTLE[1].definition.inherent_skills[1]


		if used_skill.targeted then
			---@type number[]
			local potential_targets = {}
			local count = 0
			for key, value in ipairs(BATTLE) do
				if value.team == 0 then
					table.insert(potential_targets, key)
					count = count + 1
					break
				end
			end
			target = potential_targets[love.math.random(1, count)]
		end

		if target or (not used_skill.targeted) then
			for index, effect in ipairs(used_skill.effects_sequence) do
				local selected_target = nil
				if effect.target_selection then
					selected_target = effect.target_selection(BATTLE[1])
				else
					selected_target = BATTLE[target]
				end

				if (selected_target) then
					---@type Effect
					local new_effect = {
						data = {},
						def = effect,
						origin = BATTLE[1],
						target = selected_target,
						time_passed = 0,
						started = false,
						times_activated = 0
					}
					table.insert(EFFECTS_QUEUE, new_effect)
				end
			end
		end

		AWAIT_TURN = false
	end
end

local style = require "ui._style"
local rect = require "ui.rect"
local skills_panel = require "ui.skills-panel"

local function handle_click(x, y)
	local offset_x = 150
	local offset_y = 50

	for key, value in ipairs(BATTLE) do
		if BATTLE[key].team == 1 and BATTLE[key].HP > 0 and BATTLE[key].visible then
			local r_x = offset_x + (style.battle_actors_spacing + ACTOR_WIDTH) * (value.pos - 1)
			if (rect(r_x, offset_y, ACTOR_WIDTH, ACTOR_HEIGHT, x, y)) then
				SELECTED = value
			end
		end
	end

	skills_panel.on_click(x, y)
end

local main_render = require "fights.battle-render"


local function render()
	love.graphics.setBackgroundColor(1, 1, 1, 1)
	love.graphics.setColor(0, 0, 0, 1)

	local current_effect = EFFECTS_QUEUE[1]
	main_render()
	if current_effect then
		current_effect.def.scene_render(
			current_effect.time_passed,
			current_effect.origin,
			current_effect.target,
			current_effect.data
		)
		return
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
	skills_panel.render()
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