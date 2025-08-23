local effects = require "effects._manager"
local gemstones = require "gemstones._manager"

---comment
---@param a Actor
---@param b Actor
---@param effect number
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

function LVL_TO_REQUIRED_EXP(lvl)
	return math.pow(2, lvl)
end

---@param a MetaActorWrapper
---@param x number
function ADD_EXP(a, x)
	a.experience = a.experience + x
	while a.experience > LVL_TO_REQUIRED_EXP(a.level) do
		a.experience = a.experience - LVL_TO_REQUIRED_EXP(a.level)
		a.level = a.level + 1
		a.skill_points = a.skill_points + 1
	end
end

---comment
---@param w WEAPON
function WEAPON_DMG_MULT(w)
	if w == WEAPON.NONE then
		return 0
	elseif w == WEAPON.SWORD then
		return 0.5
	end
end

---@param a Actor
function WEAPON_MASTERY(a)
	local mastery = a.definition.weapon_mastery

	if a.wrapper then
		mastery = mastery + a.wrapper.additional_weapon_mastery
	end

	return mastery
end

---@param a MetaActor
---@param w MetaActorWrapper?
function TOTAL_STR(a, w)
	local str = a.STR
	if w then
		str = str + w.level * a.STR_per_level
	end
	return str
end

---comment
---@param a Actor
function TOTAL_STR_ACTOR(a)
	return TOTAL_STR(a.definition, a.wrapper)
end

---@param a MetaActor
---@param w MetaActorWrapper?
function TOTAL_MAG(a, w)
	---@type number
	local x = a.MAG
	if w then
		x = x + w.level * a.MAG_per_level
		for index, value in ipairs(w.gemstones) do
			local def = gemstones.get(value)
			---@type number
			x = x + def.additional_mag
		end
	end
	return x
end

---comment
---@param a Actor
function TOTAL_MAG_ACTOR(a)
	return TOTAL_MAG(a.definition, a.wrapper)
end

---@param a MetaActor
---@param w MetaActorWrapper?
function TOTAL_MAX_HP(a, w)
	local x = a.MAX_HP
	if w then
		x = x + w.level * 10
		for index, value in ipairs(w.gemstones) do
			local def = gemstones.get(value)
			x = x + def.additional_hp
		end
	end
	return x
end

---comment
---@param a Actor
function TOTAL_MAX_HP_ACTOR(a)
	return TOTAL_MAX_HP(a.definition, a.wrapper)
end

---@param a MetaActor
---@param w MetaActorWrapper?
function TOTAL_SPD(a, w)
	local x = a.SPD
	if w then
		x = x + w.level * a.SPD_per_level
	end
	return x
end

---@param state GameState
---@param battle Battle
---@param origin Actor
---@param target Actor
---@param skill ActiveSkill
function USE_SKILL(state, battle, origin, target, skill)
	assert(origin.energy >= skill.required_energy)
	origin.energy = origin.energy - skill.required_energy

	for index, effect in ipairs(skill.effects_sequence) do
		local def = effects.get(effect)
		if def.target_selection then
			target = def.target_selection(state, battle, origin)
		end
		---@type Effect
		local new_effect = {
			data = {},
			def = effect,
			origin = origin,
			target = target,
			time_passed = 0,
			started = false,
			times_activated = 0
		}
		table.insert(battle.effects_queue, new_effect)
	end
end

---@param state GameState
---@param battle Battle
---@param origin Actor
---@param target Actor
---@param skill ActiveSkill
function CAN_USE_SKILL(state, battle, origin, target, skill)
	if skill.required_energy > origin.energy then
		return false
	end
	return true
end

---@param state GameState
---@param battle Battle
---@param a Actor
---@param b Actor
---@param actual_damage number
function ON_DAMAGE_DEALT(state, battle, a, b, actual_damage)
	if a.wrapper then
		for index, value in ipairs(a.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_damage_dealt_effect(state, battle, a, b, actual_damage)
		end
	end
	if b.wrapper then
		for index, value in ipairs(b.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_damage_received_effect(state, battle, a, b, actual_damage)
		end
	end
end

---@param state GameState
---@param battle Battle
---@param a Actor
function ON_TURN_START(state, battle, a)
	a.energy = math.min(a.definition.max_energy, a.energy + 1)
	for _, value in ipairs(a.status_effects) do
		table.insert(battle.effects_queue, value)
	end
	if a.wrapper then
		for _, value in ipairs(a.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_turn_start(state, battle, a)
		end
	end
end

---@param state	GameState
---@param battle Battle
---@param a Actor
---@param b Actor
function ON_KILL(state, battle, a, b)
	if a.wrapper then
		for index, value in ipairs(a.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_kill_effect(state, battle, a, b)
		end
	end
end

---comment
---@param state GameState
---@param battle Battle
---@param a Actor
---@param b Actor
---@param damage number
function DEAL_DAMAGE(state, battle, a, b, damage)
	print("attacker", a.definition.name)
	print("defender", b.definition.name)


	if b.HP <= 0 then
		return
	end
	if damage <= 0 then
		return
	end

	---@type number
	local actual_damage = math.min(damage, b.SHIELD)

	damage = math.floor(damage)
	-- local recorded_damage = damage
	b.SHIELD = b.SHIELD - damage
	if b.SHIELD < 0 then
		damage = -b.SHIELD
		b.SHIELD = 0
	else
		damage = 0
	end
	actual_damage = actual_damage + math.min(b.HP, damage)
	print("HP", b.HP)
	print("damage", damage)
	print("actual damage", actual_damage)
	b.HP = math.max(0, b.HP - damage)
	---@type PendingDamage
	local pending = {
		alpha = 1,
		value = damage
	}
	table.insert(b.pending_damage, pending)
	ON_DAMAGE_DEALT(state, battle, a, b, actual_damage)


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
		table.insert(battle.effects_queue, death)
		ON_KILL(state, battle, a, b)
	end

	if b.definition.damaged_sound then
		b.definition.damaged_sound:stop()
		b.definition.damaged_sound:play()
	end

	print("final hp", b.HP)
end

---@param origin Actor
---@param target Actor
---@param amount number
function ADD_SHIELD(origin, target, amount)
	target.SHIELD = target.SHIELD + math.floor(amount)
end

---@param state GameState
---@param battle Battle
---@param origin Actor
---@param target Actor
---@param amount number
function RESTORE_HP(state, battle, origin, target, amount)
	local amount = math.floor(amount)
	local target_max_hp = TOTAL_MAX_HP(target.definition, target.wrapper)
	target.HP = math.min(target_max_hp, target.HP + amount)

	---@type PendingDamage
	local pending = {
		alpha = 1,
		value = -amount
	}
	table.insert(target.pending_damage, pending)
end

function SPEED_TO_ACTION_OFFSET(speed)
	return math.floor(10000 / speed)
end

