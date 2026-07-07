---@param def MetaActor
---@param wrapper MetaActorWrapper|nil
return function (def, wrapper, x, y)
	---@type Actor
	local temp = {
		HP = TOTAL_MAX_HP(def, wrapper),
		SHIELD = 0,
		action_number = 0,
		definition = def,
		pending_damage = {},
		status_effects = {},
		x = x,
		y = y,
		visible = true,
		wrapper = wrapper,
		energy = def.max_energy,
		battle_order = 0,
		w = 0,
		h = 0,
		displayed = true,
		instruction_execution_timer = 0,
		lock = false,
		stack = {},
		stack_top = 0,
		view_x = x,
		view_y = y,
		counterattack_count = 0
	}

	return temp
end