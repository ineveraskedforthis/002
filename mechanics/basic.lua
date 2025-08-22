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
	local x = a.MAG
	if w then
		x = x + w.level * a.MAG_per_level
		for index, value in ipairs(w.gemstones) do
			local def = gemstones.get(value)
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

---@param origin Actor
---@param target Actor
---@param value ActiveSkill
function USE_SKILL(origin, target, value)
	for index, effect in ipairs(value.effects_sequence) do
		local def = effects.get(effect)
		if def.target_selection then
			target = def.target_selection(origin)
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

---@param a Actor
---@param b Actor
---@param actual_damage number
function ON_DAMAGE_DEALT(a, b, actual_damage)
	if a.wrapper then
		for index, value in ipairs(a.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_damage_dealt_effect(a, b, actual_damage)
		end
	end
end

---@param a Actor
function ON_TURN_START(a)
	for index, value in ipairs(a.status_effects) do
		table.insert(STATUS_EFFECT_QUEUE, value)
	end
	if a.wrapper then
		for index, value in ipairs(a.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_turn_start(a)
		end
	end
end

---@param actor_index number
---@param gemstone_index number
function GIVE_GEMSTONE(actor_index, gemstone_index)
	-- remove from old owner if it exists
	local gemstone = COLLECTED_GEMSTONES[gemstone_index]
	local old_owner = gemstone.actor
	if old_owner ~= 0 then
		-- find gemstone and remove it
		local id = 0
		for index, value in ipairs(PLAYABLE_META_ACTORS[old_owner].gemstones) do
			if value == gemstone_index then
				id = index
			end
		end
		if id ~= 0 then
			table.remove(PLAYABLE_META_ACTORS[old_owner].gemstones, id)
		end
	end

	if actor_index == 0 then
		return
	end

	local actor = PLAYABLE_META_ACTORS[actor_index]
	table.insert(actor.gemstones, gemstone_index)
	gemstone.actor = actor_index
end

---@param a Actor
---@param b Actor
function ON_KILL(a, b)
	if a.wrapper then
		for index, value in ipairs(a.wrapper.gemstones) do
			local def = gemstones.get(value)
			def.on_kill_effect(a, b)
		end
	end
end

---comment
---@param a Actor
---@param b Actor
---@param damage number
function DEAL_DAMAGE(a, b, damage)
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
	ON_DAMAGE_DEALT(a, b, actual_damage)


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
		ON_KILL(a, b)
	end

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
---@param amount number
function RESTORE_HP(origin, target, amount)
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