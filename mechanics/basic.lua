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

---@param a MetaActor
---@param w MetaActorWrapper?
function TOTAL_MAG(a, w)
	local x = a.MAG
	if w then
		x = x + w.level * a.MAG_per_level
	end
	return x
end

---@param a MetaActor
---@param w MetaActorWrapper?
function TOTAL_MAX_HP(a, w)
	local x = a.MAX_HP
	if w then
		x = x + w.level * 10
	end
	return x
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

---@param origin Actor
---@param target Actor
---@param value ActiveSkill
function USE_SKILL(origin, target, value)
	-- ATTACK(ACTORS[BATTLE[1].actor_id], ACTORS[SELECTED])
	for index, effect in ipairs(value.effects_sequence) do
		if effect.target_selection then
			target = effect.target_selection(origin)
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
		table.insert(EFFECTS_QUEUE, new_effect)
	end
end

---comment
---@param a Actor
---@param b Actor
---@param attacker_str_ratio number
---@param attacker_mag_ratio number
---@param defender_defense_ratio number
function DEAL_DAMAGE(a, b, attacker_str_ratio, attacker_mag_ratio, defender_defense_ratio)
	if b.HP <= 0 then
		return
	end
	local output = (
		TOTAL_STR(a.definition, a.wrapper) * attacker_str_ratio + TOTAL_MAG(a.definition, a.wrapper) * attacker_mag_ratio
	) * (1 + WEAPON_DMG_MULT(a.definition.weapon) * (1 + WEAPON_MASTERY(a)))
	local reduction = b.definition.DEF * defender_defense_ratio
	local raw_damage = output - reduction

	local damage = raw_damage

	damage = math.floor(damage)

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
	local origin_max_hp = TOTAL_MAX_HP(origin.definition, origin.wrapper)
	local target_max_hp = TOTAL_MAX_HP(target.definition, target.wrapper)
	local add = math.floor(origin_max_hp * origin_hp_ratio + origin.definition.DEF * origin_defense_ratio)
	local mult = math.min(1, max_hp_ratio * target_max_hp / target.SHIELD)
	target.SHIELD = target.SHIELD + math.floor(add * mult)
end

---@param origin Actor
---@param target Actor
---@param attacker_mag_ratio number
function RESTORE_HP(origin, target, attacker_mag_ratio)
	local add = math.floor(TOTAL_MAG(origin.definition, origin.wrapper) * attacker_mag_ratio)
	local target_max_hp = TOTAL_MAX_HP(target.definition, target.wrapper)
	target.HP = math.min(target_max_hp, target.HP + add)

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
	---@type number[]
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