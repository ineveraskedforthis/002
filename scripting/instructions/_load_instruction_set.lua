---@enum INSTRUCTION
INSTRUCTION = {
	RETURN = 1,
	LOCK_POSITION_TARGET_ACQUIRE = 2,
	LOCK_POSITION_TARGET_RELEASE = 3,
	LOCK_ACTOR_TARGET_ACQUIRE = 4,
	LOCK_ACTOR_TARGET_RELEASE = 5,
	LOCK_ACTOR_ORIGIN_ACQUIRE = 6,
	LOCK_ACTOR_ORIGIN_RELEASE = 7,
	MOVE = 8,
	MELEE_ATTACK = 9,
	MELEE_COUNTERATTACK = 10,
	LOAD_REGISTER_CURRENT_TO_ORIGIN = 11,
	SET_CURRENT_DIALOG = 12,
	RETURN_IF_TARGET_AND_ORIGIN_ARE_SAME = 13
}

---@param state GameState
return function (state)
	state.instruction_set = {}
	state.instruction_set[INSTRUCTION.MOVE] = function (state, frame, dt, arg1, arg2, arg3)
		local actor = state.actors[frame.acting_actor]

		local movement_speed = 10
		local dx = (frame.origin_x - frame.origin_x)
		local dy = (frame.origin_y - frame.origin_y)
		local distance = math.sqrt(dx * dx + dy * dy)


		local timer = frame.timer
		local progress = timer * movement_speed / distance

		if progress >= 1 or distance == 0 then
			actor.x = frame.target_x
			actor.y = frame.target_y
			-- print("SUCCESS:", frame.target_x, frame.target_y)
			actor.view_x = frame.target_x
			actor.view_y = frame.target_y
			frame.timer = 0
			return true, false
		else
			frame.timer = timer + dt
			-- print("PROGRESS TARGET:", frame.target_x, frame.target_y)
			-- print("PROGRESS ORIGIN:", frame.origin_x, frame.origin_y)
			actor.view_x = frame.target_x * progress + frame.origin_x * (1 - progress)
			actor.view_y = frame.target_y * progress + frame.origin_y * (1 - progress)
			-- print("NEXT_VIEW:", actor.view_x, actor.view_y, distance)
			return false, false
		end
	end
	state.instruction_set[INSTRUCTION.MELEE_ATTACK] = function (state, frame, dt, arg1, arg2, arg3)
		local actor = state.actors[frame.acting_actor]
		local target = state.actors[frame.target_actor]

		-- print("COUNT", target.counterattack_count)

		if target.counterattack_count > 0 then
			target.counterattack_count = target.counterattack_count - 1
			target.stack_top = target.stack_top + 1
			target.stack[target.stack_top] = {
				acting_actor = frame.target_actor,
				stack_pointer = state.programs[PROGRAM.MELEE_COUNTERATTACK],
				target_x = frame.origin_x,
				target_y = frame.origin_y,
				origin_x = frame.target_x,
				origin_y = frame.target_y,
				timer  = 0,
				target_actor = frame.acting_actor
			}
			return true, false
		end

		if frame.timer >= 1 then
			frame.timer = 0
			DEAL_DAMAGE(state, actor, target, 50)
			return true, false
		else
			frame.timer = frame.timer + dt
			return false, false
		end
	end
	state.instruction_set[INSTRUCTION.LOAD_REGISTER_CURRENT_TO_ORIGIN] = function (state, frame, dt, arg1, arg2, arg3)
		frame.origin_x = state.actors[frame.acting_actor].x
		frame.origin_y = state.actors[frame.acting_actor].y

		return true, false
	end
	state.instruction_set[INSTRUCTION.MELEE_COUNTERATTACK] = function (state, frame, dt, arg1, arg2, arg3)
		local actor = state.actors[frame.acting_actor]

		local timer = frame.timer
		local progress = timer

		if progress >= 1 then
			frame.timer = 0
			DEAL_DAMAGE(state, actor, state.actors[frame.target_actor], 50)
			return true, false
		else
			frame.timer = timer + dt
			return false, false
		end
	end
	state.instruction_set[INSTRUCTION.LOCK_POSITION_TARGET_ACQUIRE] = function (state, frame, dt, arg1, arg2, arg3)
		local lock = state.tile_lock[frame.target_x][frame.target_y]
		if lock then
			return false, false
		else
			-- print("ACQUIRE TILE", frame.target_x, frame.target_y)
			state.tile_lock[frame.target_x][frame.target_y] = true
			return true, false
		end
	end
	state.instruction_set[INSTRUCTION.LOCK_POSITION_TARGET_RELEASE] = function (state, frame, dt, arg1, arg2, arg3)
		-- print("RELEASE TILE", frame.target_x, frame.target_y)
		state.tile_lock[frame.target_x][frame.target_y] = false
		return true, false
	end
	state.instruction_set[INSTRUCTION.LOCK_ACTOR_TARGET_ACQUIRE] = function (state, frame, dt, arg1, arg2, arg3)
		local lock = state.actors[frame.target_actor].lock
		if lock then
			return false, false
		else
			print("ACQUIRE ACTOR", frame.target_actor)
			state.actors[frame.target_actor].lock = true
			return true, false
		end
	end
	state.instruction_set[INSTRUCTION.LOCK_ACTOR_TARGET_RELEASE] = function (state, frame, dt, arg1, arg2, arg3)
		print("RELEASE ACTOR", frame.target_actor)
		state.actors[frame.target_actor].lock = false
		return true, false
	end
	state.instruction_set[INSTRUCTION.LOCK_ACTOR_ORIGIN_ACQUIRE] = function (state, frame, dt, arg1, arg2, arg3)
		local lock = state.actors[frame.acting_actor].lock
		if lock then
			return false, false
		else
			print("ACQUIRE ACTOR", frame.target_actor)
			state.actors[frame.acting_actor].lock = true
			return true, false
		end
	end
	state.instruction_set[INSTRUCTION.LOCK_ACTOR_ORIGIN_RELEASE] = function (state, frame, dt, arg1, arg2, arg3)
		print("RELEASE ACTOR", frame.target_actor)
		state.actors[frame.acting_actor].lock = false
		return true, false
	end
	state.instruction_set[INSTRUCTION.RETURN] = function (state, frame, dt, arg1, arg2, arg3)
		return true, true
	end

	state.instruction_set[INSTRUCTION.SET_CURRENT_DIALOG] = function (state, frame, dt, arg1, arg2, arg3)
		state.current_dialog_actor = frame.target_actor
		return true, false
	end

	state.instruction_set[INSTRUCTION.RETURN_IF_TARGET_AND_ORIGIN_ARE_SAME] =function (state, frame, dt, arg1, arg2, arg3)
		if frame.acting_actor == frame.target_actor then
			return true, true
		end
		return true, false
	end
end