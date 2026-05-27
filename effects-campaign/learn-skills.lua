---@type ActiveSkill[]
local skills_to_learn = {
	require "skills.heal-allies",
	require "skills.heavy-strike",
	require "skills.poison-strike",
	require "skills.apply-poison",
	require "skills.shield-random-allies",
	require "skills.fireball",
	require "skills.firestorm",
	require "skills.magic-arrow",
	require "skills.flame-sweep",
	require "skills.blood-spear",
	require "skills.energy-link",
	require "skills.flicker-strike",
	require "skills.poison-attack"
}


---comment
---@param value ActiveSkill
---@param actor MetaActorWrapper
---@return boolean
local function can_learn(value, actor)
	-- check if already known

	for _, value2 in ipairs(actor.skills) do
		if value2.name == value.name then
			return false
		end
	end

	for _, value2 in ipairs(actor.def.inherent_skills) do
		if value2.name == value.name then
			return false
		end
	end

	if actor.def.max_energy < value.required_energy then
		return false
	end

	if TOTAL_STR(actor.def, actor) < value.required_strength then
		return false
	end

	if TOTAL_MAG(actor.def, actor) < value.required_magic then
		return false
	end

	for _, element in ipairs(value.required_elements) do
		if not actor.def.alignment[element] then
			return false
		end
	end

	local allowed_weapon = false
	local weapon_check_exists = false
	for _, req in ipairs(value.allowed_weapons) do
		weapon_check_exists = true
		if actor.def.weapon == req.weapon and WEAPON_MASTERY(actor.def, actor) >= req.mastery then
			allowed_weapon = true
		end
	end

	if weapon_check_exists and not allowed_weapon then
		return false
	end

	return true
end

---@param actor MetaActorWrapper
return function (actor)
	for _, value in ipairs(skills_to_learn) do
		if can_learn(value, actor) then
			table.insert(actor.skills, value)
		end
	end
end