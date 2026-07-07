---@enum PROGRAM
PROGRAM = {
	MOVE = 1,
	MELEE_ATTACK = 2,
	MELEE_COUNTERATTACK = 3,
	WAIT = 4,
	TALK = 5
}

---@alias ParsedInstruction {
--- [1]: INSTRUCTION,
--- [2]: number,
--- [3]: number,
--- [4]: number,
---}

---@param state GameState
---@param program ParsedInstruction[]
local function push_program(state, program)
	local sp =state.instruction_stack_top + 1
	for index, value in ipairs(program) do
		state.instruction_stack_top = state.instruction_stack_top + 1
		state.instruction_stack[state.instruction_stack_top] = value
	end
	return sp
end

---@param state GameState
return function (state)
	state.instruction_stack_top = 0
	state.instruction_stack = {}
	state.programs = {}

	state.programs[PROGRAM.MOVE] = push_program(state, {
		{INSTRUCTION.LOCK_POSITION_TARGET_ACQUIRE},
		{INSTRUCTION.LOCK_ACTOR_ORIGIN_ACQUIRE},
		{INSTRUCTION.LOAD_REGISTER_CURRENT_TO_ORIGIN},
		{INSTRUCTION.MOVE},
		{INSTRUCTION.LOCK_POSITION_TARGET_RELEASE},
		{INSTRUCTION.LOCK_ACTOR_ORIGIN_RELEASE},
		{INSTRUCTION.RETURN}
	})

	state.programs[PROGRAM.TALK] = push_program(state, {
		{INSTRUCTION.SET_CURRENT_DIALOG},
		{INSTRUCTION.RETURN}
	})

	state.programs[PROGRAM.MELEE_ATTACK] = push_program(state, {
		{INSTRUCTION.LOCK_ACTOR_TARGET_ACQUIRE},
		{INSTRUCTION.LOCK_ACTOR_ORIGIN_ACQUIRE},
		{INSTRUCTION.MELEE_ATTACK},
		{INSTRUCTION.LOCK_ACTOR_TARGET_RELEASE},
		{INSTRUCTION.LOCK_ACTOR_ORIGIN_RELEASE},
		{INSTRUCTION.RETURN}
	})

	-- assume that it interrupts actions when target and origin locks have been already acquired
	state.programs[PROGRAM.MELEE_COUNTERATTACK] = push_program(state, {
		{INSTRUCTION.LOCK_ACTOR_TARGET_ACQUIRE},
		{INSTRUCTION.LOCK_ACTOR_ORIGIN_ACQUIRE},
		{INSTRUCTION.MELEE_COUNTERATTACK},
		{INSTRUCTION.LOCK_ACTOR_TARGET_RELEASE},
		{INSTRUCTION.LOCK_ACTOR_ORIGIN_RELEASE},
		{INSTRUCTION.RETURN}
	})

	state.programs[PROGRAM.WAIT] = push_program(state, {
		{INSTRUCTION.RETURN}
	})
end