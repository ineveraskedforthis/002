
local render_meta_actor = require "ui.meta-actor"

SELECTED_PLAYABLE_ACTOR = 1

---@type ActiveSkill[]
local skills_to_learn = {
	require "skills.heal-allies",
	require "skills.heavy-strike",
	require "skills.poison-strike",
	require "skills.shield-random-allies",
	require "skills.fireball",
	require "skills.firestorm",
	require "skills.magic-arrow",
	require "skills.flame-sweep"
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
	for _, weapon in ipairs(value.allowed_weapons) do
		if actor.def.weapon == weapon then
			allowed_weapon = true
		end
	end

	if not allowed_weapon then
		return false
	end

	return true
end

local function render()
	local row = 0
	local col = 0
	local cols = 3

	for index, value in ipairs(PLAYABLE_META_ACTORS) do
		local x = col * (ACTOR_WIDTH + 10) + 40
		local y = row * (ACTOR_HEIGHT + 10) + 50
		if SELECTED_PLAYABLE_ACTOR == index then
			love.graphics.setColor(0.5, 0.5, 0, 1)
			love.graphics.rectangle("fill", x - 4, y - 4, ACTOR_WIDTH + 8, ACTOR_HEIGHT + 8)
		end
		render_meta_actor(x, y, value.def, value.unlocked, value.lineup_position)
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end

	local selected = PLAYABLE_META_ACTORS[SELECTED_PLAYABLE_ACTOR]
	local x = 400
	local y = 20
	for _, value in ipairs(skills_to_learn) do
		if can_learn(value, selected) then
			love.graphics.rectangle("line", x, y, 200, 40)
			love.graphics.printf("Learn " .. value.name, x, y, 200, "center")
			love.graphics.printf("1 skill point, " .. tostring(value.cost) .. " points", x, y + 20, 200, "center")
			y = y + 50
		end
	end

	love.graphics.rectangle("line", 300, 50, 80, 30)
	love.graphics.printf("Return", 300, 50, 80, "center")

	love.graphics.printf("Current skill points: " .. selected.skill_points, 300, 80, 80, "center")

	love.graphics.printf("Known skills:", 300, 120, 80, "center")
	---@type number
	local y_skill = 140
	for _, value in ipairs(selected.skills) do
		love.graphics.printf(value.name, 280, y_skill, 100, "center")
		---@type number
		y_skill = y_skill + 20
	end
	for _, value in ipairs(selected.def.inherent_skills) do
		love.graphics.printf(value.name, 280, y_skill, 100, "center")
		---@type number
		y_skill = y_skill + 20
	end
end

local function update(dt)

end

local rect = require "ui.rect"

local function handle_click(x, y)

	if rect(300, 50, 80, 30, x, y) then
		CURRENT_SCENE = SCENE_BATTLE_SELECTOR
	end
	local row = 0
	local col = 0
	local cols = 3

	for index, value in ipairs(PLAYABLE_META_ACTORS) do
		if value.unlocked and rect(col * (ACTOR_WIDTH + 10) + 40, row * (ACTOR_HEIGHT + 10) + 50, ACTOR_WIDTH, ACTOR_WIDTH, x, y) then
			SELECTED_PLAYABLE_ACTOR = index
		end
		col = col + 1
		if col >= cols then
			row = row + 1
			col = 0
		end
	end

	local selected = PLAYABLE_META_ACTORS[SELECTED_PLAYABLE_ACTOR]
	local x_button = 400
	local y_button = 20
	for _, value in ipairs(skills_to_learn) do
		if can_learn(value, selected) then
			if rect(x_button, y_button, 200, 40, x, y) and selected.skill_points > 0 and CURRENCY >= value.cost then
				---@type number
				CURRENCY = CURRENCY - value.cost
				selected.skill_points = selected.skill_points - 1
				table.insert(selected.skills, value)
			end
			y_button = y_button + 50
		end
	end
end

local scene = {
	update = update,
	render = render,
	on_click = handle_click
}

return scene